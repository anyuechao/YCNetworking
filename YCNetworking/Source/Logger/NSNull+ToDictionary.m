//
//  NSNull+ToDictionary.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "NSNull+ToDictionary.h"

@implementation NSNull(ToDictionary)
- (NSDictionary *)toDictionary {
    return @{@"NSNull": @"null"};
}
@end
