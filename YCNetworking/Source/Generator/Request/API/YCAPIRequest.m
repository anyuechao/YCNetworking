//
//  YCAPIRequest.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCAPIRequest_InternalParams.h"
#import "YCURLRequest_InternalParams.h"
#import "YCNetworkManager.h"
#import "YCNetworkConfig.h"
#import "YCSecurityPolicyConfig.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation YCAPIRequest
#pragma mark - initialize method
- (instancetype)init {
    self = [super init];
    if (self) {
        _useDefaultParams = YES;
        _objClz = [NSObject class];
        _accpetContentTypes = nil;
        _header = [YCNetworkManager config].request.defaultHeaders;
        _parameters = nil;
        _requestMethodType = GET;
        _requestSerializerType = RequestHTTP;
        _responseSerializerType = ResponseJSON;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    YCAPIRequest *request = [super copyWithZone:zone];
    if (request) {
        request.useDefaultParams = _useDefaultParams;
        request.objClz = _objClz;
        request.accpetContentTypes = [_accpetContentTypes copyWithZone:zone];
        request.header = [_header copyWithZone:zone];
        request.parameters = [_parameters copyWithZone:zone];
        request.requestMethodType = _requestMethodType;
        request.requestSerializerType = _requestSerializerType;
        request.responseSerializerType = _responseSerializerType;
        request.objReformerDelegate = _objReformerDelegate;
    }
    return request;
}

/**
 进行JSON -> Model 数据的转换工作的Delegate
 如果设置了ReformerDelegate，则使用ReformerDelegate的obj解析，否则直接返回
 提供该Delegate主要用于Reformer的不相关代码的解耦工作

 param responseObject 请求回调对象
 param error          错误信息

 @return 请求结果数据
 */
- (YCAPIRequest *(^)(id<YCReformerDelegate> _Nullable delegate))setObjReformerDelegate {
    return ^YCAPIRequest* (id<YCReformerDelegate> delegate) {
        self.objReformerDelegate = delegate;
        return self;
    };
}
// HTTP 请求的返回可接受的内容类型，默认为nil，该参数会覆盖YCResponseSerializerType
- (YCAPIRequest *(^)(NSSet * _Nullable contentTypes))setAccpetContentTypes {
    return ^YCAPIRequest* (NSSet *contentTypes) {
        self.accpetContentTypes = contentTypes;
        return self;
    };
}
// 是否使用APIManager.config的默认参数，默认为YES
- (YCAPIRequest *(^)(BOOL enable))enableDefaultParams {
    return ^YCAPIRequest* (BOOL enable) {
        self.useDefaultParams = enable;
        return self;
    };
}
// 设置YCAPI对应的返回值模型类型
- (YCAPIRequest *(^)(NSString *clzName))setResponseClass{
    return ^YCAPIRequest* (NSString *clzName) {
        Class clz = NSClassFromString(clzName);
        if (clz) {
            self.objClz = clz;
        } else {
            self.objClz = nil;
        }
        return self;
    };
}
// 请求方法 GET POST等
- (YCAPIRequest *(^)(YCRequestMethodType requestMethodType))setMethod{
    return ^YCAPIRequest* (YCRequestMethodType requestMethodType) {
        self.requestMethodType = requestMethodType;
        return self;
    };
}
// Request 序列化类型：JSON, HTTP, 见YCRequestSerializerType
- (YCAPIRequest *(^)(YCRequestSerializerType requestSerializerType))setRequestType{
    return ^YCAPIRequest* (YCRequestSerializerType requestSerializerType) {
        self.requestSerializerType = requestSerializerType;
        return self;
    };
}
// Response 序列化类型： JSON, HTTP
- (YCAPIRequest *(^)(YCResponseSerializerType responseSerializerType))setResponseType{
    return ^YCAPIRequest* (YCResponseSerializerType responseSerializerType) {
        self.responseSerializerType = responseSerializerType;
        return self;
    };
}
// 请求中的参数，每次设置都会覆盖之前的内容
- (YCAPIRequest *(^)(NSDictionary<NSString *, id> * _Nullable parameters))setParams{
    return ^YCAPIRequest* (NSDictionary<NSString *, id> *parameters) {
        self.parameters = parameters;
        return self;
    };
}
// 请求中的参数，每次设置都是添加新参数，不会覆盖之前的内容
- (YCAPIRequest *(^)(NSDictionary<NSString *, id> * _Nullable parameters))addParams {
    return ^YCAPIRequest* (NSDictionary<NSString *, id> *parameters) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.parameters];
        [dict addEntriesFromDictionary:parameters];
        self.parameters = [dict copy];
        return self;
    };
}
// HTTP 请求的头部区域自定义，默认为nil
- (YCAPIRequest *(^)(NSDictionary<NSString *, NSString *> * _Nullable header))setHeader{
    return ^YCAPIRequest* (NSDictionary<NSString *, NSString *> *header) {
        self.header = header;
        return self;
    };
}


