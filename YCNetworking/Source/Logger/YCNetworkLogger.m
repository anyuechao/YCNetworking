//
//  YCNetworkLogger.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCNetworkLogger.h"
#import "YCNetworkMacro.h"
#import "UIDevice+deviceInfo.h"

// 创建任务队列
static dispatch_queue_t ayc_log_queue() {
    static dispatch_queue_t ayc_log_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ayc_log_queue =
        dispatch_queue_create("com.ayc.networking.anyuechao.log.queue", DISPATCH_QUEUE_SERIAL);
    });
    return ayc_log_queue;
}

@interface YCNetworkLogger()
@property (nonatomic, strong, readwrite) YCNetworkLoggerConfig *config;

@property (nonatomic, weak, nullable) id<YCNetworkCustomLoggerDelegate> delegate;

@property (nonatomic, assign) BOOL enable;

@property (nonatomic, strong) NSMutableArray <NSDictionary *>*debugInfoArray;
@end

@implementation YCNetworkLogger

#pragma mark - logger
- (id<YCNetworkCustomLoggerDelegate>)currentDelegate {
    return [self delegate];
}

- (void)logInfoWithDebugMessage:(YCDebugMessage *)debugMessage {
#if DEBUG
    NSLog(@"%@", debugMessage);
#endif
}

- (NSArray <NSString *>*)logFilePaths {
    NSString *dirPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"com.ayc.YCNetworking/log"];
    NSArray <NSString *>*fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    NSMutableArray <NSString *>*tmpArray = [NSMutableArray array];
    for (NSString *fileName in fileList) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", dirPath, fileName];
        [tmpArray addObject:path];
    }
    return [tmpArray copy];
}

- (void)writeToFile {
    dispatch_async(ayc_log_queue(), ^{
        if (self.config.enableLocalLog) {
            BOOL succeed = NO;
            if (self.config.loggerType == YCNetworkLoggerTypeJSON) {
                NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:self.config.logFilePath append:YES];
                [outputStream open];
                succeed = [NSJSONSerialization writeJSONObject:self.debugInfoArray toStream:outputStream options:NSJSONWritingPrettyPrinted error:nil];
                [outputStream close];
            } else {
                succeed = [self.debugInfoArray writeToFile:self.config.logFilePath atomically:YES];
            }
            if (succeed) {
                [self.debugInfoArray removeAllObjects];
            }
        }
    });
}

- (void)addLogInfoWithDictionary:(NSDictionary *)dictionary {
    dispatch_async(ayc_log_queue(), ^{
        if (self.config.enableLocalLog) {
            if (self.debugInfoArray.count > self.config.logAutoSaveCount) {
                [self writeToFile];
            }
            if (dictionary.count > 0) {
                [self.debugInfoArray addObject:dictionary];
            }
        }
    });
}

- (void)startLogging {
    self.enable = YES;
}

- (void)stopLogging {
    self.enable = NO;
}

#pragma mark - setupConfig
- (void)setupConfig:(void (^)(YCNetworkLoggerConfig * _Nonnull))configBlock {
    YC_SAFE_BLOCK(configBlock, self.config);
}

#pragma mark - init
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static YCNetworkLogger *shared;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _config = [YCNetworkLoggerConfig config];
        _enable = NO;
        _debugInfoArray = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray<NSDictionary *> *)debugInfoArray {
    if (_debugInfoArray.count == 0) {
        NSDictionary *infoHeader;
        if ([self.delegate respondsToSelector:@selector(customHeaderWithMessage:)]) {
            infoHeader = [self.delegate customHeaderWithMessage:self.config];
        } else {
            infoHeader = @{@"AppInfo": @{@"OSVersion": [UIDevice currentDevice].systemVersion,
                                         @"DeviceType": [UIDevice currentDevice].yc_machineType,
                                         @"UDID": [UIDevice currentDevice].yc_udid,
                                         @"UUID": [UIDevice currentDevice].yc_uuid,
                                         @"MacAddressMD5": [UIDevice currentDevice].yc_macaddressMD5,
                                         @"ChannelID": _config.channelID,
                                         @"AppKey": _config.appKey,
                                         @"AppName": _config.appName,
                                         @"AppVersion": _config.appVersion,
                                         @"ServiceType": _config.serviceType}};
        }
        [_debugInfoArray addObject:infoHeader];
    }
    return _debugInfoArray;
}

#pragma mark - static method
+ (id<YCNetworkCustomLoggerDelegate>)currentDelegate {
    return [[self shared] currentDelegate];
}

+ (void)setDelegate:(id<YCNetworkCustomLoggerDelegate>)delegate {
    [[self shared] setDelegate:delegate];
}

+ (NSArray <NSString *>*)logFilePaths {
    return [[self shared] logFilePaths];
}

+ (void)setupConfig:(void (^)(YCNetworkLoggerConfig * _Nonnull))configBlock {
    [[self shared] setupConfig:configBlock];
}

+ (BOOL)isEnable {
    return [[self shared] enable];
}

+ (void)logInfoWithDebugMessage:(YCDebugMessage *)debugMessage {
    [[self shared] logInfoWithDebugMessage:debugMessage];
}

+ (void)writeToFile {
    [[self shared] writeToFile];
}

+ (void)addLogInfoWithDictionary:(NSDictionary *)dictionary {
    [[self shared] addLogInfoWithDictionary:dictionary];
}

+ (void)startLogging {
    [[self shared] startLogging];
}

+ (void)stopLogging {
    [[self shared] stopLogging];
}


@end
