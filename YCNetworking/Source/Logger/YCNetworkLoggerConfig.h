//
//  YCNetworkLoggerConfig.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class YCDebugMessage;

typedef NS_OPTIONS(NSUInteger, YCNetworkLoggerLevel) {
    YCNetworkLoggerNoneLevel = 0,
    YCNetworkLoggerNetErrorLevel = 1 << 0,
    YCNetworkLoggerRequestLevel = 1 << 1,
    YCNetworkLoggerResponseLevel = 1 << 2,
    YCNetworkLoggerAllLevel = 1 << 3
};

typedef NS_ENUM(NSUInteger, YCNetworkLoggerType) {
    YCNetworkLoggerTypeJSON,
    YCNetworkLoggerTypePlist
};

NS_ASSUME_NONNULL_BEGIN

@interface YCNetworkLoggerConfig : NSObject

// 渠道ID
@property (nonatomic, copy) NSString *channelID;

// app标志
@property (nonatomic, copy) NSString *appKey;

// app名字
@property (nonatomic, copy) NSString *appName;

// app版本
@property (nonatomic, copy) NSString *appVersion;

// 服务名
@property (nonatomic, copy) NSString *serviceType;

// 是否开启本地日志
@property (nonatomic, assign) BOOL enableLocalLog;

// 日志自动保存数，默认为50次保存一次
@property (nonatomic, assign) NSUInteger logAutoSaveCount;

// 日志等级，该选项暂时无效
@property (nonatomic, assign) YCNetworkLoggerLevel loggerLevel;

// 日志保存类型
@property (nonatomic, assign) YCNetworkLoggerType loggerType;

// 日志文件路径
@property (nonatomic, copy, readonly) NSString *logFilePath;

+ (instancetype)config;
@end

NS_ASSUME_NONNULL_END
