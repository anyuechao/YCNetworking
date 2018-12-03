//
//  YCPresenter.m
//  YCRequest
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCPresenter.h"

@implementation YCPresenter

/**
 初始化函数
 */
- (instancetype)initWithView:(id)view{

    if (self = [super init]) {
        _view = view;
    }
    return self;
}
/**
 * 绑定视图
 * @param view 要绑定的视图
 */
- (void) attachView:(id)view {
    _view = view;
}


/**
 解绑视图
 */
- (void)detachView{
    _view = nil;
}
@end
