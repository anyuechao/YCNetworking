//
//  YCBaseObjReformer.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCBaseObjReformer.h"
#import <YYModel/YYModel.h>

@implementation YCBaseObjReformer
- (id)reformerObject:(id)responseObject andError:(NSError *)error atRequest:(YCAPIRequest *)api {
    if (api.objClz && ![NSStringFromClass(api.objClz) isEqualToString:@"NSObject"]) {
        if (responseObject) {
            return [api.objClz yy_modelWithJSON:responseObject];
        }
    }
#if DEBUG
    NSLog(@"该对象无法转换，api = %@", api);
#endif
    if (responseObject) {
        return responseObject;
    }
    return nil;
}
@end
