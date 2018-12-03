//
//  YCNetworkTipsConfig.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
FOUNDATION_EXPORT NSString * const YCDefaultGeneralErrorString;
FOUNDATION_EXPORT NSString * const YCDefaultFrequentRequestErrorString;
FOUNDATION_EXPORT NSString * const YCDefaultNetworkNotReachableString;

@interface YCNetworkTipsConfig : NSObject<NSCopying>
// 出现网络请求时，为了给用户比较好的用户体验，而使用的错误提示文字,
// 默认为：服务器连接错误，请稍候重试
@property (nonatomic,copy)NSString *generalErrorTypeStr;

// 用户频繁发送同一个请求，使用的错误提示文字
// 默认为：请求发送速度太快, 请稍候重试
@property (nonatomic, copy) NSString *frequentRequestErrorStr;

// 网络请求开始时，会先检测相应网络域名的Reachability，如果不可达，则直接返回该错误文字
// 默认为：网络不可用，请稍后重试
@property (nonatomic, copy) NSString *networkNotReachableErrorStr;

// 网络指示器（状态栏），默认为YES
@property (nonatomic, assign) BOOL isNetworkingActivityIndicatorEnabled;

// 快速构建config
+ (YCNetworkTipsConfig *)config;

// 请使用config
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
