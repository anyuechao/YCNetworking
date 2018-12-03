//
//  YCSecurityPolicyConfig.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>

// SSL Pinning
typedef NS_ENUM(NSUInteger, YCSSLPinningMode) {
    // 不校验Pinning证书
    YCSSLPinningModeNone,
    // 校验Pinning证书中的PublicKey
    YCSSLPinningModePublicKey,
    // 校验整个Pinning证书
    YCSSLPinningModeCertificate
};

@interface YCSecurityPolicyConfig : NSObject<NSCopying>
// SSL Pinning证书的校验模式，默认为 YCSSLPinningModeNone
@property (nonatomic,readonly,assign)YCSSLPinningMode SSLPinningMode;
// 是否允许使用Invalid 证书，默认为 NO
@property (nonatomic,assign)BOOL allowInvalidCertificates;
// 是否校验在证书 CN 字段中的 domain name，默认为 YES
@property (nonatomic,assign)BOOL validatesDomainName;
// cer证书文件路径
@property (nonatomic, copy) NSString *cerFilePath;

/**
 创建新的SecurityPolicy

 @param pinningMode 证书校验模式
 @return 新的SecurityPolicy
 */
+ (instancetype)policyWithPinningMode:(YCSSLPinningMode)pinningMode;

- (NSDictionary *)toDictionary;
@end