#pragma mark - process
//// 开启API 请求
//- (YCAPIRequest *)start {
//    return self;
//}
//// 取消API 请求
//- (YCAPIRequest *)cancel {
//    return self;
//}

#pragma mark - handler block function
/**
 用于组织POST体的formData
 */
- (YCAPIRequest *(^)(YCRequestConstructingBodyBlock))formData{
    return ^YCAPIRequest* (YCRequestConstructingBodyBlock bodyBlock) {
        self.requestConstructingBodyBlock = bodyBlock;
        return self;
    };
}

#pragma mark - helper
- (NSUInteger)hash {
    NSString *hashStr = nil;
    if (self.customURL) {
        hashStr = [NSString stringWithFormat:@"%@%@?%@?%lu",
                   self.header,
                   self.customURL,
                   self.parameters,
                   (unsigned long)self.requestMethodType];
    } else {
        hashStr = [NSString stringWithFormat:@"%@%@/%@?%@?%lu",
                   self.header,
                   self.baseURL,
                   self.path,
                   self.parameters,
                   (unsigned long)self.requestMethodType];
    }
    return [hashStr hash];
}
// 拼接打印信息
- (NSString *)description {
    NSMutableString *desc = [NSMutableString string];
#if DEBUG
    [desc appendString:@"\n===============YCAPI Start===============\n"];
    [desc appendFormat:@"APIVersion: %@\n", [YCNetworkManager config].request.apiVersion ?: @"未设置"];
    [desc appendFormat:@"Class: %@\n", self.objClz];
    [desc appendFormat:@"BaseURL: %@\n", self.baseURL ?: [YCNetworkManager config].request.baseURL];
    [desc appendFormat:@"Path: %@\n", self.path ?: @"未设置"];
    [desc appendFormat:@"CustomURL: %@\n", self.customURL ?: @"未设置"];
    [desc appendFormat:@"Parameters: %@\n", self.parameters ?: @"未设置"];
    [desc appendFormat:@"Header: %@\n", self.header ?: @"未设置"];
    [desc appendFormat:@"ContentTypes: %@\n", self.accpetContentTypes];
    [desc appendFormat:@"TimeoutInterval: %f\n", self.timeoutInterval];
    [desc appendFormat:@"SecurityPolicy: %@\n", self.securityPolicy];
    [desc appendFormat:@"RequestMethodType: %@\n", [self getRequestMethodString:self.requestMethodType]];
    [desc appendFormat:@"RequestSerializerType: %@\n", [self getRequestSerializerTypeString: self.requestSerializerType]];
    [desc appendFormat:@"ResponseSerializerType: %@\n", [self getResponseSerializerTypeString: self.responseSerializerType]];
    [desc appendFormat:@"CachePolicy: %@\n", [self getCachePolicy:self.cachePolicy]];
    [desc appendString:@"=================YCAPI End================\n"];
#else
    desc = [NSMutableString stringWithFormat:@""];
#endif
    return desc;
}
- (NSString *)debugDescription {
    return self.description;
}
- (NSString *)getCachePolicy:(NSURLRequestCachePolicy)policy {
    switch (policy) {
        case NSURLRequestUseProtocolCachePolicy:
            return @"NSURLRequestUseProtocolCachePolicy";
            break;
        case NSURLRequestReloadIgnoringLocalCacheData:
            return @"NSURLRequestReloadIgnoringLocalCacheData";
            break;
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return @"NSURLRequestReloadIgnoringLocalAndRemoteCacheData";
            break;
        case NSURLRequestReturnCacheDataElseLoad:
            return @"NSURLRequestReturnCacheDataElseLoad";
            break;
        case NSURLRequestReturnCacheDataDontLoad:
            return @"NSURLRequestReturnCacheDataDontLoad";
            break;
        case NSURLRequestReloadRevalidatingCacheData:
            return @"NSURLRequestReloadRevalidatingCacheData";
            break;
        default:
            return @"NULL";
            break;
    }
}
- (NSString *)getRequestMethodString:(YCRequestMethodType)method {
    switch (method) {
        case GET:
            return @"GET";
            break;
        case POST:
            return @"POST";
            break;
        case HEAD:
            return @"HEAD";
            break;
        case PUT:
            return @"PUT";
            break;
        case PATCH:
            return @"PATCH";
            break;
        case DELETE:
            return @"PATCH";
            break;
        default:
            return @"NULL";
            break;
    }
}
- (NSString *)getRequestSerializerTypeString:(YCRequestSerializerType)type {
    switch (type) {
        case RequestJSON:
            return @"RequestJSON";
            break;
        case RequestPlist:
            return @"RequestPlist";
            break;
        case RequestHTTP:
            return @"RequestHTTP";
            break;
        default:
            return @"NULL";
            break;
    }
}
- (NSString *)getResponseSerializerTypeString:(YCResponseSerializerType)type {
    switch (type) {
        case ResponseXML:
            return @"ResponseXML";
            break;
        case ResponsePlist:
            return @"ResponsePlist";
            break;
        case ResponseHTTP:
            return @"ResponseHTTP";
            break;
        case ResponseJSON:
            return @"ResponseJSON";
            break;
        default:
            return @"NULL";
            break;
    }
}
- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"APIVersion"] = [YCNetworkManager config].request.apiVersion ?: @"未设置";
    dict[@"Class"] = [NSString stringWithFormat:@"%@", self.objClz];
    dict[@"BaseURL"] = self.baseURL ?: [YCNetworkManager config].request.baseURL;
    dict[@"Path"] = self.path ?: @"未设置";
    dict[@"CustomURL"] = self.customURL ?: @"未设置";
    dict[@"Parameters"] = self.parameters ?: @"未设置";
    dict[@"Header"] = self.header ?: @"未设置";
    dict[@"ContentTypes"] = [NSString stringWithFormat:@"%@", self.accpetContentTypes];
    dict[@"TimeoutInterval"] = [NSString stringWithFormat:@"%f", self.timeoutInterval];
    dict[@"SecurityPolicy"] = [self.securityPolicy toDictionary];
    dict[@"RequestMethodType"] = [self getRequestMethodString:self.requestMethodType];
    dict[@"RequestSerializerType"] = [self getRequestSerializerTypeString: self.requestSerializerType];
    dict[@"ResponseSerializerType"] = [self getResponseSerializerTypeString: self.responseSerializerType];
    dict[@"CachePolicy"] = [self getCachePolicy:self.cachePolicy];
    return dict;
}

