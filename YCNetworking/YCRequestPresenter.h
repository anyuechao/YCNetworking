//
//  YCRequestPresenter.h
//  YCRequest
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCRequestPresenter<E>: YCPresenter<E>

@property (nonatomic,copy)void(^handleAction)(void);

- (void)logError:(NSString *)msg;
- (void)logInfo:(NSString *)msg;
- (void)logMessage:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
