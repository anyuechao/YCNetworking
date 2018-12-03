//
//  YCNetworkPolicyConfig.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCNetworkPolicyConfig.h"

@implementation YCNetworkPolicyConfig

+ (YCNetworkPolicyConfig *)config {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isBackgroundSession = NO;
        _isErrorCodeDisplayEnabled = YES;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _URLCache = [NSURLCache sharedURLCache];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    YCNetworkPolicyConfig *config = [[[self class] alloc] init];
    if (config) {
        config.isErrorCodeDisplayEnabled = _isErrorCodeDisplayEnabled;
        config.isBackgroundSession = _isBackgroundSession;
        config.AppGroup = [_AppGroup copyWithZone:zone];
    }
    return config;
}
@end
