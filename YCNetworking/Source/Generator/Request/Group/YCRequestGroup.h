//
//  YCRequestGroup.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YCURLRequest;
@class YCRequestGroup;

typedef NS_ENUM(NSUInteger, YCRequestGroupMode) {
    YCRequestGroupModeBatch,
    YCRequestGroupModeChain,
};

NS_ASSUME_NONNULL_BEGIN

@protocol YCRequestGroupDelegate <NSObject>
// Requests 全部调用完成之后调用
- (void)requestGroupAllDidFinished:(nonnull YCRequestGroup *)apiGroup;

@end

@interface YCRequestGroup : NSObject
// 请求组类型
@property (nonatomic,assign,readonly)YCRequestGroupMode groupMode;

@property (nonatomic,assign)NSUInteger maxRequestCount;

// 自定义的同步请求所在的串行队列
@property (nonatomic,strong,readonly)dispatch_queue_t customQueue;

// Group 内 api 执行完成之后调用的delegate
@property (nonatomic,weak, nullable)id<YCRequestGroupDelegate> delegate;

// 请使用manager或sharedManager
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

// 返回一个新的manager对象
+ (instancetype)groupWithMode:(YCRequestGroupMode)mode;

// 加入到group集合中
- (void)add:(nonnull __kindof YCURLRequest *)request;

// 将带有API集合的Array 赋值
- (void)addRequests:(nonnull NSArray<__kindof YCURLRequest *> *)requests;

// 开启队列请求
- (void)start;

// 取消所有请求
- (void)cancel;

// 设置组GCD队列
- (dispatch_queue_t)setupGroupQueue:(NSString *)queueName;

#pragma mark - 遍历方法

@property (readonly) NSUInteger count;

- (void)enumerateObjectsUsingBlock:(void (^)(__kindof YCURLRequest *request, NSUInteger idx, BOOL * stop))block;

- (nonnull NSEnumerator*)objectEnumerator;

- (nonnull id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END
