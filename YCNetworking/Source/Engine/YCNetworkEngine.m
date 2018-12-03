//
//  YCNetworkEngine.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "YCNetworkEngine.h"
#import "YCNetworkMacro.h"
#import "YCNetworkConst.h"
#import "YCNetworkConfig.h"
#import "YCFormDataConfig.h"
#import "YCURLRequest_InternalParams.h"
#import "YCAPIRequest_InternalParams.h"
#import "YCTaskRequest_InternalParams.h"

@interface YCNetworkEngine(){
    dispatch_semaphore_t _lock;
}
@property (nonatomic,strong)NSMutableDictionary <NSString *, __kindof AFURLSessionManager *> *sessionManagerCache;
@property (nonatomic,strong)NSMutableDictionary <NSString *, __kindof NSURLSessionTask *> *sessionTasksCache;
@property (nonatomic,strong)NSMutableDictionary <NSNumber *, NSString *> *resumePathCache;
@property (nonatomic,strong)NSMutableDictionary <NSString *, AFNetworkReachabilityManager *> *reachabilities;
@end

@implementation YCNetworkEngine
- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
        _reachabilities = [NSMutableDictionary dictionary];
        _sessionManagerCache = [NSMutableDictionary dictionary];
        _sessionTasksCache = [NSMutableDictionary dictionary];
        _resumePathCache = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (YCNetworkEngine *)sharedEngine {
    static YCNetworkEngine *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

#pragma mark - 获取AFHTTPSessionManager
/**
 根据请求对象获取AFSessionManager

 @param requestObject 请求对象
 @param config 请求参数
 @return AFURLSessionManager
 */
- (AFURLSessionManager *)sessionManagerByRequest:(__kindof YCURLRequest *)requestObject andManagerConfig:(YCNetworkConfig *)config {
    if (!requestObject){
        return nil;
    }
    /** 拼接baseUrlStr **/
    NSString *baseUrlStr = [self createBaseURLString:requestObject andConfig:config];

    /** 设置AFSecurityPolicy参数 */
    AFSecurityPolicy *securityPolicy = [self createSecurityPolicy:requestObject andConfig:config];
    /** 如果requestObject为YCTask */
    if ([requestObject isKindOfClass:[YCTaskRequest class]]) {
        // AFURLSessionManager
        return [self createSessionManager:config
                         andBaseURLString:baseUrlStr
                        andSecurityPolicy:securityPolicy];

        /** 如果requestObject为YCAPI */
    } else if ([requestObject isKindOfClass:[YCAPIRequest class]]) {
        // AFHTTPSessionManager
        return [self createSessionManager:requestObject
                                andConfig:config
                         andBaseURLString:baseUrlStr
                        andSecurityPolicy:securityPolicy];
    } else {
        return nil;
    }
}

#pragma mark - 移除sessionTask
- (void)removeTaskForKey:(NSString *)hashKey {
    YCLock();
    if ([self.sessionTasksCache objectForKey:hashKey]) {
        [self.sessionTasksCache removeObjectForKey:hashKey];
    }
    YCUnlock();
}
# pragma mark - 发送请求
- (void)sendRequest:(__kindof YCURLRequest *)requestObject
          andConfig:(YCNetworkConfig *)config
       progressBack:(YCProgressBlock)progressCallBack
           callBack:(YCCallbackBlock)callBack {
    if (!requestObject){
        [self faultTolerantProcessWithBlock:callBack
                           andRequestObject:requestObject
                               andErrorCode:NSURLErrorUnsupportedURL andErrorDescription:@"请求对象不存在！"];
        return;
    }
    // 如果缓存中已有当前task，则立即使api返回失败回调，错误信息为frequentRequestErrorStr
    if ([self.sessionTasksCache objectForKey:[requestObject hashKey]]) {
        [self faultTolerantProcessWithBlock:callBack
                           andRequestObject:requestObject
                               andErrorCode:NSURLErrorCancelled
                        andErrorDescription:config.tips.frequentRequestErrorStr];
        return;
    }
    /** 必要参数 */
    /** 生成sessionManager */
    AFURLSessionManager *sessionManager = [self sessionManagerByRequest:requestObject andManagerConfig:config];
    if (!sessionManager) {
        [self faultTolerantProcessWithBlock:callBack
                           andRequestObject:requestObject
                               andErrorCode:NSURLErrorUnsupportedURL andErrorDescription:@"SessionManager无法构建！"];
        return;
    }
    /** 生成requestURLString */
    NSString *requestURLString;
    NSString *host;
    // 如果定义了自定义的cURL, 则直接使用
    NSURL *cURL = [NSURL URLWithString:[requestObject customURL]];
    if (cURL){
        host = [NSString stringWithFormat:@"%@://%@", cURL.scheme, cURL.host];
        requestURLString = cURL.absoluteString;
    } else {
        NSString *tmpBaseURLStr = (NSString *)[requestObject baseURL] ?: config.request.baseURL;
        if ([tmpBaseURLStr hasSuffix:@"/"]) {
            tmpBaseURLStr = [tmpBaseURLStr substringWithRange:NSMakeRange(0, tmpBaseURLStr.length - 1)];
        }
        NSURL *tmpBaseURL = [NSURL URLWithString:tmpBaseURLStr];
        host = [NSString stringWithFormat:@"%@://%@", tmpBaseURL.scheme, tmpBaseURL.host];
        // 使用BaseUrl + apiversion(可选) + path 组成 UrlString
        // 如果有apiVersion且类型不是YCTask时，则在requestUrlStr中插入该参数
        if (IsEmptyValue(config.request.apiVersion) || [requestObject isKindOfClass:[YCTaskRequest class]]) {
            requestURLString = tmpBaseURL.absoluteString;
        } else {
            requestURLString = [NSString stringWithFormat:@"%@/%@",tmpBaseURL.absoluteString, config.request.apiVersion];
        }
        if (!IsEmptyValue([requestObject path])) {
            requestURLString = [NSString stringWithFormat:@"%@/%@",requestURLString,[requestObject path]];
        }
    }
    if (IsEmptyValue(requestURLString)){
        [self faultTolerantProcessWithBlock:callBack
                           andRequestObject:requestObject
                               andErrorCode:NSURLErrorUnsupportedURL andErrorDescription:@"requestURLString无法构建！"];
        return;
    }
    /** 网络状态不好使自动放弃该此请求 */
    // 设置reachbility,监听url为baseURL
    SCNetworkReachabilityRef hostReachable = SCNetworkReachabilityCreateWithName(NULL, [host UTF8String]);
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(hostReachable, &flags);
    BOOL isReachable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    if (hostReachable){
        CFRelease(hostReachable);
    }
    // 如果无网络，则立即使api响应失败回调，错误信息是networkNotReachableErrorStr
    if(!isReachable) {
        [self faultTolerantProcessWithBlock:callBack
                           andRequestObject:requestObject
                               andErrorCode:NSURLErrorCannotConnectToHost andErrorDescription:[NSString stringWithFormat:@"%@, %@ 无法访问", config.tips.networkNotReachableErrorStr, host]];
        return;
    }
    // 进度Block
    void (^progressBlock)(NSProgress *progress) = ^(NSProgress *progress) {
        if (progress.totalUnitCount <= 0) return;
        dispatch_async_main(config.request.callbackQueue, ^{
            if(progressCallBack) {
                progressCallBack(progress);
            }
            if(requestObject.progressHandler){
                requestObject.progressHandler(progress);
            }
        });
    };
    /** 根据requestObject类型，发送请求 */
    // requestObject为YCAPI时
    if([requestObject isKindOfClass:[YCAPIRequest class]]) {
        YCAPIRequest *api = requestObject;
        AFHTTPSessionManager *session = (AFHTTPSessionManager *)sessionManager;
        /** 生成请求参数 */
        NSMutableDictionary<NSString *, id> *requestParams;
        requestParams = [NSMutableDictionary dictionaryWithDictionary:api.parameters];
        if(config.request.defaultParams && api.useDefaultParams) {
            [requestParams addEntriesFromDictionary:config.request.defaultParams];
        }
        /** 生成需要的Block */
        // task成功Block
        @yc_weakify(self)
        void (^successBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id resultObject) {
            // 移除dataTask缓存
            @yc_strongify(self)
            if(callBack) {
                callBack(api, resultObject, nil);
            }
            [self removeTaskForKey:api.hashKey];
        };
        // task失败Block
        void (^failureBlock)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
            // 移除dataTask缓存
            @yc_strongify(self)
            if(callBack){
                callBack(api,nil,error);
            }
            [self removeTaskForKey:api.hashKey];
        };
        // 执行AFN的请求
        NSURLSessionDataTask *dataTask;
        switch (api.requestMethodType) {
            case GET: {
                dataTask = [session GET:requestURLString
                             parameters:requestParams
                               progress:progressCallBack
                                success:successBlock
                                failure:failureBlock];
            }
                break;
            case DELETE: {
                dataTask = [session DELETE:requestURLString
                                parameters:requestParams
                                   success:successBlock
                                   failure:failureBlock];
            }
                break;
            case PATCH: {
                dataTask = [session PATCH:requestURLString
                               parameters:requestParams
                                  success:successBlock
                                  failure:failureBlock];
            }
                break;
            case PUT: {
                dataTask = [session PUT:requestURLString
                             parameters:requestParams
                                success:successBlock
                                failure:failureBlock];
            }
                break;
            case HEAD: {
                dataTask = [session HEAD:requestURLString
                              parameters:requestParams
                                 success:^(NSURLSessionDataTask * _Nonnull task) {
                                     if(successBlock) {
                                         dispatch_async_main(config.request.callbackQueue, ^{
                                             successBlock(task,nil);
                                         });
                                     }
                                 } failure:failureBlock];
            }
                break;
            case POST: {
                if (![api requestConstructingBodyBlock]) {
                    dataTask = [session POST:requestURLString
                                  parameters:requestParams
                                    progress:progressCallBack
                                     success:successBlock
                                     failure:failureBlock];
                } else {
                    void (^formDataBlock)(id<AFMultipartFormData> formData) = ^(id <AFMultipartFormData> formData) {
                        api.requestConstructingBodyBlock((id<YCMultipartFormDataProtocol>)formData);
                    };
                    dataTask = [session POST:requestURLString
                                  parameters:requestParams constructingBodyWithBlock:formDataBlock progress:progressBlock
                                     success:successBlock
                                     failure:failureBlock];
                }
            }
                break;
            default: {
                dataTask = [session GET:requestURLString
                             parameters:requestParams
                               progress:progressBlock
                                success:successBlock
                                failure:failureBlock];
            }
                break;
        }

        // 缓存dataTask
        if (dataTask) {
            YCLock();
            self.sessionTasksCache[api.hashKey] = dataTask;
            YCUnlock();
        }

        // requestObject为YCTask时
    } else if ([requestObject isKindOfClass:[YCTaskRequest class]]) {
        /** 准备请求参数 */
        YCTaskRequest *task = requestObject;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]];
        NSURL *fileURL = task.filePath ? [NSURL fileURLWithPath:task.filePath] : nil;
        if (!fileURL) {
            return;
        }

        /** 生成需要的Block */
        // 下载地址Block
        NSURL * (^destinatioBlock)(NSURL *targetPath, NSURLResponse *response) = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
            return fileURL ?: [NSURL fileURLWithPath:path];
        };

        @yc_weakify(self);
        void (^uploadCompleteBlock)(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) = ^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
            @yc_strongify(self);
            if (callBack) {
                callBack(task, responseObject, error);
            }
            [self removeTaskForKey:task.hashKey];
        };

        // 下载完成的Block
        void(^downloadCompleteBlock)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) = ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            @yc_strongify(self);
            if (callBack) {
                callBack(task, filePath, error);
            }
            [self removeTaskForKey:task.hashKey];
        };

        NSURLSessionTask *sessionTask;
        switch (task.requestTaskType) {
            case Upload:{
                [request setHTTPMethod:@"POST"];
                sessionTask = [sessionManager uploadTaskWithRequest:request
                                                           fromFile:fileURL progress:progressBlock completionHandler:uploadCompleteBlock];
            }
                break;
            case Download: {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:task.resumePath]];
                if(data) {
                    sessionTask = [sessionManager downloadTaskWithResumeData:data
                                                                    progress:progressBlock
                                                                 destination:destinatioBlock completionHandler:downloadCompleteBlock];
                } else {
                    sessionTask = [sessionManager downloadTaskWithRequest:request
                                                                 progress:progressBlock destination:destinatioBlock completionHandler:downloadCompleteBlock];
                }
                YCLock();
                self.resumePathCache[@(sessionTask.hash)] = task.resumePath;
                YCUnlock();
            }
                break;
            default:
                break;
        }

        // 缓存dataTask
        if (sessionTask) {
            [sessionTask resume];
            YCLock();
            self.sessionTasksCache[task.hashKey] = sessionTask;
            YCUnlock();
        }
    } else {
        return;
    }
}

