//
//  YCNetworkConst.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#ifndef YCNetworkConst_h
#define YCNetworkConst_h

@protocol YCMultipartFormDataProtocol;
@class YCDebugMessage;

// 网络请求类型
typedef NS_ENUM(NSUInteger, YCRequestTaskType) {
    Upload = 16,
    Download = 17
};

// 网络请求类型
typedef NS_ENUM(NSUInteger, YCRequestMethodType) {
    GET = 10,
    POST = 11,
    HEAD = 12,
    PUT = 13,
    PATCH = 14,
    DELETE = 15
};

// 请求的序列化格式
typedef NS_ENUM(NSUInteger, YCRequestSerializerType) {
    // Content-Type = application/x-www-form-urlencoded
    RequestHTTP = 100,
    // Content-Type = application/json
    RequestJSON = 101,
    // Content-Type = application/x-plist
    RequestPlist = 102
};

// 请求返回的序列化格式
typedef NS_ENUM(NSUInteger, YCResponseSerializerType) {
    // 默认的Response序列化方式（不处理）
    ResponseHTTP = 200,
    // 使用NSJSONSerialization解析Response Data
    ResponseJSON = 201,
    // 使用NSPropertyListSerialization解析Response Data
    ResponsePlist = 202,
    // 使用NSXMLParser解析Response Data
    ResponseXML = 203
};

// reachability的状态
typedef NS_ENUM(NSUInteger, YCReachabilityStatus) {
    YCReachabilityStatusUnknown,
    YCReachabilityStatusNotReachable,
    YCReachabilityStatusReachableViaWWAN,
    YCReachabilityStatusReachableViaWiFi
};

// 定义的Block
// 请求结果回调
typedef void(^YCSuccessBlock)(id __nullable responseObj);
// 请求失败回调
typedef void(^YCFailureBlock)(NSError * __nullable error);
// 请求进度回调
typedef void(^YCProgressBlock)(NSProgress * __nullable progress);
// formData拼接回调
typedef void(^YCRequestConstructingBodyBlock)(id<YCMultipartFormDataProtocol> __nullable formData);
// debug回调
typedef void(^YCDebugBlock)(YCDebugMessage * __nonnull debugMessage);
// reachability回调
typedef void(^YCReachabilityBlock)(YCReachabilityStatus status);
// 桥接回调
typedef void(^YCCallbackBlock)(id __nonnull request, id __nullable responseObject, NSError * __nullable error);

#endif /* YCNetworkConst_h */
