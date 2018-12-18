//
//  YCTakePhotoTool.h
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <UIKit/UIKit.h>

typedef void (^imageHandle)(UIImage *image);
typedef void (^VideoHandle)(NSString *videoUrl);

@interface YCTakePhotoTool : NSObject

+ (YCTakePhotoTool *)defaultTool;

- (void)catchPhotoWithSourceType:(UIImagePickerControllerSourceType)sourceType viewController:(UIViewController *)viewController imageHandle:(imageHandle)handle;

- (void)catchPhotoWithAlertviewController:(UIViewController *)viewController imageHandle:(imageHandle)handle;

- (void)actionVideo:(UIViewController *)vc videoHandle:(VideoHandle)videoHandle;



@end
