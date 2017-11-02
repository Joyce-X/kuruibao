//
//  NetTool.h
//  FRIILENS
//
//  Created by 黎峰麟 on 16/1/23.
//  Copyright © 2016年 zorro. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "RTSPPlayer.h"
#import "MyDemoModel.h"
#import "Header.h"
#import "BaseModelEntity.h"


#define NetToolManager  [NetTool sharedInstance]
@interface NetTool : BaseModelEntity


@property (nonatomic, strong) VideoModel *videoModel;
@property (nonatomic, strong) ImageModel *imageModel;


@property (nonatomic, assign) NSInteger rtspChoose; //


@property (nonatomic, assign) BOOL isRecording;     //正在录像

@property (nonatomic, assign)BOOL isFirst;   //判断是否要从新打开视频流通道

@property (nonatomic, assign)BOOL isBegin;   //首次加载直播A

@property (nonatomic, assign)BOOL isBeginB;   //首次加载直播B
@property (nonatomic, assign)BOOL isfirstB;   //首次加载直播B

@property (nonatomic, assign)BOOL isSetTime; //首次设置时间
@property (nonatomic, assign)NSInteger recordTime; //录像时间

@property (nonatomic, strong) NSString *wifiString;//

@property (nonatomic, assign)BOOL isCameraViewController;
@property (nonatomic, assign)BOOL isRtspBViewController;
@property (nonatomic, assign)BOOL isSuccess;
AS_SINGLETON(NetTool)



//快照
-(void)requestTakePictureSuccess:(void (^)(NSDictionary *dict))success
                          failed:(void (^)(NSError *error))failed;



//录像状态 0 停止录像  1 开始录像
-(void)requestRecordingStatus:(NSInteger)index
                      Success:(void (^)(NSDictionary *dict))success
                       failed:(void (^)(NSError *error))failed;

//设置系统时间
-(void)requestSetTimeSuccess:(void (^)(NSDictionary *dict))success
                      failed:(void (^)(NSError *error))failed;


//系统将重新启动
-(void)requestRebootSuccess:(void (^)(NSDictionary *dict))success
                     failed:(void (^)(NSError *error))failed;


//录像模式  0:自动 1:手动
-(void)requestCameraMode:(NSInteger)index
                 Success:(void (^)(NSDictionary *dict))success
                  failed:(void (^)(NSError *error))failed;


//请求检测SD卡
-(void)requestCheckTFSuccess:(void (^)(NSDictionary *dict))success
                      failed:(void (^)(NSError *error))failed;


//请求格式化SD卡
-(void)requestFormatSDSuccess:(void (^)(NSDictionary *dict))success
                       failed:(void (^)(NSError *error))failed;


//获取图片
-(void)requestGetImageSuccess:(void (^)(NSDictionary *dict))success
                       failed:(void (^)(NSError *error))failed;


//0:加锁/    1:不加锁/   2:删除文件
-(void)requestSetFile:(NSInteger)index
             WithName:(NSString *)name
              Success:(void (^)(NSDictionary *dict))success
               failed:(void (^)(NSError *error))failed;

//图片设置

-(void)requestSetImageBrightness:(NSInteger)brightness
                        Contrast:(NSInteger)contrast
                             Hue:(NSInteger)hue
                      Saturation:(NSInteger)saturation
                       Sharpness:(NSInteger)sharpness
                    Image_mirror:(NSInteger)image_mirror
                         Success:(void (^)(NSDictionary *dict))success
                          failed:(void (^)(NSError *error))failed;


//文件 图片搜索 0: 文件   1: 图片
-(void)requestSearch:(NSInteger)index
              Update:(int)update
             Success:(void (^)(NSDictionary *dict))success
              failed:(void (^)(NSError *error))failed;


//灵敏度 0: low   1: normal  2: high
-(void)requestGsensor:(NSInteger)index
              Success:(void (^)(NSDictionary *dict))success
               failed:(void (^)(NSError *error))failed;


//分辨率 0: 1080p  1: 720p  2: 360p
-(void)requestRecordResolution:(NSInteger)index
                       Success:(void (^)(NSDictionary *dict))success
                        failed:(void (^)(NSError *error))failed;

//录制时间 0: 1min   1: 3min   2: 5min
-(void)requestRecordRectime:(NSInteger)index
                    Success:(void (^)(NSDictionary *dict))success
                     failed:(void (^)(NSError *error))failed;


//帧率 0: 30   1: 25   2: 20  2: 15
-(void)requestRecordFrames:(NSInteger)index
                   Success:(void (^)(NSDictionary *dict))success
                    failed:(void (^)(NSError *error))failed;


//设置视频声音
-(void)requestSetVideoRecMute:(NSInteger)index
                     WithType:(NSInteger)type
                      Success:(void (^)(NSDictionary *dict))success
                       failed:(void (^)(NSError *error))failed;


//获取产品型号
-(void)requestGetversionSuccess:(void (^)(NSDictionary *dict))success
                         failed:(void (^)(NSError *error))failed;

//获取录像时间 帧率 分辨率
-(void)requestGetRecordStausSuccess:(void (^)(NSDictionary *dict))success
                             failed:(void (^)(NSError *error))failed;


//获取灵敏度
-(void)requestGetGsensorSuccess:(void (^)(NSDictionary *dict))success
                         failed:(void (^)(NSError *error))failed;



////视频镜像
//-(void)requestSetImage_mirror:(NSInteger)index
//                   Success:(void (^)(NSDictionary *dict))success
//                    failed:(void (^)(NSError *error))failed;

#pragma mark 根据CMTime生成一个时间字符串  http://192.168.63.9
- (NSString *)timeStringWithCMTime:(NSInteger)time ;

-(BOOL)setTimeStr:(NSString *)str With:(NSInteger)type;


-(BOOL)isCurrentWIFI;
-(BOOL)isCurrentUBIWIFI;

@end


