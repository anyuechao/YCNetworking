//
//  YCNetworkEngine.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YCNetworkConst.h"
@class YCNetworkConfig;
@class YCURLRequest;

@interface YCNetworkEngine : NSObject
// 请使用sharedEngine
- (_Nonnull instancetype)init NS_UNAVAILABLE;
+ (_Nonnull instancetype)new NS_UNAVAILABLE;
// 单例
+ (_Nonnull instancetype)sharedEngine;

// 发送请求
// requestObject为YCAPI或者YCTask对象
- (void)sendRequest:(__kindof YCURLRequest * _Nonnull)requestObject
          andConfig:(YCNetworkConfig * _Nonnull)config
       progressBack:(YCProgressBlock _Nullable)progressCallBack
           callBack:(YCCallbackBlock _Nullable)callBack;

//取消请求
- (void)cancelRequestByIdentifier:(NSString * _Nonnull)identifier;

// 如果task不存在则返回NSNull对象
- (__kindof NSURLSessionTask * _Nullable)requestByIdentifier:(NSString * _Nonnull)identifier;

#pragma mark - reachability相关
// 开始监听，domain为需要监听的域名
- (void)listeningWithDomain:(NSString * _Nonnull)domain listeningBlock:(YCReachabilityBlock _Nonnull)listener;
// 停止监听，domain为需要停止的域名
- (void)stopListeningWithDomain:(NSString * _Nonnull)domain;
@end

