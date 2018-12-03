//
//  YCURLRequest.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YCNetworkConst.h"

@class YCURLRequest;
@class YCSecurityPolicyConfig;
@protocol YCMultipartFormDataProtocol;
@protocol YCURLRequestDelegate;

NS_ASSUME_NONNULL_BEGIN

@protocol YCURLRequestDelegate <NSObject>
@optional
// 请求将要发出
- (void)requestWillBeSent:(nullable __kindof YCURLRequest *)request;
// 请求已经发出
- (void)requestDidSent:(nullable __kindof YCURLRequest *)request;
@end

@interface YCURLRequest : NSObject <NSCopying>
#pragma mark - property
@property (nonatomic, assign, readonly) NSTimeInterval timeoutInterval;
@property (nonatomic, copy, readonly) NSString *baseURL;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, nullable, getter=customURL, readonly) NSString *cURL;

#pragma mark - initialize method
// 请使用API
+ (instancetype)request;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - parameters append method
// 设置YCAPI的requestDelegate
- (__kindof YCURLRequest *(^)(id<YCURLRequestDelegate> _Nullable delegate))setDelegate;
// 设置API的baseURL，该参数会覆盖config中的baseURL
- (__kindof YCURLRequest *(^) (NSString *baseURL))setBaseURL;
// urlQuery，baseURL后的地址
- (__kindof YCURLRequest *(^) (NSString *_Nullable path))setPath;
// 自定义的RequestUrl，该参数会无视任何baseURL的设置，优先级最高
- (__kindof YCURLRequest *(^) (NSString *customURL))setCustomURL;
// HTTPS 请求的Security策略
- (__kindof YCURLRequest *(^) (YCSecurityPolicyConfig *securityPolicy))setSecurityPolicy;
// HTTP 请求的Cache策略
- (__kindof YCURLRequest *(^) (NSURLRequestCachePolicy requestCachePolicy))setCachePolicy;
// HTTP 请求超时的时间，默认为15秒
- (__kindof YCURLRequest *(^) (NSTimeInterval requestTimeoutInterval))setTimeout;

#pragma mark- process
// 开启API 请求
- (__kindof YCURLRequest *)start;
// 取消API 请求
- (__kindof YCURLRequest *)cancel;
// 继续Task
- (__kindof YCURLRequest *)resume;
// 暂停Task
- (__kindof YCURLRequest *)pause;

#pragma mark- helper
- (NSDictionary *)toDictionary;
- (NSString *)hashKey;

@end

#pragma mark- handle block function
@interface YCURLRequest (Handler)
/**
 API完成后的成功回调
 写法：
 .success(^(id obj) {
 dosomething
 })
 */
- (__kindof YCURLRequest *(^)(YCSuccessBlock))success;

/**
 API完成后的失败回调
 写法：
 .failure(^(NSError *error) {

 })
 */
- (__kindof YCURLRequest *(^)(YCFailureBlock))failure;

/**
 API上传、下载等长时间执行的Progress进度
 写法：
 .progress(^(NSProgress *proc){
 NSLog(@"当前进度：%@", proc);
 })
 */
- (__kindof YCURLRequest *(^)(YCProgressBlock))progress;

/**
 用于Debug的Block
 block内返回YCDebugMessage对象
 */
- (__kindof YCURLRequest *(^)(YCDebugBlock))debug;

@end

NS_ASSUME_NONNULL_END
