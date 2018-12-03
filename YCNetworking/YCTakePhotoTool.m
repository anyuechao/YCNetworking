//
//  YCTakePhotoTool.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCTakePhotoTool.h"

@interface YCTakePhotoTool()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,copy)imageHandle imageHandle;
@property (nonatomic , strong)UIImagePickerController *imagePicker;
@property (nonatomic,strong)UIViewController *currentVC;
@end

@implementation YCTakePhotoTool

#pragma mark- =====================public method=====================

+ (YCTakePhotoTool *)defaultTool {
    static YCTakePhotoTool *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}


- (void)catchPhotoWithAlertviewController:(UIViewController *)viewController imageHandle:(imageHandle)handle {
    self.imageHandle = handle;
    self.currentVC = viewController;

    BOOL islAuthorized = [self checkCameraRightWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL iscAuthorized =[self checkCameraRightWithSourceType:UIImagePickerControllerSourceTypeCamera];
    BOOL ispAuthorized =[self checkCameraRightWithSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    if (islAuthorized && iscAuthorized && ispAuthorized){
        [self selectIconActionWithviewController:viewController];
    }else{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"访问没有权限,请在隐私设置中开启" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.currentVC dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self.currentVC presentViewController:alertVC animated:YES completion:nil];
    }

}
- (void)selectIconActionWithviewController:(UIViewController *)vc {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self usePhtooSystemWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self usePhtooSystemWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alert addAction:photo];
    [alert addAction:album];
    [alert addAction:cancel];
    [vc presentViewController:alert animated:true completion:^{}];
}

- (void)catchPhotoWithSourceType:(UIImagePickerControllerSourceType)sourceType viewController:(UIViewController *)viewController imageHandle:(imageHandle)handle {

    self.imageHandle = handle;
    self.currentVC = viewController;

    if ([self checkCameraRightWithSourceType:sourceType]){
        [self usePhtooSystemWithSourceType:sourceType];
    }else{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"访问没有权限,请在隐私设置中开启" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.currentVC dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self.currentVC presentViewController:alertVC animated:YES completion:nil];
    }

}

#pragma mark- =====================private method=====================
/**
 *   退出
 */
- (void)exitWithPickerController:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:nil];

}

/**
 *   对权限进行校验 有权限返回YES 没有权限返回NO
 */
- (BOOL)checkCameraRightWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    AVAuthorizationStatus Status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (Status == AVAuthorizationStatusAuthorized || Status == AVAuthorizationStatusNotDetermined) {
        if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
            return YES;
        }
    }
    return NO;
}

/**
 *   调用相机或者相册
 */
- (void)usePhtooSystemWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePicker.sourceType = sourceType;
    [self.currentVC presentViewController:self.imagePicker animated:NO completion:nil];
}

#pragma mark- =====================UIImagePIckerControllerDelegate=====================
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    /* 此处参数 info 是一个字典，下面是字典中的键值 （从相机获取的图片和相册获取的图片时，两者的info值不尽相同）
     * UIImagePickerControllerMediaType; // 媒体类型
     * UIImagePickerControllerOriginalImage;  // 原始图片
     * UIImagePickerControllerEditedImage;    // 裁剪后图片
     * UIImagePickerControllerCropRect;       // 图片裁剪区域（CGRect）
     * UIImagePickerControllerMediaURL;       // 媒体的URL
     * UIImagePickerControllerReferenceURL    // 原件的URL
     * UIImagePickerControllerMediaMetadata    // 当数据来源是相机时，此值才有效
     */

    //判断返回的是视频还是照片
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (self.imageHandle) {
            self.imageHandle(image);
        }
    }
    //退出
    [self exitWithPickerController:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self exitWithPickerController:picker];
}

#pragma mark- =====================getter method=====================
- (UIImagePickerController *)imagePicker {

    if (!_imagePicker) {
        _imagePicker = [UIImagePickerController new];
        _imagePicker.delegate = self;
        _imagePicker.editing = YES;
        _imagePicker.allowsEditing = YES;

    }
    return _imagePicker;
}

@end
