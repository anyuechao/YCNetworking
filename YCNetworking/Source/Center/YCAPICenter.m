//
//  YCAPICenter.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCAPICenter.h"

static YCAPICenter *shared = nil;

@implementation YCAPICenter

- (YCBaseObjReformer *)defaultReformer {
    if (!_defaultReformer) {
        _defaultReformer = [[YCBaseObjReformer alloc] init];
    }
    return _defaultReformer;
}

+ (instancetype)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(shared == nil) {
            shared = [[self alloc] init];
        }
    });
    return shared;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(shared == nil)
        {
            shared = [super allocWithZone:zone];
        }
    });
    return shared;
}


- (id)copy {
    return self;
}

- (id)mutableCopy {
    return self;
}
@end
