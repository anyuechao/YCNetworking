//
//  YCNetworkConfig.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCNetworkConfig.h"

inline void dispatch_async_main(dispatch_queue_t queue, dispatch_block_t block) {
    if (queue) {
        dispatch_async(queue, block);
    } else {
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), block);
        } else {
            block();
        }
    }
}

@implementation YCNetworkConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _tips = [YCNetworkTipsConfig config];
        _request = [YCNetworkRequestConfig config];
        _policy = [YCNetworkPolicyConfig config];
        _enableReachability = NO;
        _enableGlobalLog = NO;
        _defaultSecurityPolicy = [YCSecurityPolicyConfig policyWithPinningMode:YCSSLPinningModeNone];
    }
    return self;
}

+ (YCNetworkConfig *)config {
    return [[self alloc] init];
}

- (id)copyWithZone:(NSZone *)zone {
    YCNetworkConfig *config = [[[self class] alloc] init];
    if (config) {
        config.tips = [_tips copyWithZone:zone];
        config.request = [_request copyWithZone:zone];
        config.policy = [_policy copyWithZone:zone];
        config.defaultSecurityPolicy = [_defaultSecurityPolicy copyWithZone:zone];
        config.enableReachability = _enableReachability;
        config.defaultSecurityPolicy = _defaultSecurityPolicy;
    }
    return config;
}
@end
