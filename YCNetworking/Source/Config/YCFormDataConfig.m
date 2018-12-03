//
//  YCFormDataConfig.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/1.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCFormDataConfig.h"

@implementation YCFormDataConfig

+ (void (^)(id<YCMultipartFormDataProtocol> _Nonnull))configWithData:(NSData *)data
                                                                name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    return ^(id<YCMultipartFormDataProtocol> formData) {
        [formData appendPartWithFileData:data
                                    name:name
                                fileName:fileName
                                mimeType:mimeType];
    };
}

+ (void (^)(id<YCMultipartFormDataProtocol> _Nonnull))configWithImage:(UIImage *)image
                                                                 name:(NSString *)name fileName:(NSString *)fileName quality:(CGFloat)quality {
    return ^(id<YCMultipartFormDataProtocol> formData) {
        NSData *data;
        NSString *mimeType;
        if (UIImagePNGRepresentation(image) == nil) {
            data = UIImageJPEGRepresentation(image, quality);
            mimeType = @"image/jpeg";
        } else {
            data = UIImagePNGRepresentation(image);
            mimeType = @"image/png";
        }
        [formData appendPartWithFileData:data
                                    name:name
                                fileName:fileName
                                mimeType: mimeType];
    };
}

+ (void (^)(id<YCMultipartFormDataProtocol>))configWithFileURL:(NSURL *)fileURL
                                                          name:(NSString *)name
                                                      fileName:(NSString *)fileName
                                                      mimeType:(NSString *)mimeType
                                                         error:(NSError *__autoreleasing  _Nullable *)error {
    return ^(id<YCMultipartFormDataProtocol> formData) {
        [formData appendPartWithFileURL:fileURL
                                   name:name
                               fileName:fileName
                               mimeType:mimeType
                                  error:error];
    };
}

+ (void (^)(id<YCMultipartFormDataProtocol> _Nonnull))configWithInputStream:(NSInputStream *)inputStream
                                                                       name:(NSString *)name fileName:(NSString *)fileName length:(int64_t)length mimeType:(NSString *)mimeType {
    return ^(id<YCMultipartFormDataProtocol> formData) {
        [formData appendPartWithInputStream:inputStream
                                       name:name
                                   fileName:fileName
                                     length:length
                                   mimeType:mimeType];
    };
}


@end
