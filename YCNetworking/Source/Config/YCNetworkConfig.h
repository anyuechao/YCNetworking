//
//  YCNetworkConfig.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YCSecurityPolicyConfig.h"
#import "YCNetworkTipsConfig.h"
#import "YCNetworkRequestConfig.h"
#import "YCNetworkPolicyConfig.h"

NS_ASSUME_NONNULL_BEGIN

DISPATCH_EXPORT void dispatch_async_main(dispatch_queue_t queue, dispatch_block_t block);

@interface YCNetworkConfig : NSObject<NSCopying>
// 提示相关参数
@property (nonatomic, strong) YCNetworkTipsConfig *tips;
// 请求相关参数
@property (nonatomic, strong) YCNetworkRequestConfig *request;
// 网络策略相关参数
@property (nonatomic, strong) YCNetworkPolicyConfig *policy;
// 安全策略相关参数
@property (nonatomic, strong) YCSecurityPolicyConfig *defaultSecurityPolicy;
// 是否启用reachability，baseURL为domain
@property (nonatomic, assign) BOOL enableReachability;
// 是否开启网络debug日志，该选项会在控制台输出所有网络回调日志，并且在Release模式下无效
@property (nonatomic, assign) BOOL enableGlobalLog;

// 快速构建config
+ (YCNetworkConfig *)config;

// 请使用config
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


@end

NS_ASSUME_NONNULL_END
