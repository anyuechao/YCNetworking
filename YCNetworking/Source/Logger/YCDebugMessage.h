//
//  YCDebugMessage.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YCURLResponse.h"
#import "NSNull+ToDictionary.h"

typedef NSString *YCDebugKey;

@interface YCDebugMessage : NSObject
// 请求对象，YCAPI或YCTask
@property (nonatomic,strong,readonly)id requestObject;
// 获取NSURLSessionTask
@property (nonatomic,strong,readonly)NSURLSessionTask *sessionTask;
// 获取RequestObject
@property (nonatomic,strong,readonly)YCURLResponse *response;
// 执行的队列名
@property (nonatomic,copy,readonly)NSString *queueName;
// 生成时间
@property (nonatomic,copy,readonly)NSString *timeString;

- (instancetype)initWithRequest:(id)requestObject andResult:(id)resultObject andError:(NSError *)error andQueueName:(NSString *)queueName;

- (NSDictionary *)toDictionary;
@end

