//
//  YCURLRequest_InternalParams.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCURLRequest.h"
NS_ASSUME_NONNULL_BEGIN
@interface YCURLRequest()
@property (nonatomic,weak, nullable)id<YCURLRequestDelegate> delegate;
@property (nonatomic,copy)NSString *cURL;
@property (nonatomic,copy)NSString *baseURL;
@property (nonatomic,copy)NSString *path;
@property (nonatomic, assign)NSTimeInterval timeoutInterval;
@property (nonatomic, assign)NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, strong)YCSecurityPolicyConfig *securityPolicy;

@property (nonatomic, copy, nullable) YCSuccessBlock successHandler;
@property (nonatomic, copy, nullable) YCFailureBlock failureHandler;
@property (nonatomic, copy, nullable) YCProgressBlock progressHandler;
@property (nonatomic, copy, nullable) YCDebugBlock debugHandler;

@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, strong, nullable) dispatch_queue_t queue;
@end

NS_ASSUME_NONNULL_END