//#pragma mark - 重写父类方法，用于转换类型
//// 设置YCAPI的requestDelegate
//- (YCAPIRequest *(^)(id<YCURLRequestDelegate> delegate))setDelegate;
//// 设置YCAPI的requestDelegate
//- (YCAPIRequest *(^)(NSString *baseURL))setBaseURL;
//// urlQuery，baseURL后的地址
//- (YCAPIRequest *(^)(NSString *_Nullable path))setPath;
//// 自定义的RequestUrl，该参数会无视任何baseURL的设置，优先级最高
//- (YCAPIRequest *(^)(NSString *customURL))setCustomURL;
//// HTTPS 请求的Security策略
//- (YCAPIRequest *(^)(YCSecurityPolicyConfig *securityPolicy))setSecurityPolicy;
//// HTTP 请求的Cache策略
//- (YCAPIRequest *(^)(NSURLRequestCachePolicy requestCachePolicy))setCachePolicy;
//// HTTP 请求超时的时间，默认为15秒
//- (YCAPIRequest *(^)(NSTimeInterval requestTimeoutInterval))setTimeout;
//
///**
// API完成后的成功回调
// 写法：
// .success(^(id obj) {
// dosomething
// })
// */
//- (YCAPIRequest *(^)(YCSuccessBlock))success;
//
///**
// API完成后的失败回调
// 写法：
// .failure(^(NSError *error) {
//
// })
// */
//- (YCAPIRequest *(^)(YCFailureBlock))failure;
//
///**
// API上传、下载等长时间执行的Progress进度
// 写法：
// .progress(^(NSProgress *proc){
// NSLog(@"当前进度：%@", proc);
// })
// */
//
//- (YCAPIRequest *(^)(YCProgressBlock))progress;
//
///**
// 用于Debug的Block
// block内返回YCDebugMessage对象
// */
//- (YCAPIRequest *(^)(YCDebugBlock))debug;
@end
