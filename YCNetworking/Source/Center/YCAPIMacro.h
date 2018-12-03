//
//  YCAPIMacro.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#ifndef YCAPIMacro_h
#define YCAPIMacro_h

#import <objc/runtime.h>

#define metamacro_concat(A, B) \
metamacro_concat_(A, B)
#define metamacro_concat_(A, B) A ## B

#define YCStrongProperty(name) \
@property (nonatomic, strong, setter=set__nonuse__##name:, getter=__nonuse__##name) YCAPIRequest *name; \
+ (YCAPIRequest *)name;

#define YCStrongSynthesize(name, api) \
static void *name##AssociatedKey = #name "associated"; \
- (void)set__nonuse__##name:(YCAPIRequest *)name { \
objc_setAssociatedObject(self, name##AssociatedKey, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
} \
\
- (YCAPIRequest *)__nonuse__##name { \
id _##name = objc_getAssociatedObject(self, name##AssociatedKey); \
if (!_##name) { \
_##name = api; \
} \
return _##name; \
} \
+ (YCAPIRequest *)name { \
return [[self defaultCenter] __nonuse__##name];\
}

#endif /* YCAPIMacro_h */
