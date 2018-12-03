//
//  YCDebugMessage.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCDebugMessage.h"
#import "YCNetworkEngine.h"

YCDebugKey const kYCSessionTaskDebugKey = @"kYCSessionTaskDebugKey";
YCDebugKey const kYCRequestDebugKey = @"kYCRequestDebugKey";
YCDebugKey const kYCResponseDebugKey = @"kYCResponseDebugKey";
YCDebugKey const kYCQueueDebugKey = @"kYCQueueDebugKey";

@interface YCDebugMessage ()
// 获取NSURLSessionTask
@property (nonatomic, strong, readwrite)NSURLSessionTask *sessionTask;
// 获取YCAPI
@property (nonatomic, strong, readwrite)id requestObject;
// 获取NSURLResponse
@property (nonatomic, strong, readwrite)YCURLResponse *response;
// 执行的队列名
@property (nonatomic, copy, readwrite)NSString *queueName;
// 生成时间
@property (nonatomic, copy, readwrite) NSString *timeString;
@end

@implementation YCDebugMessage

- (instancetype)initWithRequest:(id)requestObject andResult:(id)resultObject andError:(NSError *)error andQueueName:(NSString *)queueName {
    self = [super init];
    if (self) {
        NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
        [myFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _timeString = [myFormatter stringFromDate:[NSDate date]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
        NSString *hashKey = [requestObject performSelector:@selector(hashKey)];
#pragma clang diagnostic pop
        id sessionTask = [[YCNetworkEngine sharedEngine] requestByIdentifier: hashKey];
        id request = [NSNull null];
        id requestId = [NSNull null];

        if ([requestObject isKindOfClass:[NSURLSessionTask class]]) {
            request = [sessionTask currentRequest];
        }
        if ([requestObject hash]) {
            requestId = [NSNumber numberWithUnsignedInteger:[requestObject hash]];
        }
        // 生成response对象
        YCURLResult *result = [[YCURLResult alloc] initWithObject:resultObject andError:error];
        YCURLResponse *response = [[YCURLResponse alloc] initWithResult:result
                                                              requestId:requestId
                                                                request:request];
        _sessionTask = sessionTask;
        _requestObject = request;
        _response = response;
        _queueName = queueName;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary <NSString *, id>*dictionary = [NSMutableDictionary dictionary];
    dictionary[@"Time"] = self.timeString;
    dictionary[@"RequestObject"] = [self.requestObject toDictionary];
    dictionary[@"Response"] = [self.response toDictionary];
    dictionary[@"SessionTask"] = [self.sessionTask description];
    dictionary[@"Queue"] = self.queueName;
    return dictionary;
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"\n****************Debug Message Start****************\n"];
    [desc appendFormat:@"Time : %@\n", self.timeString];
    [desc appendFormat:@"RequestObject : %@\n", self.requestObject ?: @"无参数"];
    [desc appendFormat:@"SessionTask : %@\n", self.sessionTask ?: @"无参数"];
    [desc appendFormat:@"Response : %@\n", self.response ?: @"无参数"];
    [desc appendFormat:@"Queue : %@", self.queueName ?: @"无参数"];
    [desc appendString:@"\n****************Debug Message End****************\n"];
    return desc;
}

- (NSString *)debugDescription {
    return self.description;
}
@end
