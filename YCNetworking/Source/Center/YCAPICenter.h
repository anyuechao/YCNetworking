//
//  YCAPICenter.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YCBaseObjReformer.h"
#import "YCAPIMacro.h"

@interface YCAPICenter : NSObject
+ (instancetype)defaultCenter;

@property (nonatomic,strong)YCBaseObjReformer *defaultReformer;
@end
