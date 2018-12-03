//
//  YCAPIRequest_InternalParams.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCAPIRequest.h"
NS_ASSUME_NONNULL_BEGIN
@interface YCAPIRequest ()
// readOnly property
@property (nonatomic,strong,nullable)Class objClz;
@property (nonatomic,assign)BOOL useDefaultParams;
@property (nonatomic,weak,nullable)id<YCReformerDelegate> objReformerDelegate;
@property (nonatomic, assign) YCRequestMethodType requestMethodType;
@property (nonatomic, assign) YCRequestSerializerType requestSerializerType;
@property (nonatomic, assign) YCResponseSerializerType responseSerializerType;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSObject *> *parameters;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *header;
@property (nonatomic, copy) NSSet *accpetContentTypes;

@property (nonatomic, copy, nullable) YCRequestConstructingBodyBlock requestConstructingBodyBlock;
@end


NS_ASSUME_NONNULL_END


