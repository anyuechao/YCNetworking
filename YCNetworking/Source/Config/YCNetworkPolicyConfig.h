//
//  YCNetworkPolicyConfig.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCNetworkPolicyConfig : NSObject <NSCopying>

// 是否为后台模式所用的GroupID，该选项只对Task有影响
@property (nonatomic, copy) NSString *AppGroup;

// 是否为后台模式，该选项只对Task有影响
@property (nonatomic, assign) BOOL isBackgroundSession;

// 出现网络请求错误时，是否在请求错误的文字后加上{code}，默认为YES
@property (nonatomic, assign) BOOL isErrorCodeDisplayEnabled;

// 请求缓存策略，默认为NSURLRequestUseProtocolCachePolicy
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

// URLCache设置
@property (nonatomic, assign) NSURLCache *URLCache;

// 快速构建config
+ (YCNetworkPolicyConfig *)config;

// 请使用config
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
