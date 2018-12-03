//
//  YCSecurityPolicyConfig.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCSecurityPolicyConfig.h"

@interface YCSecurityPolicyConfig()
@property (nonatomic,readwrite,assign)YCSSLPinningMode SSLPinningMode;
@end

@implementation YCSecurityPolicyConfig

+ (instancetype)policyWithPinningMode:(YCSSLPinningMode)pinningMode {
    YCSecurityPolicyConfig *securityPolicy = [[YCSecurityPolicyConfig alloc] init];
    if (securityPolicy){
        //教研模式
        securityPolicy.SSLPinningMode = pinningMode;
        //是否允许失效的证书
        securityPolicy.allowInvalidCertificates = NO;
        //是否校验在证书 CN 字段中的 domain name，默认为 YES
        securityPolicy.validatesDomainName = YES;
        securityPolicy.cerFilePath = nil;
    }
    return securityPolicy;
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString string];
#if DEBUG
    [desc appendString:@"\n\n----YCSecurityPolicyConfig Start----\n"];
    [desc appendFormat:@"SSLPinningMode: %@\n", [self getpinningModeString:self.SSLPinningMode]];
    [desc appendFormat:@"AllowInvalidCertificates: %@\n", self.allowInvalidCertificates ? @"YES" : @"NO"];
    [desc appendFormat:@"ValidatesDomainName: %@\n", self.validatesDomainName ? @"YES" : @"NO"];
    [desc appendFormat:@"CerFilePath: %@\n", self.cerFilePath ?: @"未设置"];
    [desc appendString:@"------YCSecurityPolicyConfig End------\n"];
#else
    desc = [NSMutableString stringWithFormat:@""];
#endif
    return desc;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"SSLPinningMode"] = [self getpinningModeString:self.SSLPinningMode];
    dict[@"AllowInvalidCertificates"] = self.allowInvalidCertificates ? @"YES" : @"NO";
    dict[@"ValidatesDomainName"] = self.validatesDomainName ? @"YES" : @"NO";
    dict[@"CerFilePath"] = self.cerFilePath ?: @"未设置";
    return dict;
}

- (NSString *)debugDescription {
    return self.description;
}

- (NSString *)getpinningModeString:(YCSSLPinningMode)mode {

    switch (mode) {
        case YCSSLPinningModeNone:
            return @"YCSSLPinningModeNone";
            break;
        case YCSSLPinningModePublicKey:
            return @"YCSSLPinningModePublicKey";
            break;
        case YCSSLPinningModeCertificate:
            return @"YCSSLPinningModeCertificate";
            break;
        default:
            return @"YCSSLPinningModeNone";
            break;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    YCSecurityPolicyConfig *config = [[[self class] alloc] init];
    if (config) {
        config.SSLPinningMode = _SSLPinningMode;
        config.allowInvalidCertificates = _allowInvalidCertificates;
        config.validatesDomainName = _validatesDomainName;
        config.cerFilePath = [_cerFilePath copyWithZone:zone];
    }
    return config;
}
@end
