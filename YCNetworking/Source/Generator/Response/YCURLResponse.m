//
//  YCURLResponse.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCURLResponse.h"

@interface YCURLResponse()

@property (nonatomic,strong,readwrite)YCURLResult *result;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSUInteger requestId;
@end

@implementation YCURLResponse

#pragma mark - life cycle
- (instancetype)initWithResult:(YCURLResult *)result
                     requestId:(NSNumber *)requestId
                       request:(NSURLRequest *)request {
    if (self = [super init]) {
        _result = result;
        _requestId = requestId;
        _request = request;
    }
    return self;
}

#pragma mark - private methods
- (NSString *)description {
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"\n++++++++YCURLResponse Start++++++++\n"];
    [desc appendFormat:@"Result : %@\n", self.result];
    [desc appendFormat:@"Request : %@\n", self.request];
    [desc appendFormat:@"RequestId : %lu\n", (unsigned long)self.requestId];
    [desc appendString:@"+++++++++YCURLResponse End+++++++++\n"];
    return desc;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"Result"] = [self.result toDictionary];
    dict[@"Request"] = self.request.description;
    dict[@"RequestId"] = [NSString stringWithFormat:@"%lu", (unsigned long)self.requestId];
    return dict;
}

- (NSString *)debugDescription {
    return self.description;
}
@end
