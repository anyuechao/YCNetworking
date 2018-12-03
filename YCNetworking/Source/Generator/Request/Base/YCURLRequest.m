//
//  YCURLRequest.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCURLRequest.h"
#import "YCURLRequest_InternalParams.h"
#import "YCNetworkConfig.h"
#import "YCNetworkMacro.h"
#import "YCNetworkManager.h"
#import "YCSecurityPolicyConfig.h"

@implementation YCURLRequest
#pragma mark - initialize method
- (instancetype)init {
    self = [super init];
    if (self) {
        _cURL = nil;
        _path = nil;
        _baseURL = [YCNetworkManager config].request.baseURL;
        _timeoutInterval = YC_API_REQUEST_TIME_OUT;
        _retryCount = [YCNetworkManager config].request.retryCount;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _securityPolicy = [YCNetworkManager config].defaultSecurityPolicy;
    }
    return self;
}

+ (instancetype)request {
    return [[self alloc] init];
}

- (id)copyWithZone:(NSZone *)zone {
    YCURLRequest *request = [[[self class] alloc] init];
    if (request) {
        request.cURL = [_cURL copyWithZone:zone];
        request.path = [_path copyWithZone:zone];
        request.baseURL = [_baseURL copyWithZone:zone];
        request.timeoutInterval = _timeoutInterval;
        request.retryCount = _retryCount;
        request.securityPolicy = [_securityPolicy copyWithZone:zone];
        request.cachePolicy = _cachePolicy;
        request.delegate = _delegate;
    }
    return request;
}

#pragma mark - parameters append method
// 设置YCAPI的requestDelegate
- (__kindof YCURLRequest *(^)(id<YCURLRequestDelegate> _Nullable delegate))setDelegate {
    return ^YCURLRequest* (id<YCURLRequestDelegate>delegate){
        self.delegate = delegate;
        return self;
    };
}
// 设置API的baseURL，该参数会覆盖config中的baseURL
- (__kindof YCURLRequest *(^) (NSString *baseURL))setBaseURL {
    return ^YCURLRequest *(NSString *baseURL) {
        self.baseURL = baseURL;
        return self;
    };
}
// urlQuery，baseURL后的地址
- (__kindof YCURLRequest *(^) (NSString *_Nullable path))setPath {
    return ^YCURLRequest * (NSString *path) {
        self.path = path;
        return self;
    };
}
// 自定义的RequestUrl，该参数会无视任何baseURL的设置，优先级最高
- (__kindof YCURLRequest *(^) (NSString *customURL))setCustomURL {
    return ^YCURLRequest *(NSString *customURL) {
        self.cURL = customURL;
        NSURL *tmpURL = [NSURL URLWithString:customURL];
        if (tmpURL.host) {
            self.baseURL = [NSString stringWithFormat:@"%@://%@",tmpURL.scheme ?: @"https", tmpURL.host];
            self.path  = [NSString stringWithFormat:@"%@",tmpURL.query];
        }
        return self;
    };
}
// HTTPS 请求的Security策略
- (__kindof YCURLRequest *(^) (YCSecurityPolicyConfig *securityPolicy))setSecurityPolicy {
    return ^YCURLRequest *(YCSecurityPolicyConfig *securityPolicy) {
        self.securityPolicy = securityPolicy;
      return self;
    };
}
// HTTP 请求的Cache策略
- (__kindof YCURLRequest *(^) (NSURLRequestCachePolicy requestCachePolicy))setCachePolicy {
    return ^YCURLRequest*(NSURLRequestCachePolicy requestCachePolicy) {
        self.cachePolicy = requestCachePolicy;
        return self;
    };
}
// HTTP 请求超时的时间，默认为15秒
- (__kindof YCURLRequest *(^) (NSTimeInterval requestTimeoutInterval))setTimeout {
    return ^YCURLRequest *(NSTimeInterval requestTimeoutInterval) {
        self.timeoutInterval = requestTimeoutInterval;
        return self;
    };
}

#pragma mark - handler block function
/**
 API完成后的成功回调
 写法：
 .success(^(id obj) {
 dosomething
 })
 */
