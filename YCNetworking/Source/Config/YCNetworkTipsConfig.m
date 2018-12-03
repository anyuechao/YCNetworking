//
//  YCNetworkTipsConfig.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCNetworkTipsConfig.h"

NSString * const YCDefaultGeneralErrorString            = @"服务器连接错误，请稍候重试";
NSString * const YCDefaultFrequentRequestErrorString    = @"请求发送速度太快, 请稍候重试";
NSString * const YCDefaultNetworkNotReachableString     = @"网络不可用，请稍后重试";

@implementation YCNetworkTipsConfig

+ (YCNetworkTipsConfig *)config {
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _generalErrorTypeStr = YCDefaultGeneralErrorString;
        _frequentRequestErrorStr = YCDefaultFrequentRequestErrorString;
        _networkNotReachableErrorStr = YCDefaultNetworkNotReachableString;
        _isNetworkingActivityIndicatorEnabled = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    YCNetworkTipsConfig *config = [[[self class] alloc] init];
    if (config) {
        config.generalErrorTypeStr = [_generalErrorTypeStr copyWithZone:zone];
        config.frequentRequestErrorStr = [_frequentRequestErrorStr copyWithZone:zone];
        config.networkNotReachableErrorStr = [_networkNotReachableErrorStr copyWithZone:zone];
        config.isNetworkingActivityIndicatorEnabled = _isNetworkingActivityIndicatorEnabled;
    }
    return config;
}
@end
