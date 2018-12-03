//
//  YCAPIRequest.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCURLRequest.h"
#import "YCFormDataConfig.h"

@class YCAPIRequest;
NS_ASSUME_NONNULL_BEGIN

#pragma mark- 用于转换回掉结果的代理
@protocol YCReformerDelegate <NSObject>
@required
/**
 一般用来进行JSON -> Model 数据的转换工作。返回的id，如果没有error，则为转换成功后的Model数据。如果有error， 则直接返回传参中的responseObject

 @param request 调用的request
 @param responseObject 请求的返回
 @param error 请求的错误
 @return 整理过后的请求数据
 **/
- (nullable id)reformerObject:(id)responseObject andError:(NSError * _Nullable)error atRequest:(YCAPIRequest *)request;

@end

@interface YCAPIRequest : YCURLRequest
@property (nonatomic,assign,readonly)BOOL useDefaultParams;
@property (nonatomic,strong,readonly)Class objClz;
@property (nonatomic,copy,readonly)NSDictionary<NSString *, NSObject *> *parameters;
@property (nonatomic,copy,readonly)NSDictionary<NSString *, NSString *> *header;
@property (nonatomic,copy,readonly)NSSet *accpetContentTypes;

#pragma mark - parameters append method
/**
 进行JSON -> Model 数据的转换工作的Delegate
 如果设置了ReformerDelegate，则使用ReformerDelegate的obj解析，否则直接返回
 提供该Delegate主要用于Reformer的不相关代码的解耦工作

 param responseObject 请求回调对象
 param error          错误信息

 @return 请求结果数据
 */
- (YCAPIRequest *(^)(id<YCReformerDelegate> _Nullable delegate))setObjReformerDelegate;
// HTTP 请求的返回可接受的内容类型，默认为nil，该参数会覆盖YCResponseSerializerType
- (YCAPIRequest *(^)(NSSet * _Nullable contentTypes))setAccpetContentTypes;
// 是否使用APIManager.config的默认参数，默认为YES
- (YCAPIRequest *(^)(BOOL enable))enableDefaultParams;
// 设置YCAPI对应的返回值模型类型
- (YCAPIRequest *(^)(NSString *clzName))setResponseClass;
// 请求方法 GET POST等
- (YCAPIRequest *(^)(YCRequestMethodType requestMethodType))setMethod;
// Request 序列化类型：JSON, HTTP, 见YCRequestSerializerType
- (YCAPIRequest *(^)(YCRequestSerializerType requestSerializerType))setRequestType;
// Response 序列化类型： JSON, HTTP
- (YCAPIRequest *(^)(YCResponseSerializerType responseSerializerType))setResponseType;
// 请求中的参数，每次设置都会覆盖之前的内容
- (YCAPIRequest *(^)(NSDictionary<NSString *, id> * _Nullable parameters))setParams;
// 请求中的参数，每次设置都是添加新参数，不会覆盖之前的内容
- (YCAPIRequest *(^)(NSDictionary<NSString *, id> * _Nullable parameters))addParams;
// HTTP 请求的头部区域自定义，默认为nil
- (YCAPIRequest *(^)(NSDictionary<NSString *, NSString *> * _Nullable header))setHeader;

#pragma mark - process
// 开启API 请求
- (YCAPIRequest *)start;
// 取消API 请求
- (YCAPIRequest *)cancel;

#pragma mark - handler block function
/**
 用于组织POST体的formData
 */
- (YCAPIRequest *(^)(YCRequestConstructingBodyBlock))formData;

#pragma mark - 重写父类方法，用于转换类型
// 设置YCAPI的requestDelegate
- (YCAPIRequest *(^)(id<YCURLRequestDelegate> delegate))setDelegate;
// 设置YCAPI的requestDelegate
- (YCAPIRequest *(^)(NSString *baseURL))setBaseURL;
// urlQuery，baseURL后的地址
- (YCAPIRequest *(^)(NSString *_Nullable path))setPath;
// 自定义的RequestUrl，该参数会无视任何baseURL的设置，优先级最高
- (YCAPIRequest *(^)(NSString *customURL))setCustomURL;
// HTTPS 请求的Security策略
- (YCAPIRequest *(^)(YCSecurityPolicyConfig *securityPolicy))setSecurityPolicy;
// HTTP 请求的Cache策略
- (YCAPIRequest *(^)(NSURLRequestCachePolicy requestCachePolicy))setCachePolicy;
// HTTP 请求超时的时间，默认为15秒
- (YCAPIRequest *(^)(NSTimeInterval requestTimeoutInterval))setTimeout;

/**
 API完成后的成功回调
 写法：
 .success(^(id obj) {
 dosomething
 })
 */
- (YCAPIRequest *(^)(YCSuccessBlock))success;

/**
 API完成后的失败回调
 写法：
 .failure(^(NSError *error) {

 })
 */
- (YCAPIRequest *(^)(YCFailureBlock))failure;

/**
 API上传、下载等长时间执行的Progress进度
 写法：
 .progress(^(NSProgress *proc){
 NSLog(@"当前进度：%@", proc);
 })
 */

- (YCAPIRequest *(^)(YCProgressBlock))progress;

/**
 用于Debug的Block
 block内返回YCDebugMessage对象
 */
- (YCAPIRequest *(^)(YCDebugBlock))debug;

@end

NS_ASSUME_NONNULL_END