- (__kindof YCURLRequest *(^)(YCSuccessBlock))success {
    return ^YCURLRequest*(YCSuccessBlock objBlock) {
        self.successHandler = objBlock;
        return self;
    };
}

/**
 API完成后的失败回调
 写法：
 .failure(^(NSError *error) {

 })
 */
- (__kindof YCURLRequest *(^)(YCFailureBlock))failure {

    return ^YCURLRequest* (YCFailureBlock errorBlock) {
        self.failureHandler = errorBlock;
        return self;
    };
}

/**
 API上传、下载等长时间执行的Progress进度
 写法：
 .progress(^(NSProgress *proc){
 NSLog(@"当前进度：%@", proc);
 })
 */
- (__kindof YCURLRequest *(^)(YCProgressBlock))progress {
    return ^YCURLRequest *(YCProgressBlock progressBlock) {
        self.progressHandler = progressBlock;
        return self;
    };
}

/**
 用于Debug的Block
 block内返回YCDebugMessage对象
 */
- (__kindof YCURLRequest *(^)(YCDebugBlock))debug {
    return ^YCURLRequest *(YCDebugBlock debugBlock) {
        self.debugHandler = debugBlock;
        return self;
    };
}

// 开启API 请求
- (__kindof YCURLRequest *)start {
    [YCNetworkManager send:self];
    return self;
}
// 取消API 请求
- (__kindof YCURLRequest *)cancel {
    [YCNetworkManager cancel:self];
    return self;
}
// 继续Task
- (__kindof YCURLRequest *)resume {
    [YCNetworkManager resume:self];
    return self;
}
// 暂停Task
- (__kindof YCURLRequest *)pause {
    [YCNetworkManager pause:self];
    return self;
}

#pragma mark - helper
- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"APIVersion"] = [YCNetworkManager config].request.apiVersion ?: @"未设置";
    dict[@"BaseURL"] = self.baseURL ?: [YCNetworkManager config].request.baseURL;
    dict[@"Path"] = self.path ?: @"未设置";
    dict[@"CustomURL"] = self.customURL ?: @"未设置";
    dict[@"TimeoutInterval"] = [NSString stringWithFormat:@"%f", self.timeoutInterval];
    dict[@"SecurityPolicy"] = [self.securityPolicy toDictionary];
    dict[@"CachePolicy"] = [self getCachePolicy:self.cachePolicy];
    return dict;
}
- (NSString *)hashKey {
    return [NSString stringWithFormat:@"%lu", (unsigned long)[self hash]];
}

- (NSUInteger)hash {
    NSString *hashStr = nil;
    if (self.customURL) {
        hashStr = [NSString stringWithFormat:@"%@",
                   self.customURL];
    } else {
        hashStr = [NSString stringWithFormat:@"%@/%@",
                   self.baseURL,
                   self.path];
    }
    return [hashStr hash];
}
- (BOOL)isEqualToRequest:(YCURLRequest *)request {
    return [self hash] == [request hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[YCURLRequest class]]) return NO;
    return [self isEqualToRequest:(YCURLRequest *) object];
}
- (NSString *)getCachePolicy:(NSURLRequestCachePolicy)policy {
    switch (policy) {
        case NSURLRequestUseProtocolCachePolicy:
            return @"NSURLRequestUseProtocolCachePolicy";
            break;
        case NSURLRequestReloadIgnoringLocalCacheData:
            return @"NSURLRequestReloadIgnoringLocalCacheData";
            break;
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return @"NSURLRequestReloadIgnoringLocalAndRemoteCacheData";
            break;
        case NSURLRequestReturnCacheDataElseLoad:
            return @"NSURLRequestReturnCacheDataElseLoad";
            break;
        case NSURLRequestReturnCacheDataDontLoad:
            return @"NSURLRequestReturnCacheDataDontLoad";
            break;
        case NSURLRequestReloadRevalidatingCacheData:
            return @"NSURLRequestReloadRevalidatingCacheData";
            break;
        default:
            return @"NULL";
            break;
    }
}

@end
