//
//  YCNetworkManager.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCNetworkManager.h"
#import "YCNetworkEngine.h"
#import "YCNetWorkConfig.h"
#import "YCNetWorkMacro.h"
#import "YCNetWorkLogger.h"
#import "YCDebugMessage.h"
#import "YCURLRequest_InternalParams.h"
#import "YCRequestGroup.h"
#import "YCTaskRequest.h"
#import "YCAPIRequest_InternalParams.h"


inline BOOL YCJudgeVersion(void) { return [[NSUserDefaults standardUserDefaults] boolForKey:@"isR"]; }

inline void YCJudgeVersionSwitch(BOOL isR) { [[NSUserDefaults standardUserDefaults] setBool:isR forKey:@"isR"]; }

// 创建任务队列
static dispatch_queue_t ayc_network_request_queue() {
    static dispatch_queue_t ayc_network_request_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ayc_network_request_queue =
        dispatch_queue_create("com.ayc.anyuechao.networking.callback.queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    });
    return ayc_network_request_queue;
}

// 创建上传下载任务队列
static dispatch_queue_t ayc_network_task_queue() {
    static dispatch_queue_t ayc_network_task_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ayc_network_task_queue =
        dispatch_queue_create("com.ayc.anyuechao.networking.task.queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    });
    return ayc_network_task_queue;
}

@interface YCNetworkManager() {
    dispatch_semaphore_t _lock;
}
@property (nonatomic, strong, readwrite) YCNetworkConfig *config;
@property (nonatomic, strong) NSHashTable<id <YCNetworkResponseDelegate>> *responseObservers;

@property (nonatomic, assign, readwrite) YCReachabilityStatus reachabilityStatus;
@property (nonatomic, assign, readwrite, getter = isReachable) BOOL reachable;
@property (nonatomic, assign, readwrite, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
@property (nonatomic, assign, readwrite, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

@end

@implementation YCNetworkManager
+ (YCNetworkConfig *)config {
    return [[self sharedManager] config];
}
#pragma mark - initialize method
+ (instancetype)manager {
    return [[self alloc] init];
}
+ (instancetype)sharedManager {
    static YCNetworkManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
        _config = [YCNetworkConfig config];
        _reachabilityStatus = YCReachabilityStatusUnknown;
        _responseObservers = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    return self;
}
- (void)setupConfig:(void (^)(YCNetworkConfig * _Nonnull config))configBlock {
    YC_SAFE_BLOCK(configBlock, self.config);
}
+ (void)setupConfig:(void (^)(YCNetworkConfig * _Nonnull config))configBlock {
    [[self sharedManager] setupConfig:configBlock];
}

#pragma mark - process
// 发送API请求，默认为manager内置队列
- (void)send:(__kindof YCURLRequest *)request {
    @yc_weakify(self);
    if (!request.queue) {
        if ([request isKindOfClass:[YCTaskRequest class]]) {
            request.queue = ayc_network_task_queue();
        } else {
            request.queue = ayc_network_request_queue();
        }
    }
    dispatch_async(request.queue, ^{
        @yc_strongify(self);
        [self send:request atSemaphore:nil atGroup:nil];
    });
}
+ (void)send:(__kindof YCURLRequest *)request {
    [[self sharedManager] send:request];
}
// 发送一组请求，使用信号量做同步请求，使用group做完成通知
- (void)sendGroup:(YCRequestGroup *)group {
    if (!group) return;
    dispatch_queue_t queue;
    if (group.customQueue) {
        queue = group.customQueue;
    } else {
        if ([group[0] isKindOfClass:[YCTaskRequest class]]) {
            queue = ayc_network_task_queue();
        } else {
            queue = ayc_network_request_queue();
        }
    }
    // 根据groupMode 配置信号量
    dispatch_semaphore_t semaphore = nil;
    if (group.groupMode == YCRequestGroupModeChain) {
        semaphore = dispatch_semaphore_create(group.maxRequestCount);
    }
    dispatch_group_t api_group = dispatch_group_create();
    @yc_weakify(self);
    dispatch_async(queue, ^{
        [group enumerateObjectsUsingBlock:^(YCURLRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
            @yc_strongify(self);
            request.queue = queue;
            if (group.groupMode == YCRequestGroupModeChain) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            dispatch_group_enter(api_group);
            [self send:request atSemaphore:semaphore atGroup:api_group];
        }];
        dispatch_group_notify(api_group, dispatch_get_main_queue(), ^{
            if (group.delegate) {
                [group.delegate requestGroupAllDidFinished:group];
            }
        });
    });
}
+ (void)sendGroup:(YCRequestGroup *)group {
    [[self sharedManager] sendGroup:group];
}
// 取消API请求，如果该请求已经发送或者正在发送，则不保证一定可以取消，但会将Block回落点置空，delegate正常回调，默认为manager内置队列
- (void)cancel:(__kindof YCURLRequest *)request {
    if (!request.queue) {
        if ([request isKindOfClass:[YCTaskRequest class]]) {
            request.queue = ayc_network_task_queue();
        } else {
            request.queue = ayc_network_request_queue();
        }
    }
    dispatch_async(request.queue, ^{
        [[YCNetworkEngine sharedEngine] cancelRequestByIdentifier:request.hashKey];
    });
}
+ (void)cancel:(__kindof YCURLRequest *)request {
    [[self sharedManager] cancel:request];
}
// 取消API请求，如果该请求已经发送或者正在发送，则不保证一定可以取消，但会将Block回落点置空，delegate正常回调，默认为manager内置队列
- (void)cancelGroup:(YCRequestGroup *)group {
    NSAssert(group.count != 0, @"APIGroup元素不可小于1");
    [group enumerateObjectsUsingBlock:^(__kindof YCURLRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancel:request];
    }];
}
+ (void)cancelGroup:(YCRequestGroup *)group {
    [[self sharedManager] cancelGroup:group];
}
// 恢复Task
- (void)resume:(__kindof YCURLRequest *)request {
    @yc_weakify(self);
    if (!request.queue) {
        if ([request isKindOfClass:[YCTaskRequest class]]) {
            request.queue = ayc_network_task_queue();
        } else {
            request.queue = ayc_network_request_queue();
        }
    }
    dispatch_async(request.queue, ^{
        @yc_strongify(self);
        NSURLSessionTask *sessionTask = [[YCNetworkEngine sharedEngine] requestByIdentifier:request.hashKey];
        if (sessionTask) {
            [sessionTask resume];
        } else {
            [self send:request];
        }
    });
}
+ (void)resume:(__kindof YCURLRequest *)request {
    [[self sharedManager] resume:request];
}
// 暂停Task
- (void)pause:(__kindof YCURLRequest *)request {
    if (!request.queue) {
        if ([request isKindOfClass:[YCTaskRequest class]]) {
            request.queue = ayc_network_task_queue();
        } else {
            request.queue = ayc_network_request_queue();
        }
    }
    dispatch_async(request.queue, ^{
        NSURLSessionTask *sessionTask = [[YCNetworkEngine sharedEngine] requestByIdentifier:request.hashKey];
        if (sessionTask) {
            [sessionTask suspend];
        }
    });
}
+ (void)pause:(__kindof YCURLRequest *)request {
    [[self sharedManager] pause:request];
}
// 注册网络请求监听者
- (void)registerResponseObserver:(id<YCNetworkResponseDelegate>)observer {
    YCLock();
    [self.responseObservers addObject:observer];
    YCUnlock();
}
+ (void)registerResponseObserver:(id<YCNetworkResponseDelegate>)observer {
    [[self sharedManager] registerResponseObserver:observer];
}
// 删除网络请求监听者
- (void)removeResponseObserver:(id<YCNetworkResponseDelegate>)observer {
    YCLock();
    if ([self.responseObservers containsObject:observer]) {
        [self.responseObservers removeObject:observer];
    }
    YCUnlock();
}
+ (void)removeResponseObserver:(id<YCNetworkResponseDelegate>)observer {
    [[self sharedManager] removeResponseObserver:observer];
}

#pragma mark - reachability
- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.reachabilityStatus == YCReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.reachabilityStatus == YCReachabilityStatusReachableViaWiFi;
}

+ (YCReachabilityStatus)reachabilityStatus {
    return [[self sharedManager] reachabilityStatus];
}

+ (BOOL)isReachable {
    return [[self sharedManager] isReachable];
}

+ (BOOL)isReachableViaWWAN {
    return [[self sharedManager] isReachableViaWWAN];
}

+ (BOOL)isReachableViaWiFi {
    return [[self sharedManager] isReachableViaWiFi];
}

+ (void)listening:(YCReachabilityBlock)listener {
    [[self sharedManager] listeningWithDomain:[[self sharedManager] config].request.baseURL listeningBlock:listener];
}

+ (void)stopListening {
    [[self sharedManager] stopListeningWithDomain:[[self sharedManager] config].request.baseURL];
}

- (void)listeningWithDomain:(NSString *)domain listeningBlock:(YCReachabilityBlock)listener {
    if (self.config.enableReachability) {
        @yc_weakify(self)
        [[YCNetworkEngine sharedEngine] listeningWithDomain:domain listeningBlock:^(YCReachabilityStatus status) {
            @yc_strongify(self)
            self.reachabilityStatus = status;
            listener(status);
        }];
    }
}

- (void)stopListeningWithDomain:(NSString *)domain {
    [[YCNetworkEngine sharedEngine] stopListeningWithDomain:domain];
}

#pragma mark - private method
- (void)send:(YCURLRequest *)request
 atSemaphore:(dispatch_semaphore_t)semaphore
     atGroup:(dispatch_group_t)group {
    // 对api.delegate 发送即将请求api的消息
    if ([request.delegate respondsToSelector:@selector(requestWillBeSent:)]) {
        dispatch_async_main(self.config.request.callbackQueue, ^{
            [request.delegate requestWillBeSent:request];
        });
    }

    if (self.config.tips.isNetworkingActivityIndicatorEnabled) {
        dispatch_async_main(self.config.request.callbackQueue, ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
    }

    // 定义进度block
    @yc_weakify(self)
    void (^progressBlock)(NSProgress *proc) = ^(NSProgress *proc) {
        if (proc.totalUnitCount <= 0) return;
        dispatch_async_main(self.config.request.callbackQueue, ^{
            for (id<YCNetworkResponseDelegate> obj in self.responseObservers) {
                if ([[obj observerRequests] containsObject:request]) {
                    if ([obj respondsToSelector:@selector(requestProgress:atRequest:)]) {
                        [obj requestProgress:proc atRequest:request];
                    }
                }
            }
        });
    };
    // 定义回调block
    void (^callBackBlock)(YCURLRequest *request, id responseObject, NSError *error)
    = ^(YCURLRequest *request, id responseObject, NSError *error) {
        @yc_strongify(self)
        if (self.config.tips.isNetworkingActivityIndicatorEnabled) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        [self callbackWithRequest:request
                  andResultObject:responseObject
                         andError:error
                         andGroup:group
                     andSemaphore:semaphore];
    };

    [[YCNetworkEngine sharedEngine] sendRequest:request
                                      andConfig:self.config
                                   progressBack:progressBlock
                                       callBack:callBackBlock];

    // 对api.delegate 发送已经请求api的消息
    if ([request.delegate respondsToSelector:@selector(requestDidSent:)]) {
        dispatch_async_main(self.config.request.callbackQueue, ^{
            [request.delegate requestDidSent:request];
        });
    }
}


/**
 Task完成的回调方法

 @param request 调用的request
 @param resultObject 返回的对象
 @param error 返回的错误
 @param group 调用的组
 @param semaphore 调用的信号量
 */
- (void)callbackWithRequest:(YCURLRequest *)request
            andResultObject:(id)resultObject
                   andError:(NSError *)error
                   andGroup:(dispatch_group_t)group
               andSemaphore:(dispatch_semaphore_t)semaphore {
    // 处理回调的block
    NSError *netError = error;
    if (netError) {
        // 网络状态不好时自动重试
        if (request.retryCount > 0) {
            request.retryCount --;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self send:request atSemaphore:semaphore atGroup:group];
            });
            return;
        }
        // 如果不是reachability无法访问host或用户取消错误(NSURLErrorCancelled)，则对错误提示进行处理
        if (![error.domain isEqualToString: NSURLErrorDomain] &&
            error.code != NSURLErrorCancelled) {
            // 使用KVC修改error内部属性
            // 默认使用self.config.generalErrorTypeStr = "服务器连接错误，请稍候重试"
            NSMutableDictionary *tmpUserInfo = [[NSMutableDictionary alloc]initWithDictionary:error.userInfo copyItems:NO];
            if (![[tmpUserInfo allKeys] containsObject:NSLocalizedFailureReasonErrorKey]) {
                tmpUserInfo[NSLocalizedFailureReasonErrorKey] = NSLocalizedString(self.config.tips.generalErrorTypeStr, nil);
            }
            if (![[tmpUserInfo allKeys] containsObject:NSLocalizedRecoverySuggestionErrorKey]) {
                tmpUserInfo[NSLocalizedRecoverySuggestionErrorKey] = NSLocalizedString(self.config.tips.generalErrorTypeStr, nil);
            }
            // 加上 networking error code
            NSString *newErrorDescription = self.config.tips.generalErrorTypeStr;
            if (self.config.policy.isErrorCodeDisplayEnabled) {
                newErrorDescription = [NSString stringWithFormat:@"%@, error code = (%ld)", self.config.tips.generalErrorTypeStr, (long)error.code];
            }
            tmpUserInfo[NSLocalizedDescriptionKey] = NSLocalizedString(newErrorDescription, nil);
            NSDictionary *userInfo = [tmpUserInfo copy];
            netError = [NSError errorWithDomain:error.domain
                                           code:error.code
                                       userInfo:userInfo];
        }
    }

    if ([request isKindOfClass:[YCAPIRequest class]]) {
        YCAPIRequest *tmpRequest = (YCAPIRequest *)request;
        if (tmpRequest.objReformerDelegate) {
            resultObject = [tmpRequest.objReformerDelegate reformerObject:resultObject andError:netError atRequest:tmpRequest];
        }
    }

    // 设置Debug及log信息
    YCDebugMessage *msg = [[YCDebugMessage alloc] initWithRequest:request
                                                        andResult:resultObject
                                                         andError:netError
                                                     andQueueName:[NSString stringWithFormat:@"%@", [request isKindOfClass:[YCTaskRequest class]] ? ayc_network_task_queue() : ayc_network_request_queue()]];
#if DEBUG
    if (self.config.enableGlobalLog) {
        [YCNetworkLogger logInfoWithDebugMessage:msg];
    }
    if (request.debugHandler) {
        request.debugHandler(msg);
        request.debugHandler = nil;
    }
#endif
    if ([YCNetworkLogger isEnable]) {
        NSDictionary *msgDictionary;
        if ([YCNetworkLogger currentDelegate]) {
            msgDictionary = [[YCNetworkLogger currentDelegate] customInfoWithMessage:msg];
        } else {
            msgDictionary = [msg toDictionary];
        }
        [YCNetworkLogger addLogInfoWithDictionary:msgDictionary];
    }

    if (netError) {
        if ([request failureHandler]) {
            dispatch_async_main(self.config.request.callbackQueue, ^{
                request.failureHandler(netError);
                request.failureHandler = nil;
            });
        }
    } else {
        if ([request successHandler]) {
            dispatch_async_main(self.config.request.callbackQueue, ^{
                request.successHandler(resultObject);
                request.successHandler = nil;
            });
        }
    }

    if (request.progressHandler) {
        request.progressHandler = nil;
    }

    // 处理回调的delegate
    for (id<YCNetworkResponseDelegate> observer in self.responseObservers) {
        if ([[observer observerRequests] containsObject:request]) {
            if (netError) {
                if ([observer respondsToSelector:@selector(requestFailure:atRequest:)]) {
                    dispatch_async_main(self.config.request.callbackQueue, ^{
                        [observer requestFailure:netError atRequest:request];
                    });
                }
            } else {
                if ([observer respondsToSelector:@selector(requestSucess:atRequest:)]) {
                    dispatch_async_main(self.config.request.callbackQueue, ^{
                        [observer requestSucess:resultObject atRequest:request];
                    });
                }
            }
        }
    }

    // 完成后离组
    if (group) {
        dispatch_group_leave(group);
    }
    // 完成后信号量加1
    if (semaphore) {
        dispatch_semaphore_signal(semaphore);
    }
}

//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

@end
