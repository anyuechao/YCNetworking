//
//  YCNetworkLoggerConfig.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCNetworkLoggerConfig.h"

@interface YCNetworkLoggerConfig()
// 系统版本
@property (nonatomic, copy, readwrite) NSString *osVersion;

// 设备型号
@property (nonatomic, copy, readwrite) NSString *deviceModel;

// 设备标识
@property (nonatomic, copy, readwrite) NSString *UDID;
@end

@implementation YCNetworkLoggerConfig
+ (instancetype)config {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _channelID = @"";
        _appKey = @"";
        _appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] ?: @"";
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"";
        _serviceType = @"";
        _enableLocalLog = NO;
        _loggerLevel = YCNetworkLoggerNoneLevel;
        _logAutoSaveCount = 50;
        _loggerType = YCNetworkLoggerTypeJSON;
    }
    return self;
}

- (NSString *)logFilePath {
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"com.ayc.YCNetworking/log"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *dateString = [myFormatter stringFromDate:[NSDate date]];
    return [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log", dateString]];
}

@end
