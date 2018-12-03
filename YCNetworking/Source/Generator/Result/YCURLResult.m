//
//  YCURLResult.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCURLResult.h"

@interface YCURLResult ()
@property (nonatomic, strong, readwrite) id resultObject;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, assign, readwrite) YCURLResultStatus status;
@end

@implementation YCURLResult

- (instancetype)initWithObject:(id)resultObject andError:(NSError *)error {
    self = [super init];
    if (self) {
        _resultObject = resultObject;
        _error = error;
        _status = [self resultStatusWithError:error];
    }
    return self;
}

- (YCURLResultStatus)resultStatusWithError:(NSError *)error {
    if (error){
        YCURLResultStatus result = YCURLResultStatusErrorNotReachable;
                // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut){
            result = YCURLResultStatusErrorTimeout;
        }
        return result;
    } else {
        return YCURLResultStatusSuccess;
    }
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"\n---------YCURLResult Start---------\n"];
    [desc appendFormat:@"Status : %@\n", [self getYCURLResultStatusString:self.status]];
    [desc appendFormat:@"Object : %@\n", self.resultObject];
    [desc appendFormat:@"Error : %@\n", self.error ?: @"成功"];
    [desc appendString:@"----------YCURLResult End----------"];
    return desc;
}

- (NSString *)debugDescription {
    return self.description;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"Status"] = [self getYCURLResultStatusString:self.status];
    dict[@"Object"] = [NSString stringWithFormat:@"%@", [self.resultObject class]];
    dict[@"Error"] = self.error.localizedDescription ?: @"无错误";
    return dict;
}

- (NSString *)getYCURLResultStatusString:(YCURLResultStatus)status {
    switch (status) {
        case YCURLResultStatusSuccess:
            return @"YCURLResultStatusSuccess";
            break;
        case YCURLResultStatusErrorTimeout:
            return @"YCURLResultStatusErrorTimeout";
            break;
        case YCURLResultStatusErrorNotReachable:
            return @"YCURLResultStatusErrorNotReachable";
            break;
        default:
            return @"YCURLResultStatusErrorUnknown";
            break;
    }
}

@end