- (void)cancelRequestByIdentifier:(NSString *)identifier {
    NSURLSessionTask *sessiontask = [self.sessionTasksCache objectForKey:identifier];
    if (sessiontask) {
        YCLock();
        if ([sessiontask isKindOfClass:[NSURLSessionDownloadTask class]]) {
            NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)sessiontask;
            [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                [resumeData writeToFile:self.resumePathCache[@(downloadTask.hash)] atomically:YES];
            }];
        } else {
            [sessiontask cancel];
            [self.sessionTasksCache removeObjectForKey:identifier];
        }
        YCUnlock();
    }
}

- (__kindof NSURLSessionTask *)requestByIdentifier:(NSString * _Nonnull)identifier {
    return [self.sessionTasksCache objectForKey:identifier] ?: nil;
}

- (void)listeningWithDomain:(NSString *)domain listeningBlock:(YCReachabilityBlock)listener {
    AFNetworkReachabilityManager *manager = [self.reachabilities objectForKey:domain];
    if (!manager) {
        manager = [AFNetworkReachabilityManager managerForDomain:domain];
        self.reachabilities[domain] = manager;
    }
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        YCReachabilityStatus result = YCReachabilityStatusUnknown;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                result = YCReachabilityStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                result = YCReachabilityStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                result = YCReachabilityStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                result = YCReachabilityStatusReachableViaWiFi;
                break;
            default:
                result = YCReachabilityStatusUnknown;
                break;
        }
        if (listener){
            listener(result);
        }
    }];
    [manager startMonitoring];
}

