//
//  YCTaskRequest.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCTaskRequest.h"
#import "YCTaskRequest_InternalParams.h"
#import "YCNetworkManager.h"
#import "YCNetworkConfig.h"
#import "YCSecurityPolicyConfig.h"
#import "YCURLRequest_InternalParams.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation YCTaskRequest
#pragma mark - initialize method
- (instancetype)init {
    self = [super init];
    if (self) {
        _requestTaskType = Download;
        NSString *baseResumePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"com.ayc.YCNetworking/downloadDict"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:baseResumePath isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:baseResumePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _resumePath = [baseResumePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.arc", (unsigned long)self.hash]];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    YCTaskRequest *request = [super copyWithZone:zone];
    if (request) {
        request.filePath = [_filePath copyWithZone:zone];
        request.resumePath = [_resumePath copyWithZone:zone];
        request.requestTaskType = _requestTaskType;
    }
    return request;
}

#pragma mark - parameters append method
// 设置下载或者上传的本地文件路径
- (YCTaskRequest *(^)(NSString *filePath))setFilePath {
    return ^YCTaskRequest* (NSString *filePath) {
        self.filePath = filePath;
        return self;
    };
}
// 设置task的类型（上传/下载）
- (YCTaskRequest *(^)(YCRequestTaskType requestTaskType))setTaskType {
    return ^YCTaskRequest* (YCRequestTaskType requestTaskType) {
        self.requestTaskType = requestTaskType;
        return self;
    };
}

#pragma mark - helper
- (NSUInteger)hash {
    NSString *hashStr;
    if (self.customURL) {
        hashStr = self.customURL;
    } else {
        hashStr = [NSString stringWithFormat:@"%@/%@", self.baseURL, self.path];
    }
    return [hashStr hash];
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString string];
#if DEBUG
    [desc appendString:@"\n===============YCTask Start===============\n"];
    [desc appendFormat:@"Class: %@\n", self.class];
    [desc appendFormat:@"BaseURL: %@\n", self.baseURL ?: [YCNetworkManager config].request.baseURL];
    [desc appendFormat:@"Path: %@\n", self.path ?: @"未设置"];
    [desc appendFormat:@"CustomURL: %@\n", self.customURL ?: @"未设置"];
    [desc appendFormat:@"ResumePath: %@", self.resumePath];
    [desc appendFormat:@"CachePath: %@", self.filePath];
    [desc appendFormat:@"TimeoutInterval: %f\n", self.timeoutInterval];
    [desc appendFormat:@"SecurityPolicy: %@\n", self.securityPolicy];
    [desc appendFormat:@"RequestTaskType: %@\n", [self getRequestTaskTypeString:self.requestTaskType]];
    [desc appendFormat:@"CachePolicy: %@\n", [self getCachePolicyString:self.cachePolicy]];
    [desc appendString:@"===============End===============\n"];
#else
    desc = [NSMutableString stringWithFormat:@""];
#endif
    return desc;
}

- (NSString *)getRequestTaskTypeString:(YCRequestTaskType)type {
    switch (type) {
        case Download:
            return @"Download";
            break;
        case Upload:
            return @"Upload";
            break;
        default:
            return @"Download";
            break;
    }
}

- (NSString *)getCachePolicyString:(NSURLRequestCachePolicy)policy {
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
            return @"NSURLRequestUseProtocolCachePolicy";
            break;
    }
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"APIVersion"] = [YCNetworkManager config].request.apiVersion ?: @"未设置";
    dict[@"BaseURL"] = self.baseURL ?: [YCNetworkManager config].request.baseURL;
    dict[@"Path"] = self.path ?: @"未设置";
    dict[@"CustomURL"] = self.customURL ?: @"未设置";
    dict[@"ResumePath"] = self.resumePath ?: @"未设置";
    dict[@"TimeoutInterval"] = [NSString stringWithFormat:@"%f", self.timeoutInterval];
    dict[@"SecurityPolicy"] = [self.securityPolicy toDictionary];
    dict[@"RequestMethodType"] = [self getRequestTaskTypeString:self.requestTaskType];
    dict[@"CachePolicy"] = [self getCachePolicyString:self.cachePolicy];
    return dict;
}
@end

#pragma clang diagnostic pop
