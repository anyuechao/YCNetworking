//
//  UIDevice+deviceInfo.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice(deviceInfo)
//通用唯一识别码
- (NSString *) yc_uuid;
//设备唯一标识
- (NSString *) yc_udid;
//局域网地址
- (NSString *) yc_macaddress;
//局域网地址md5加密
- (NSString *) yc_macaddressMD5;
//设备类型
- (NSString *) yc_machineType;
@end
