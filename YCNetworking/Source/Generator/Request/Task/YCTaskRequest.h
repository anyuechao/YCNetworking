//
//  YCTaskRequest.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCURLRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCTaskRequest : YCURLRequest

#pragma mark- property
@property (nonatomic,copy,readonly)NSString *filePath;
@property (nonatomic,copy,readonly)NSString *resumePath;

#pragma mark- parameters append method
// 设置下载或者上传的本地文件路径
- (YCTaskRequest *(^)(NSString *filePath))setFilePath;
// 设置task的类型（上传/下载）
- (YCTaskRequest *(^)(YCRequestTaskType requestTaskType))setTaskType;

#pragma mark- process
//开启API请求
- (YCTaskRequest *)start;
//取消API请求
- (YCTaskRequest *)cancel;
//继续API请求
- (YCTaskRequest *)resume;
//暂停API请求
- (YCTaskRequest *)pause;

#pragma mark - 重写父类方法，用于转换类型
// 设置YCAPI的requestDelegate
- (YCTaskRequest * _Nonnull (^)(id<YCURLRequestDelegate> _Nullable))setDelegate;
// 设置API的baseURL，该参数会覆盖config中的baseURL
- (YCTaskRequest * _Nonnull (^)(NSString * _Nonnull))setBaseURL;
// urlQuery，baseURL后的地址
- (YCTaskRequest * _Nonnull (^)(NSString * _Nullable))setPath;
// 自定义的RequestUrl，该参数会无视任何baseURL的设置，优先级最高
- (YCTaskRequest * _Nonnull (^)(NSString * _Nonnull))setCustomURL;
// HTTPS 请求的Security策略
- (YCTaskRequest * _Nonnull (^)(YCSecurityPolicyConfig * _Nonnull))setSecurityPolicy;
// HTTP 请求的Cache策略
- (YCTaskRequest * _Nonnull (^)(NSURLRequestCachePolicy))setCachePolicy;
// HTTP 请求超时的时间，默认为15秒
- (YCURLRequest * _Nonnull (^)(NSTimeInterval))setTimeout;

/**
 API完成后的成功回调
 写法：
 .success(^(id obj) {
 dosomething
 })
 */
- (YCTaskRequest * _Nonnull (^)(YCSuccessBlock _Nonnull))success;

/**
 API完成后的失败回调
 写法：
 .failure(^(NSError *error) {

 })
 */
- (YCTaskRequest * _Nonnull (^)(YCFailureBlock _Nonnull))failure;

/**
 API上传、下载等长时间执行的Progress进度
 写法：
 .progress(^(NSProgress *proc){
 NSLog(@"当前进度：%@", proc);
 })
 */
- (YCTaskRequest * _Nonnull (^)(YCProgressBlock _Nonnull))progress;

/**
 用于Debug的Block
 block内返回YCDebugMessage对象
 */
- (YCTaskRequest * _Nonnull (^)(YCDebugBlock _Nonnull))debug;

@end

NS_ASSUME_NONNULL_END