- (void)stopListeningWithDomain:(NSString *)domain {
    AFNetworkReachabilityManager *manager = [self.reachabilities objectForKey:domain];
    if (manager) {
        [manager stopMonitoring];
        if ([self.reachabilities objectForKey:domain]) {
            [self.reachabilities removeObjectForKey:domain];
        }
    }
}

#pragma mark - private method
// 创建BaseURLString
- (NSString *)createBaseURLString:(YCURLRequest *)requestObject andConfig:(YCNetworkConfig *)config {
    NSString *baseUrlStr;
    // 如果定义了自定义的cURL, 则直接使用
    NSURL *cURL = [NSURL URLWithString:requestObject.customURL];
    if (cURL.host) {
        baseUrlStr = [NSString stringWithFormat:@"%@://%@", cURL.scheme ?: @"https", cURL.host];
    } else {
        NSAssert(requestObject.baseURL != nil || config.request.baseURL != nil, @"api baseURL 和 self.config.baseurl 两者必须有一个有值");
        NSString *tmpStr = requestObject.baseURL ?: config.request.baseURL;
        // 在某些情况下，一些用户会直接把整个url地址写进 baseUrl
        // 因此，还需要对baseUrl 进行一次切割
        NSURL *tmpURL = [NSURL URLWithString:tmpStr];
        baseUrlStr = [NSString stringWithFormat:@"%@://%@", tmpURL.scheme ?: @"https", tmpURL.host];;
    }
    return baseUrlStr;
}

