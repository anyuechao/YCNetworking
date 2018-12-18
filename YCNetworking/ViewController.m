//
//  ViewController.m
//  YCNetworking
//
//  Created by 安跃超 on 2018/12/3.
//  Copyright © 2018年 安跃超. All rights reserved.
//

#import "ViewController.h"
#import "YCNetworking.h"
#import "YCAPICenter+home.h"
#import "YCRequestPresenter.h"
#import "YCTakePhotoTool.h"

@interface ViewController ()<YCRequestGroupDelegate,YCURLRequestDelegate,YCNetworkCustomLoggerDelegate>
@property (nonatomic,strong)YCRequestPresenter *ycrp;
@property (nonatomic,strong)YCTaskRequest *taskRequest;
@property (nonatomic,assign)BOOL isPause;
@property (nonatomic , strong)UIImagePickerController *imagePicker;
@property (nonatomic , strong)UIImage *icon;
@property (nonatomic,copy)void(^handleResult)(NSData *data);
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [YCNetworkLogger setupConfig:^(YCNetworkLoggerConfig * _Nonnull config) {
        config.enableLocalLog = YES;
        config.logAutoSaveCount = 5;
        config.loggerType = YCNetworkLoggerTypePlist;
    }];

    [YCNetworkLogger setDelegate:self];
    [YCNetworkLogger startLogging];

    self.isPause = YES;
    YCRequestPresenter *ycrp = [[YCRequestPresenter alloc] initWithView:self.view];
    @yc_weakify(self);
    ycrp.handleAction = ^{
        @yc_strongify(self);

                [self textHome];
        //分组请求
//                [self textAPIGroup];
        //文件下载
//                [self startdownLoadVideo];
        //文件上传
//        [self startUpload];
        //videos上传
//         [self startUploadVideo];
    };
    _ycrp = ycrp;
}

- (void)textHome {
    @yc_weakify(self);
    [YCAPICenter.home
     .success(^(id response){
        NSLog(@"%@",response);
        [self.ycrp logInfo:response];
    })
     .failure(^(NSError *error){
        NSString *log = [NSString stringWithFormat:@"请求失败 %@",error.localizedDescription];
        @yc_strongify(self);
        [self.ycrp logError:log];
    }) start];
}

- (void)textAPIGroup {
    YCRequestGroup *group = [YCRequestGroup groupWithMode:YCRequestGroupModeBatch];
    group.delegate = self;
    group.maxRequestCount = 1;

    @yc_weakify(self);
    YCAPIRequest *api1 = YCAPICenter.home
    .success(^(id response){
        NSLog(@"%@",response);
        NSString *str = [NSString stringWithFormat:@"api1请求成功%@",response];
        [self.ycrp logInfo:str];
    })
    .failure(^(NSError *error){
        NSString *log = [NSString stringWithFormat:@"api1请求失败 %@",error.localizedDescription];
        @yc_strongify(self);
        [self.ycrp logError:log];
    });

    YCAPIRequest *api2 = YCAPICenter.activity
    .success(^(id response){
        NSLog(@"%@",response);
        NSString *str = [NSString stringWithFormat:@"api2请求成功%@",response];
        [self.ycrp logInfo:str];
    })
    .failure(^(NSError *error){
        NSString *log = [NSString stringWithFormat:@"api2请求失败 %@",error.localizedDescription];
        @yc_strongify(self);
        [self.ycrp logError:log];
    });

    YCAPIRequest *api3 = YCAPICenter.center
    .success(^(id response){
        NSLog(@"%@",response);
        NSString *str = [NSString stringWithFormat:@"api3请求成功%@",response];
        [self.ycrp logInfo:str];
    })
    .failure(^(NSError *error){
        NSString *log = [NSString stringWithFormat:@"api3请求失败 %@",error.localizedDescription];
        @yc_strongify(self);
        [self.ycrp logError:log];
    });
    YCAPIRequest *api4 = YCAPICenter.room
    .success(^(id response){
        NSLog(@"%@",response);
        NSString *str = [NSString stringWithFormat:@"api4请求成功%@",response];
        [self.ycrp logInfo:str];
    })
    .failure(^(NSError *error){
        NSString *log = [NSString stringWithFormat:@"api4请求失败 %@",error.localizedDescription];
        @yc_strongify(self);
        [self.ycrp logError:log];
    });
    YCAPIRequest *api5 = YCAPICenter.live
    .success(^(id response){
        NSLog(@"%@",response);
        NSString *str = [NSString stringWithFormat:@"api5请求成功%@",response];
        [self.ycrp logInfo:str];
    })
    .failure(^(NSError *error){
        NSString *log = [NSString stringWithFormat:@"api5请求失败 %@",error.localizedDescription];
        @yc_strongify(self);
        [self.ycrp logError:log];
    });
    [group addRequests:@[api1,api2,api3,api4,api5]];
    [group start];
}

