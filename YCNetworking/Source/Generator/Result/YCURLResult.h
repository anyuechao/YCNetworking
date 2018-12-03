//
//  YCURLResult.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, YCURLResultStatus) {
    YCURLResultStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的CTAPIBaseManager来决定。
    YCURLResultStatusErrorTimeout,
    YCURLResultStatusErrorNotReachable // 默认除了超时以外的错误都是无网络错误。
};

NS_ASSUME_NONNULL_BEGIN

@interface YCURLResult : NSObject
@property (nonatomic, strong, readonly) id resultObject;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, assign, readonly) YCURLResultStatus status;

- (NSDictionary *)toDictionary;

- (instancetype)initWithObject:(id)resultObject andError:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