// 创建AFSecurityPolicy
- (AFSecurityPolicy *)createSecurityPolicy:(YCURLRequest *)requestObject andConfig:(YCNetworkConfig *)config {
    YCSecurityPolicyConfig *requestSecurityPolicy = requestObject.securityPolicy;
    NSInteger pinningMode = requestSecurityPolicy.SSLPinningMode ?: config.defaultSecurityPolicy.SSLPinningMode;
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:pinningMode];
    securityPolicy.allowInvalidCertificates = requestSecurityPolicy.allowInvalidCertificates ?: config.defaultSecurityPolicy.allowInvalidCertificates;
    securityPolicy.validatesDomainName = requestSecurityPolicy.validatesDomainName ?: config.defaultSecurityPolicy.validatesDomainName;
    NSString *cerPath = requestSecurityPolicy.cerFilePath ?: config.defaultSecurityPolicy.cerFilePath;
    NSData *certData = nil;
    if (cerPath && ![cerPath isEqualToString:@""]) {
        certData = [NSData dataWithContentsOfFile:cerPath];
        if (certData) {
            securityPolicy.pinnedCertificates = [NSSet setWithObject:certData];
        }
    }
    return securityPolicy;
}

- (AFURLSessionManager *)createSessionManager:(YCNetworkConfig *)config
                             andBaseURLString:(NSString *)baseUrlStr
                            andSecurityPolicy:(AFSecurityPolicy *)securityPolicy {
    AFURLSessionManager *sessionManager = [self.sessionManagerCache objectForKey:baseUrlStr];
    if (!sessionManager){
        NSURLSessionConfiguration *sessionConfig;
        if (config){
            if (config.policy.isBackgroundSession){
                NSString *kBackgroundSessionID = [NSString stringWithFormat:@"com.anyuechao.backgroundSession.task.%@",baseUrlStr];
                NSString *kSharedContainerIdentifier = config.policy.AppGroup ?: [NSString stringWithFormat:@"com.anyuechao.testApp"];
                sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroundSessionID];
                sessionConfig.sharedContainerIdentifier = kSharedContainerIdentifier;
            } else {
                sessionConfig.HTTPMaximumConnectionsPerHost = config.request.maxHttpConnectionPerHost;
            }
            sessionConfig.HTTPMaximumConnectionsPerHost = MAX_HTTP_CONNECTION_PER_HOST;
        }
        sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfig];
        [self.sessionManagerCache setObject:sessionManager forKey:baseUrlStr];
    }
    sessionManager.securityPolicy = securityPolicy;
    return sessionManager;
}

