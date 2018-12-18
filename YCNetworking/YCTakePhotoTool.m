//
//  YCTakePhotoTool.m
//  YCNetWorking
//
//  Created by 安跃超 on 2018/12/2.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "YCTakePhotoTool.h"
#import <Photos/Photos.h>

#define PHOTOCACHEPATH [NSTemporaryDirectory() stringByAppendingPathComponent:@"photoCache"]
#define VIDEOCACHEPATH [NSTemporaryDirectory() stringByAppendingPathComponent:@"videoCache"]
@interface YCTakePhotoTool()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,copy)imageHandle imageHandle;
@property (nonatomic,copy)VideoHandle videoHandle;
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
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
//        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
//        if (self.videoHandle){
//            self.videoHandle(videoUrl);
//        }
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {

            //如果是拍摄的视频, 则把视频保存在系统多媒体库中
            NSLog(@"video path: %@", info[UIImagePickerControllerMediaURL]);

//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library writeVideoAtPathToSavedPhotosAlbum:info[UIImagePickerControllerMediaURL] completionBlock:^(NSURL *assetURL, NSError *error) {
//
//                if (!error) {
//
//                    NSLog(@"视频保存成功");
//                } else {
//
//                    NSLog(@"视频保存失败");
//                }
//            }];
            //生成视频名称

        }
            //将视频存入缓存
            NSLog(@"将视频存入缓存");
            [self saveVideoFromPath:info[UIImagePickerControllerMediaURL] toCachePath:[VIDEOCACHEPATH stringByAppendingPathComponent:@"mediaName"]];

           NSString *videoUrl = [VIDEOCACHEPATH stringByAppendingPathComponent:@"mediaName"];
                    if (self.videoHandle){
                        self.videoHandle(videoUrl);
                    }

    }

    //退出
    [self exitWithPickerController:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self exitWithPickerController:picker];
}

- (void)actionVideo:(UIViewController *)vc videoHandle:(VideoHandle)videoHandle {
    _videoHandle = videoHandle;

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                NSLog(@"PHAuthorizationStatusAuthorized");
                break;
            case PHAuthorizationStatusDenied:
                NSLog(@"PHAuthorizationStatusDenied");
                break;
            case PHAuthorizationStatusNotDetermined:
                NSLog(@"PHAuthorizationStatusNotDetermined");
                break;
            case PHAuthorizationStatusRestricted:
                NSLog(@"PHAuthorizationStatusRestricted");
                break;
        }
    }];

    BOOL islAuthorized = [self checkCameraRightWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL iscAuthorized =[self checkCameraRightWithSourceType:UIImagePickerControllerSourceTypeCamera];
    BOOL ispAuthorized =[self checkCameraRightWithSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];

    if (islAuthorized && iscAuthorized && ispAuthorized){
        UIAlertController *alertController = \
        [UIAlertController alertControllerWithTitle:@""
                                            message:@"上传视频"
                                     preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *photoAction = \
        [UIAlertAction actionWithTitle:@"从视频库选择"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {

                                   NSLog(@"从视频库选择");
                                   self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                   self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
                                   self.imagePicker.allowsEditing = NO;

                                   [vc presentViewController:self.imagePicker animated:YES completion:nil];
                               }];

        UIAlertAction *cameraAction = \
        [UIAlertAction actionWithTitle:@"录像"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {

                                   NSLog(@"录像");
                                   self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                   self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                   self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                                   self.imagePicker.videoQuality = UIImagePickerControllerQualityType640x480;
                                   self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                                   self.imagePicker.allowsEditing = YES;

                                   [vc presentViewController:self.imagePicker animated:YES completion:nil];
                               }];

        UIAlertAction *cancelAction = \
        [UIAlertAction actionWithTitle:@"取消"
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * _Nonnull action) {

                                   NSLog(@"取消");
                               }];

        [alertController addAction:photoAction];
        [alertController addAction:cameraAction];
        [alertController addAction:cancelAction];

        [vc presentViewController:alertController animated:YES completion:nil];

        return;
    }else{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"访问没有权限,请在隐私设置中开启" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.currentVC dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self.currentVC presentViewController:alertVC animated:YES completion:nil];
        return;
    }
}

//将视频保存到缓存路径中
- (void)saveVideoFromPath:(NSString *)videoPath toCachePath:(NSString *)path {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:VIDEOCACHEPATH]) {

        NSLog(@"路径不存在, 创建路径");
        [fileManager createDirectoryAtPath:VIDEOCACHEPATH
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    } else {

        NSLog(@"路径存在");
    }

    NSError *error;
    [fileManager copyItemAtPath:videoPath toPath:path error:&error];
    if (error) {

        NSLog(@"文件保存到缓存失败");
    }
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
