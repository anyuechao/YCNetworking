//
//  YCTaskRequest_InternalParams.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCTaskRequest.h"

@interface YCTaskRequest ()
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *resumePath;
@property (nonatomic, assign)YCRequestTaskType requestTaskType;
@end
