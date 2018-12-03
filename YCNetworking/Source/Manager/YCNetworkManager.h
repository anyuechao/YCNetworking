//
//  YCNetworkManager.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YCNetworkConst.h"
NS_ASSUME_NONNULL_BEGIN

@class YCNetworkConfig;
@class YCURLRequest;
@class YCRequestGroup;
@protocol YCNetworkResponseDelegate;

// 判断当前是否为审核版本
FOUNDATION_EXPORT inline BOOL YCJudgeVersion(void);
// 设置是否为审核版本
FOUNDATION_EXPORT inline void YCJudgeVersionSwitch(BOOL isR);

@interface YCNetworkManager : NSObject

#pragma mark - property
@property (nonatomic, strong, readonly) YCNetworkConfig *config;

+ (YCNetworkConfig *)config;

#pragma mark - initialize method
// 请使用manager或sharedManager
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
// 返回一个新的manager对象
+ (instancetype)manager;
// 返回单例
+ (instancetype)sharedManager;

// 配置设置
+ (void)setupConfig:(void(^)(YCNetworkConfig *config))configBlock;
- (void)setupConfig:(void(^)(YCNetworkConfig *config))configBlock;

#pragma mark - process
// 发送API请求，默认为manager内置队列
+ (void)send:(__kindof YCURLRequest *)request;
- (void)send:(__kindof YCURLRequest *)request;
// 发送一组请求
+ (void)sendGroup:(YCRequestGroup *)group;
- (void)sendGroup:(YCRequestGroup *)group;
// 取消API请求，如果该请求已经发送或者正在发送，则不保证一定可以取消，但会将Block回落点置空，delegate正常回调，默认为manager内置队列
+ (void)cancel:(__kindof YCURLRequest *)request;
- (void)cancel:(__kindof YCURLRequest *)request;
// 取消API请求，如果该请求已经发送或者正在发送，则不保证一定可以取消，但会将Block回落点置空，delegate正常回调，默认为manager内置队列
+ (void)cancelGroup:(YCRequestGroup *)group;
- (void)cancelGroup:(YCRequestGroup *)group;
// 恢复Task
+ (void)resume:(__kindof YCURLRequest *)request;
- (void)resume:(__kindof YCURLRequest *)request;
// 暂停Task
+ (void)pause:(__kindof YCURLRequest *)request;
- (void)pause:(__kindof YCURLRequest *)request;
// 注册网络请求监听者
+ (void)registerResponseObserver:(id<YCNetworkResponseDelegate>)observer;
- (void)registerResponseObserver:(id<YCNetworkResponseDelegate>)observer;
// 删除网络请求监听者
+ (void)removeResponseObserver:(id<YCNetworkResponseDelegate>)observer;
- (void)removeResponseObserver:(id<YCNetworkResponseDelegate>)observer;


#pragma mark - reachability相关
// 当前reachability状态
@property (nonatomic, assign, readonly) YCReachabilityStatus reachabilityStatus;
// 当前是否可访问网络
@property (nonatomic, assign, readonly, getter = isReachable) BOOL reachable;
// 当前是否使用数据流量访问网络
@property (nonatomic, assign, readonly, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
// 当前是否使用WiFi访问网络
@property (nonatomic, assign, readonly, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

// 通过sharedMager单例，获取当前reachability状态
+ (YCReachabilityStatus)reachabilityStatus;
// 通过sharedMager单例，获取当前是否可访问网络
+ (BOOL)isReachable;
// 通过sharedMager单例，获取当前是否使用数据流量访问网络
+ (BOOL)isReachableViaWWAN;
// 通过sharedMager单例，获取当前是否使用WiFi访问网络
+ (BOOL)isReachableViaWiFi;

// 开启默认reachability监视器，block返回状态
+ (void)listening:(YCReachabilityBlock)listener;
// 默认reachability监视器停止监听
+ (void)stopListening;

// 监听给定的域名是否可以访问，block内返回状态
- (void)listeningWithDomain:(NSString *)domain listeningBlock:(YCReachabilityBlock)listener;
// 停止给定域名的网络状态监听
- (void)stopListeningWithDomain:(NSString *)domain;
@end

#pragma mark - manager监听代理
@protocol YCNetworkResponseDelegate <NSObject>
// 快速设置需要监听的task对象
#define YCObserverRequests(...) \
- (NSArray <__kindof YCURLRequest *>* _Nonnull)observerRequests { \
return [NSArray arrayWithObjects:__VA_ARGS__, nil]; \
}
@required
// 设置需要监听的task对象
- (NSArray <__kindof YCURLRequest *>*)observerRequests;

@optional
// task 上传、下载等长时间执行的Progress进度
- (void)requestProgress:(nullable NSProgress *)progress atRequest:(nullable __kindof YCURLRequest *)request;
// 请求成功的回调
- (void)requestSucess:(nullable id)responseObject atRequest:(nullable __kindof YCURLRequest *)request;
// 请求失败的回调
- (void)requestFailure:(nullable NSError *)error atRequest:(nullable __kindof YCURLRequest *)request;
@end


NS_ASSUME_NONNULL_END