- (void)startUpload {
    @yc_weakify(self);
    [[YCTakePhotoTool defaultTool] catchPhotoWithAlertviewController:self imageHandle:^(UIImage *image) {
        NSData *data = UIImageJPEGRepresentation(image, 1.0);

        @yc_strongify(self);
        [YCAPICenter.upload.formData(^(id<YCMultipartFormDataProtocol>formData){
            [formData appendPartWithFileData:data name:@"uploadfile" fileName:@"uploadfile" mimeType:@"image/jpeg"];
        })
         .progress(^(NSProgress *proc){
            NSLog(@"\n进度=====\n当前进度：%@", proc);
            NSString *pro = [NSString stringWithFormat:@"\n进度=====\n当前进度：%@", proc];
            [self.ycrp logInfo:pro];
        })
         .success(^(id response){
            NSLog(@"%@",response);
            NSString *str = [NSString stringWithFormat:@"文件上传成功成功%@",response];
            [self.ycrp logInfo:str];
        })
         .failure(^(NSError *error){
            NSString *log = [NSString stringWithFormat:@"文件上传失败 %@",error.localizedDescription];
            [self.ycrp logError:log];
        }) start];
    }];
}

- (void)startUploadVideo {
    @yc_weakify(self);
    [[YCTakePhotoTool defaultTool] actionVideo:self videoHandle:^(NSString *videoUrl) {
        @yc_strongify(self);
        [YCAPICenter.uploadVideo.formData(^(id<YCMultipartFormDataProtocol>formData){
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:videoUrl] name:@"uploadfile" fileName:@"uploadfile" mimeType:@"video/.mov" error:nil];
//            [formData appendPartWithFileURL:videoUrl name:@"uploadfile" error:nil];
//            [formData appendPartWithFileData:videoUrl name:@"uploadfile" fileName:@"uploadfile" mimeType:@"video/.mov"];
        })
         .progress(^(NSProgress *proc){
            NSLog(@"\n进度=====\n当前进度：%@", proc);
            NSString *pro = [NSString stringWithFormat:@"\n进度=====\n当前进度：%@", proc];
            [self.ycrp logInfo:pro];
        })
         .success(^(id response){
            NSLog(@"%@",response);
            NSString *str = [NSString stringWithFormat:@"文件上传成功成功%@",response];
            [self.ycrp logInfo:str];
        })
         .failure(^(NSError *error){
            NSString *log = [NSString stringWithFormat:@"文件上传失败 %@",error.localizedDescription];
            [self.ycrp logError:log];
        }) start];
    }];
}

/**
 *  文件下载
 **/
- (void)startdownLoadVideo {
    if (self.isPause) {
        [self.taskRequest resume];
    } else {
        [self.taskRequest pause];
    }
    self.isPause = !self.isPause;
}

#pragma mark- =====================YCRequestGroupDelegate =====================
- (void)requestGroupAllDidFinished:(nonnull YCRequestGroup *)apiGroup {
    [self.ycrp logMessage:@"apiGroupAllDidFinished"];
}

#pragma mark- =====================YCURLRequestDelegate=====================
// 请求将要发出
- (void)requestWillBeSent:(nullable __kindof YCURLRequest *)request {

}
// 请求已经发出
- (void)requestDidSent:(nullable __kindof YCURLRequest *)request {

}

- (NSDictionary *)customInfoWithMessage:(YCDebugMessage *)message {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"Time"] = message.timeString;
    dict[@"RequestObject"] = [message.requestObject toDictionary];
    dict[@"Response"] = [message.response toDictionary];
    return [dict copy];
}

- (YCTaskRequest *)taskRequest {
    if (!_taskRequest){

        _taskRequest = [YCTaskRequest request]
        .setDelegate(self)
        .setFilePath([[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bbb_sunflower_1080p_30fps_normal.mp4"])
        .setCustomURL(@"https://videos.files.wordpress.com/kUJmAcSf/bbb_sunflower_1080p_30fps_normal.mp4")
        .progress(^(NSProgress *proc){
            NSLog(@"\n进度=====\n当前进度：%@", proc);
            NSString *pro = [NSString stringWithFormat:@"\n进度=====\n当前进度：%@", proc];
            [self.ycrp logInfo:pro];
        })
        .success(^(id response){
            NSLog(@"\n完成=====\n对象：%@", response);
            NSString *pro = [NSString stringWithFormat:@"\n完成=====\n对象：%@", response];
            [self.ycrp logMessage:pro];
        })
        .failure(^(NSError *error){
            NSLog(@"\n失败=====\n错误：%@", error);
            NSString *proe = [NSString stringWithFormat:@"\n失败=====\n错误：%@", error];
            [self.ycrp logMessage:proe];
        });
    }
    return _taskRequest;
}

@end
