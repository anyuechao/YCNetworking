//
//  YCPresenter.h
//  YCRequest
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCPresenter<E>: NSObject{

    //MVP中负责更新的视图
    __weak E _view;
}


/**
 初始化函数

 @param view 要绑定的视图
 */
- (instancetype) initWithView:(E)view;

/**
 * 绑定视图
 * @param view 要绑定的视图
 */
- (void) attachView:(E)view ;

/**
 解绑视图
 */
- (void)detachView;
@end

NS_ASSUME_NONNULL_END
