//
//  YCAPICenter+home.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCAPICenter+home.h"

#define BASEURL @"http://10.2.0.55:8082/"

#define BASEURL1 [NSString stringWithFormat:@"%@%@",BASEURL,@"api/testget/p3/header"]
//@"http://192.168.1.16:8082/api/testget/p3/header"
//#define BASEURL2 @"http://192.168.1.16:8082/api/testget/p3"
#define BASEURL2 [NSString stringWithFormat:@"%@%@",BASEURL,@"api/testget/p3"]
//#define BASEURL3 @"http://192.168.1.16:8082/api/testpost/p2"
#define BASEURL3 [NSString stringWithFormat:@"%@%@",BASEURL,@"api/testpost/p2"]
//#define BASEURL4 @"http://192.168.1.16:8082/api/testput/p1"
#define BASEURL4 [NSString stringWithFormat:@"%@%@",BASEURL,@"api/testput/p1"]
//#define BASEURL5 @"http://192.168.1.16:8082/api/testpost/p2"
#define BASEURL5 [NSString stringWithFormat:@"%@%@",BASEURL,@"api/testpost/p2"]
//#define BASEURL6 @"http://192.168.1.16:8082/api/testput/p1"
#define BASEURL6 [NSString stringWithFormat:@"%@%@",BASEURL,@"api/testput/p1"]
//#define BASEURL7 @"http://192.168.1.16:8082/api/testget/p3"
#define BASEURL7 [NSString stringWithFormat:@"%@%@",BASEURL,@"api/testget/p3"]
//#define BASEURL @"http://192.168.1.16:8082/api/testget/p3/header?v1=2&v2=10"

@implementation YCAPICenter(home)
YCStrongSynthesize(home, [YCAPIRequest request]
                   .setMethod(GET)
                   .setCustomURL(BASEURL1)
                   .setParams(@{@"v1":@"home",
                                @"v2":@"GET"})
                   .setHeader(@{@"access_token":@"accessTokenaccessToken",
                                @"refresh_token":@"refreshToken"})
                   .setObjReformerDelegate(self.defaultReformer))


YCStrongSynthesize(activity, [YCAPIRequest request]
                   .setMethod(GET)
                   .setCustomURL(BASEURL2)
                   .setParams(@{@"v1":@"activity",
                                @"v2":@"GET"})
                   .setObjReformerDelegate(self.defaultReformer))
YCStrongSynthesize(center, [YCAPIRequest request]
                   .setMethod(POST)
                   .setCustomURL(BASEURL3)
                   .setParams(@{@"v1":@"center",
                                @"v2":@"POST"})
                   .setObjReformerDelegate(self.defaultReformer))
YCStrongSynthesize(room, [YCAPIRequest request]
                   .setMethod(PUT)
                   .setCustomURL(BASEURL4)
                   .setParams(@{@"v1":@"room",
                                @"v2":@"PUT"})
                   .setObjReformerDelegate(self.defaultReformer))
YCStrongSynthesize(live, [YCAPIRequest request]
                   .setMethod(POST)
                   .setCustomURL(BASEURL5)
                   .setParams(@{@"v1":@"live",
                                @"v2":@"POST"})
                   .setObjReformerDelegate(self.defaultReformer))

YCStrongSynthesize(upload, [YCAPIRequest request]
                   .setMethod(POST)
                   .setCustomURL(@"http://192.168.1.16:8082/api/testpost/upload")
                   .setObjReformerDelegate(self.defaultReformer))

//[[YCAPIRequest request].setMethod(GET)
// .setCustomURL(BASEURL)
// .setParams(@{@"v1":@"1.9.11",
//              @"v2":@"1111"})
// .setHeader(@{@"access_token":@"accessTokenaccessToken",
//              @"refresh_token":@"refreshToken"})
// .success(^(id response){
//    typeof(weakSelf) __strong strongSelf = weakSelf;
//    NSString *log = [NSString stringWithFormat:@"请求成功 %@",response];
//    [strongSelf.ycrp logMessage:log];
//})
// .failure(^(NSError *error){
//    typeof(weakSelf) __strong strongSelf = weakSelf;
//    [strongSelf.ycrp logError:error.description];
//}) start];
//static void *homeAssociatedKey =  "homeassociated";
//- (void)set__nonuse__home:(YCAPIRequest *)name { \
//    objc_setAssociatedObject(self, homeAssociatedKey, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
//}
//
//- (YCAPIRequest *)__nonuse__home { \
//    id _home = objc_getAssociatedObject(self, homeAssociatedKey);
//    if (!_home) {
//        YCAPIRequest *api = [YCAPIRequest request]
//        .setMethod(GET)
//        .setCustomURL(@"get")
//        .setObjReformerDelegate(self.defaultReformer);
//        _home = api;
//    }
//    return _home;
//}
//+ (YCAPIRequest *)name {
//    return [[self defaultCenter] __nonuse__home];
//}
@end
