//
//  YCRequestGroup.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCRequestGroup.h"
#import "YCURLRequest.h"
#import "YCNetworkManager.h"

#define mix(A, B) A##B
// 创建任务队列
static dispatch_queue_t ayc_api_chain_queue(const char * queueName) {
    static dispatch_queue_t mix(ayc_api_chain_queue_, queueName);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mix(ayc_api_chain_queue_, queueName) =
        dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    });
    return mix(ayc_api_chain_queue_, queueName);
}

@interface YCRequestGroup()
@property (nonatomic,strong,readwrite)NSMutableArray<__kindof YCURLRequest *> *apiArray;
// 自定义的同步请求所在的串行队列
@property (nonatomic,strong,readwrite)dispatch_queue_t customQueue;
@end

@implementation YCRequestGroup

#pragma mark - initialize method
- (instancetype)initWithMode:(YCRequestGroupMode)mode {
    self = [super init];
    if (self) {
        _apiArray = [NSMutableArray array];
        _groupMode = mode;
        _maxRequestCount = 1;
    }
    return self;
}
+ (instancetype)groupWithMode:(YCRequestGroupMode)mode {
    return [[self alloc] initWithMode:mode];
}

#pragma mark - NSFastEnumeration
- (NSUInteger)count {
    return _apiArray.count;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx >= _apiArray.count) {
        [NSException raise:NSRangeException format:@"Index %lu 的区间为 [0, %lu].", (unsigned long)idx, (unsigned long)_apiArray.count];
    }
    return _apiArray[idx];
}

- (void)enumerateObjectsUsingBlock:(void (^)(__kindof YCURLRequest * _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    [_apiArray enumerateObjectsUsingBlock:block];
}

- (NSEnumerator *)objectEnumerator {
    return [_apiArray objectEnumerator];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id  _Nullable __unsafe_unretained [])buffer
                                    count:(NSUInteger)len {
    return [_apiArray countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Add Requests
- (void)add:(__kindof YCURLRequest *)request {
    if (!request) {
        return;
    }
    if ([self.apiArray containsObject:request]) {
#ifdef DEBUG
        NSLog(@"批处理队列中已有相同的API！");
#endif
    }
    [self.apiArray addObject:request];
}

- (void)addRequests:(NSArray<__kindof YCURLRequest *> *)requests {
    if (!requests) return;
    if (requests.count == 0) return;
    [requests enumerateObjectsUsingBlock:^(__kindof YCURLRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self add:obj];
    }];
}

- (void)start {
    if (self.apiArray.count == 0) return;
    [YCNetworkManager sendGroup:self];
}

- (void)cancel {
    if (self.apiArray.count == 0) return;
    [YCNetworkManager cancelGroup:self];
}

- (dispatch_queue_t)setupGroupQueue:(NSString *)queueName {
    self.customQueue = ayc_api_chain_queue([queueName UTF8String]);
    return self.customQueue;
}







@end