// 创建Request序列化工具
- (AFHTTPRequestSerializer *)createRequestSerializer:(YCAPIRequest *)requestObject
                                           andConfig:(YCNetworkConfig *)config {
    AFHTTPRequestSerializer *requestSerializer;
    switch ([requestObject requestSerializerType]) {
        case RequestHTTP:
            requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        case RequestJSON:
            requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        case RequestPlist:
            requestSerializer = [AFPropertyListRequestSerializer serializer];
            break;
        default:
            requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    requestSerializer.cachePolicy = [requestObject cachePolicy];
    requestSerializer.timeoutInterval = [requestObject timeoutInterval];
    NSDictionary *requestHeaderFieldParams = [requestObject header];
    if (![[requestHeaderFieldParams allKeys] containsObject:@"User-Agent"] &&
        config.request.userAgent) {
        [requestSerializer setValue:config.request.userAgent forKey:@"User-Agent"];
    }
    if (requestHeaderFieldParams) {
        [requestHeaderFieldParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    return requestSerializer;
}

// 创建Response序列化工具
- (AFHTTPResponseSerializer *)createResponseSerializer:(YCAPIRequest *)requestObject andConfig:(YCNetworkConfig *)config {
    AFHTTPResponseSerializer *responseSerializer;
    switch ([requestObject responseSerializerType]) {
        case ResponseHTTP:
            responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case ResponseJSON:
            responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case ResponsePlist:
            responseSerializer = [AFPropertyListResponseSerializer serializer];
            break;
        case ResponseXML:
            responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        default:
            responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
    }
    if (requestObject.accpetContentTypes) {
        NSMutableSet *tmpSet = [NSMutableSet setWithSet:requestObject.accpetContentTypes];
        [tmpSet unionSet:responseSerializer.acceptableContentTypes];
        responseSerializer.acceptableContentTypes = [tmpSet copy];
    }
    return responseSerializer;
}

// 创建AFHTTPSessionManager
- (AFHTTPSessionManager *)createSessionManager:(YCAPIRequest *)requestObject
                                     andConfig:(YCNetworkConfig *)config
                              andBaseURLString:(NSString *)baseUrlStr
                             andSecurityPolicy:(AFSecurityPolicy *)securityPolicy {
    AFHTTPSessionManager *sessionManager = [self.sessionManagerCache objectForKey:baseUrlStr];
    if (!sessionManager) {
        // 根据传入的BaseURL创建新的SessionManager
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.HTTPMaximumConnectionsPerHost = config.request.maxHttpConnectionPerHost;
        sessionConfig.requestCachePolicy = [requestObject cachePolicy] ?: config.policy.cachePolicy;
        sessionConfig.timeoutIntervalForRequest = [requestObject timeoutInterval] ?: config.request.requestTimeoutInterval;
        sessionConfig.URLCache = config.policy.URLCache;
        sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr] sessionConfiguration:sessionConfig];
        [self.sessionManagerCache setObject:sessionManager forKey:baseUrlStr];
    }
    sessionManager.requestSerializer = [self createRequestSerializer:requestObject andConfig:config];
    sessionManager.responseSerializer = [self createResponseSerializer:requestObject andConfig:config];
    sessionManager.securityPolicy = securityPolicy;
    return sessionManager;
}

// 容错处理
- (void)faultTolerantProcessWithBlock:(YCCallbackBlock)callbackBlock
                     andRequestObject:(__kindof YCURLRequest *)requestObject
                         andErrorCode:(NSInteger)errorCode
                  andErrorDescription:(NSString *)errorDescription {
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                         code:NSURLErrorUnsupportedURL
                                     userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
    if (callbackBlock) {
        callbackBlock(requestObject, nil, error);
    }
}
@end
