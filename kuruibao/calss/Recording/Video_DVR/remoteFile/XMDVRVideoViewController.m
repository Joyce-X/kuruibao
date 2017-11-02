//
//  XMDVRVideoViewController.m
//  GKDVR
//
//  Created by x on 16/10/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description
 
      rootViewController:
 
    1 take photos
    2 show current video
    3 search remote image
    4 setting
 **********************************************************/
 

#import "XMDVRVideoViewController.h"
#import "AFNetworking.h"
//#import "KxMovieViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "XMLDictionary.h"
#import "XMDVRImageViewController.h"
#import "XMDVRSettingViewController.h"
#import "XMDVRLocalFileViewController.h"
#import "AppDelegate.h"
//#import "SpeechSynthesizer.h"

//#import "TestVC.h"
//#import "RTSPPlayer.h"
#import "ZxcRtspB.h"
#import "NetTool.h"
#import "ZxcRtspA.h"

#import "BoolTool.h"






#define coverHeight (mainSize.width * 211 / 375)
#define WIFIIdentifier @"DVR_"
#define liveAddress @"rtsp://192.168.63.9:554/live/udp/ch1_0"

#define kXMDVRSettingManualChangeRecordStatusNotification @"kXMDVRSettingManualChangeRecordStatusNotification"

@interface XMDVRVideoViewController ()<UIAlertViewDelegate,NSXMLParserDelegate,ZxcRtspBDelegate>

{
    BOOL isPlay;//!<  is playing image
    
    BOOL isFull;//!<  is full screen


}

 
@property (assign, nonatomic) BOOL isConnetDVR;//!< is connected to DVR WIFI

@property (nonatomic,weak)UIImageView* videoImageView;//!< play image view

@property (strong, nonatomic) AFHTTPSessionManager *session;//!< session manager

//@property (strong, nonatomic) KxMovieViewController *player;

@property (nonatomic,weak)UILabel* timeLabel;//!< show the record time

@property (nonatomic,weak)UIButton* twinkleBtn;//!< twinkle light

@property (nonatomic,weak)UIButton* recordBtn;//!< record button

@property (strong, nonatomic) NSTimer *timer; //!<

@property (assign, nonatomic) NSInteger recordTime;//!< current record time

@property (assign, nonatomic) NSInteger currentRecTime;

@property (nonatomic,strong)UIButton* fullScreenBtn;//!< click to show full screen

@property (assign, nonatomic) CGRect originFrame;//!< origin location of play view

@property (nonatomic,weak)UIImageView* fullScreenBar;//!< bottomBar when full screen

@property (nonatomic,weak)UIButton* fullScreenTwinkleBtn;//!< twinkle light when full screen


@property (nonatomic,weak)UILabel* fullScreenTimeLabel;//!< show time when full screen

@property (nonatomic,weak)UIButton* fullScreenVideoBtn;//!< record btn when full screen
@property (nonatomic,weak)UILabel* titleLabel;

@property (strong, nonatomic) NSMutableArray *btns;//!< 存按钮数组

@property (weak, nonatomic) UIView *bottomView;//!< 底部view


@end

@implementation XMDVRVideoViewController


#pragma mark --- life cycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //!< judge current network
    [self judgeCurrentNetWork];
   
    //!< init subview
    [self setupInit];
    
    isPlay = NO;
   
    //!< disable the sleep timer of system
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    
    
}




#pragma mark - play image
- (void)zxcRtspBCurrentImage:(UIImage *)image {
    
    isPlay = YES;//!< is playing
    
    [MBProgressHUD hideHUDForView:self.videoImageView];
    
    if (self.isConnetDVR)
    {
        self.videoImageView.image = image;
    }
    
}

/**
 *  invoke when the instance can not read the first frame or the fifth reconnect failure
 */
 - (void)zxcRtspBDisplayFailure:(BOOL)isFifth
{
    
    [MBProgressHUD hideHUDForView:self.videoImageView];
    
    isPlay = NO;
    
    [self showAlert];
  

}


/*!
 @brief  invoke when play failure
 */
- (void)zxcRtspBFailedToOpenStream
{
    
    [MBProgressHUD hideHUDForView:self.videoImageView];
    
    isPlay = NO;
    
    [self showAlert];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
//     self.tabBarController.tabBar.hidden = NO;
    
    if (self.isConnetDVR)
    {
        
        if(isPlay == NO)
        {
            //!< set delegate
            [ZxcRtspB shared].delegate = self;
            
            NetToolManager.rtspChoose = 0;
            
            [MBProgressHUD showHUDAddedTo:self.videoImageView animated:YES];
            
            [[ZxcRtspB shared] starRtsp];
        
        }else
        {
            [[ZxcRtspB shared] continueFrame];
        
        
        }
 
        
    }else
    {
        //!< 没有连接wifi不做任何操作
        //!< 当前wifi不正确，需要从新打开视频流
        NetToolManager.isFirst = YES;
        return;
    
    }
    
   
    //!< 监听通知
    //上下滑即将进入前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    //即将进入前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    //即将进入后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    //旋转屏幕通知
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(onDeviceOrientationChange)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil
//     ];

    MobClickBegain(@"记录仪主界面");

}

//- (void)onDeviceOrientationChange
//{
//     XMLOG(@"the device orientation did change");
//      [UIView animateWithDuration:0.2 animations:^{
//         
//          self.videoImageView.frame = CGRectMake(0, 0, mainSize.width, mainSize.height);
//          
//      }];
//    
//}

#pragma mark 上下滑进入前台
- (void)applicationBecomeActiveNotification {
    
    if (isPlay)
    {
        [[ZxcRtspB shared] continueFrame];
    }
    
}

#pragma mark 即将返回前台的处理
- (void)applicationWillEnterForeground {
   
    if (isPlay)
    {
        [[ZxcRtspB shared] continueFrame];
    }
}

#pragma mark 即将进入后台的处理
- (void)applicationWillResignActive {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    if (isPlay) {
        
         [[ZxcRtspB shared] pauseFrame];
    }
    
     
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //!< 取消监听通知
//    NetToolManager.isSetTime = NO;
    
     [[ZxcRtspB shared] pauseFrame];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    MobClickEnd(@"记录仪主页面");

}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
    
}

- (void)setupInit
{
    
    
    //!< 添加底部背景
    UIImageView *bottomBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background_bottom"]];
    
    bottomBackground.userInteractionEnabled  = YES;
    
    [self.view addSubview:bottomBackground];
    
    self.bottomView = bottomBackground;
    
    [bottomBackground mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.equalTo(self.view);
        
        make.height.equalTo(FITHEIGHT(354));
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 播放区域
    UIImageView *playBackground = [[UIImageView alloc]init];
    
    playBackground.backgroundColor = [UIColor blackColor];
    
     playBackground.userInteractionEnabled  = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(coverImageDidClick:)];
    
    [playBackground addGestureRecognizer:tap];
    
    [self.view addSubview:playBackground];
    
    self.videoImageView = playBackground;
    
    [playBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(self.view);
        
        make.bottom.equalTo(bottomBackground.mas_top);
        
        make.height.equalTo(FITHEIGHT(211));
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 顶部背景
    UIImageView *topBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background_top"]];
    
    topBackground.userInteractionEnabled  = YES;
    
    [self.view addSubview:topBackground];
    
    [topBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.top.equalTo(self.view);
        
        make.bottom.equalTo(playBackground.mas_top);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 返回
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"update_back"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backToLast) forControlEvents:UIControlEventTouchUpInside];
    
    [topBackground addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(topBackground).offset(-24);
        
        make.left.equalTo(topBackground).offset(24);
        
        make.size.equalTo(CGSizeMake(25, 25));
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 圆形背景
    UIImageView *circleBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"update_circle"]];
    
    circleBackground.userInteractionEnabled = YES;
    
    [bottomBackground addSubview:circleBackground];
    
    [circleBackground mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.equalTo(bottomBackground);
        
        make.size.equalTo(CGSizeMake(FITHEIGHT(248), FITHEIGHT(248)));
        
        
    }];
    
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 底部按钮
    NSMutableArray  *btns = [NSMutableArray array];
    
    NSArray *images = @[@"update_lock_normal",@"update_remote_normal",@"update_setting_normal",@"update_take_normal",@"update_local_normal"];
    
     NSArray *imagess = @[@"update_lock_highlight",@"update_remote_highlight",@"update_setting_highlight",@"update_take_highlight",@"update_local_highlight"];
    
    for (int i = 0; i < 5; i++)
    {
        UIButton *btn = [UIButton new];
        
        [btn setBackgroundImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:images[i]] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[UIImage imageNamed:imagess[i]] forState:UIControlStateSelected];
 
        
        btn.tag = i;
        
        [bottomBackground addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(bottomBackground);
            
            make.bottom.equalTo(circleBackground.mas_centerY).offset(62);
            
            make.size.equalTo(CGSizeMake(125*1.1753, 125));
            
        }];
        
        [btns addObject:btn];
        
        btn.layer.anchorPoint = CGPointMake(0.5, 1);
        
        [btn addTarget:self action:@selector(btnClick:event:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat angle = 72 * i;
        
        btn.transform = CGAffineTransformMakeRotation(angle *M_PI /180);
        
        self.btns = btns;
        
    }
    
    
    
    UIButton *optBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [optBtn setBackgroundImage:[UIImage imageNamed:@"update_continue"] forState:UIControlStateNormal];
    
    [optBtn setBackgroundImage:[UIImage imageNamed:@"update_pause"] forState:UIControlStateSelected];
    
    optBtn.tag = 5;
    
    [optBtn addTarget:self action:@selector(operateBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomBackground addSubview:optBtn];
    
    self.recordBtn = optBtn;
    
    [optBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(circleBackground.mas_centerX);
        
        make.centerY.equalTo(circleBackground.mas_centerY).offset(-2);
        
        make.size.equalTo(CGSizeMake(60, 60));
        
    }];


    
//    return;
    //-----------------------------以下区域为旧代码---seperate line---------------------------------------//
    
     isFull = NO;//!< 初始化是否显示全屏
    
    [self fullScreenBtn];
    
    //!< timeLabel
    
    UILabel *timeLabel = [UILabel new];
    
    timeLabel.textColor = [UIColor whiteColor];
    
    timeLabel.text = @"";
    
    timeLabel.font = [UIFont systemFontOfSize:14];
    
    [playBackground addSubview:timeLabel];
    
    self.timeLabel = timeLabel;
    
     [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
         make.height.equalTo(11);
        
         make.top.equalTo(playBackground).offset(9);
         
         make.centerX.equalTo(playBackground);
   
         make.width.equalTo(50);
        
    }];

    
    //!< add twinkle btn
    
    UIButton *twinkleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [twinkleBtn setImage:[UIImage imageNamed:@"DVR_noRecording"] forState:UIControlStateNormal];
    
    [twinkleBtn setImage:[UIImage imageNamed:@"DVR_isRecording"] forState:UIControlStateSelected];
    
    [playBackground addSubview:twinkleBtn];
    
    self.twinkleBtn = twinkleBtn;
    
    [twinkleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(timeLabel.mas_left).offset(-13);
        
        make.centerY.equalTo(timeLabel);
        
        make.size.equalTo(CGSizeMake(8, 8));
        
        
    }];
    
    timeLabel.hidden = YES;
    
    twinkleBtn.hidden = YES;
    
    //!< 监听网络变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStatisDidChanged:) name:XMNetWorkDidChangedNotification object:nil];
    
    //!< 监听手动修改录像状态
    [[NSNotificationCenter defaultCenter] addObserver:
     self  selector:@selector(userManualChangeRecordStatus:) name:kXMDVRSettingManualChangeRecordStatusNotification object:nil];
    
    //!< 获取当前录制状态
    if (!self.isConnetDVR) { //!< 如果没有连接到设备就不进行任何判定
        
//        [self showAlert];
        return;
    }
    
    
    NSString *urlStr = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=getrecstatus";
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLData:responseObject];
        
        int status = [dic[@"RecStat"] intValue];
        
        //!< 如果是正在录制就显示录制图片
        self.recordBtn.selected = status ? YES : NO;
        
        if (status)
        {
            //!< 正在录制的话，就获取当前录制时间 准备开始倒计时
            
            [self getRecordTime];
        }
        
        
    } failure:nil];

//    [self coverImageDidClick:nil];
    
    
   
    
    
}

- (void)getRecordTime
{
    NSString *url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=getrecord";
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         NSString *result = [NSString stringWithCString:[responseObject bytes] encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:result];
        
        
        int recordTime = [dic[@"Rectime"] intValue];
        
        if(recordTime == 0)self.currentRecTime = 60;
        
        if(recordTime == 1)self.currentRecTime = 180;
        
        if(recordTime == 2)self.currentRecTime = 300;
        
        self.recordTime = self.currentRecTime;
        
        if(self.timer)
        {
            [self.timer invalidate];
            
            self.timer = nil;
        
        }
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeTimeLabelValue:) userInfo:nil repeats:YES];
        
        //!< 设置按钮状态，销毁定时器，隐藏倒计时
        
        if (isFull)
        {
            //!< 全屏状态发送停止录制指令成功
//            self.fullScreenVideoBtn.selected = YES;
            
            self.fullScreenTwinkleBtn.hidden = NO;
            
            self.fullScreenTimeLabel.hidden = NO;
            
//            self.fullScreenTimeLabel.text = @"";
            
        }else
        {
            //!< 非全屏状态发送停止录制指令成功
            self.timeLabel.hidden = NO;
            
            self.twinkleBtn.hidden = NO;
            
//            self.timeLabel.text = @"";
            
//            self.recordBtn.selected = YES;
            
        }
        
        
    } failure:nil];
    
    
}


- (void)changeTimeLabelValue:(NSTimer *)timer
{
    
   
    
    NSInteger minute = self.recordTime / 60;
    
    NSInteger second = self.recordTime % 60;
    
     //!< 设置按钮状态，销毁定时器，隐藏倒计时
    
    if (isFull)
    {
        //!< 全屏状态发送停止录制指令成功
         self.fullScreenTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)minute,second];
        
         self.fullScreenTwinkleBtn.selected = !self.fullScreenTwinkleBtn.selected;
        
    }else
    {
        //!< 非全屏状态发送停止录制指令成功
        self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)minute,second];
        
        self.twinkleBtn.selected = !self.twinkleBtn.selected;

        
    }
    
    self.recordTime--;
    
    if (self.recordTime == -1)
    {
        self.recordTime = _currentRecTime;
    }
    

    if (self.recordTime % 5 == 0)
    {
        NSString *wifiName = [self getCurrentWIFIName];
        
        if (!wifiName || [wifiName containsString:WIFIIdentifier])
        {
        
            [self netStatisDidChanged:nil];
            
        }
    }
    
    
}


- (void)dealloc
{
    if (isPlay)
    {
        [[ZxcRtspB shared] stopRtsp];
    }
    
    [ZxcRtspB shared].delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    NSLog(@"-------------------------909");
}



#pragma mark --- lazy

-(AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _session.requestSerializer.timeoutInterval = 10;
    }
    
    return _session;

}


#pragma mark --- monitor click event



/**
 * @brief 点击按钮执行
 */
- (void)btnClick:(UIButton *)sender event:(UIEvent *)event
{
    
    //!< 判断当前的点是否在上一个按钮的返回内，是否在下一个点击的范围内，避免误操作，进行判断
    UITouch *touch = [[event allTouches] anyObject];
    
    //    CGPoint point = [touch locationInView:sender];//!< 在当前按钮上的坐标
    
    CGPoint point_view = [touch locationInView:_bottomView];
    //
    //    UIButton *lastBtn, *nextBtn;//!< 前后的按钮
    //
    //    int index = (int)sender.tag;
    //
    //    int lastIndex = index - 1;
    //
    //    int nextIndex = index + 1;
    //
    //    if(lastIndex < 0)
    //    {
    //        //!< 点击的是第一个按钮
    //        lastBtn = _btns.lastObject;
    //
    //        nextBtn = _btns[1];
    //
    //    }else if(nextIndex == _btns.count)
    //    {
    //        //!< 点击的是最后一个按钮
    //        lastBtn = _btns[_btns.count - 2];
    //
    //        nextBtn = _btns.firstObject;
    //
    //    }else
    //    {
    //        lastBtn = _btns[lastIndex];
    //
    //        nextBtn = _btns[nextIndex];
    //
    //    }
    //
    //    BOOL lastContain = CGRectContainsPoint(lastBtn.frame, point_view);
    //
    //    BOOL nextContain = CGRectContainsPoint(nextBtn.frame, point_view);
    //
    //    if(!lastContain && !nextContain)
    //    {
    //
    //     //!< 前后都不包含的话 由index来响应事件
    //
    //
    //    }
    //
    CGPoint endPoint = CGPointMake(_bottomView.bounds.size.width/2, _bottomView.bounds.size.height/2);
    
    float angle = [self angleForStartPoint:point_view EndPoint:endPoint];
    
    CGRect bottomRect = CGRectMake(0, _bottomView.bounds.size.height / 2, _bottomView.bounds.size.width, _bottomView.bounds.size.height/2);
    
    BOOL isContain = CGRectContainsPoint(bottomRect, point_view);
    
    if (isContain)
    {
        
        angle = -1 *angle;
        NSLog(@"点击下班部分-----");
        
    }else
    {
        NSLog(@"点击上半部分-----");
        
    }
    
    NSLog(@"------------  %f",angle);
    
    //!< 根据角度来确定让那个按钮去响应事件
    
    int index = 0;
    
    if (angle >= 54 && angle < 124)
    {
        index = 0;
    }
    
    if (angle >= 124 && angle <= 180)
    {
        index = 1;
    }
    
    if (angle >= -180 && angle <= -165)
    {
        index = 1;
    }
    
    if (angle > -165 && angle <= -91)
    {
        index = 2;
    }
    
    
    if (angle > -91 && angle <= -17)
    {
        index = 3;
    }
    
    if (angle > -17 && angle < 54)
    {
        index = 4;
    }
    
    
    NSLog(@"000000==应该由%d个按钮来响应事件",index);
    
    [self executeClickWithIndex:index];
    
    
}


- (void)executeClickWithIndex:(int)index
{
//    return;
    UIButton *btn = _btns[index];
    
    btn.tag = index;
    
    btn.selected = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        btn.selected = NO;
 
    });
    
    //!< 在这里执行相应的方法---
    
    [self operateBtnDidClick:btn];
    
    
}


/**
 *  click the play view
 */
- (void)coverImageDidClick:(UITapGestureRecognizer *)tap
{

    //!< whether the wifiName is correct
    NSString *wifiName = [self getCurrentWIFIName];
    
    //!< if the wifiName is wrong,show alert and return
    if (wifiName.length == 0 ||![wifiName containsString:WIFIIdentifier]){
      
        [self showAlert];
       
        return;
    }
    
    
    //!< whether the view is playing image
    if (isPlay == NO)
    {
        //!< isPlay is no,show hud and start to play
        [MBProgressHUD showHUDAddedTo:self.videoImageView animated:YES];
        
        ZxcRtspB *zxc = [ZxcRtspB shared];
        
        zxc.delegate = self;
        
        [zxc starRtsp];
        
        
        
    }else
    {
        //!< isPlaying,judge isFull,
        if (isFull)
        {
            //!< current is full screen
            
            
            
            
            
        }else
        {
            //!< current is normal state
        
            if (self.fullScreenBtn.alpha == 1)
            {
                [UIView animateWithDuration:0.4 animations:^{
                   
                    self.fullScreenBtn.alpha = 0;
                }];
            }else
            {
                [UIView animateWithDuration:0.4 animations:^{
                    
                   self.fullScreenBtn.alpha = 1;
                }];
            
            
            }
        
        }
    
    
    }

}

- (UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn)
    {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_fullScreenBtn setBackgroundImage:[UIImage imageNamed:@"DVR_fullScreen"] forState:UIControlStateNormal];
        
//        _fullScreenBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 19, 19);
        
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.videoImageView addSubview:_fullScreenBtn];
        
        [_fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.videoImageView).offset(-10);
            
            make.bottom.equalTo(self.videoImageView).offset(-10);
            
            make.size.equalTo(CGSizeMake(31, 31));
            
        }];
    }

    return _fullScreenBtn;
}


//!< 点击操作按钮
- (void)operateBtnDidClick:(UIButton *)sender
{
    
    NSString *wifiName = [self getCurrentWIFIName];
    
    
    if ((wifiName == nil || ![wifiName containsString:WIFIIdentifier]) && sender.tag !=4) {
        
        [self showAlert];
        
        return;
    }
  
    
    switch (sender.tag) {
            
        case 0:
            
            [self clickLockVideo];
//
            
            break;
            
        case 1:
            
            [self clickSDCardImage];
            
            
            break;
            
        case 2:
            
            [self clickSetting];
            
            break;
        case 3:
            
            [self clickTakePhoto];
            
            break;
        case 4:
            
            [self clickLocalImage];
            
            
            break;
        case 5:
            
           [self clickRecordVideo];
        default:
            break;
    }
    

}

/**
 * @brief 点击锁定视频
 */
- (void)clickLockVideo
{
    
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *url = @"http://192.168.63.9/cgi-bin/lockVideo.cgi";
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
//        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        hud.mode = MBProgressHUDModeText;
        
        hud.labelText = @"操作成功";
        
        [hud hide:YES afterDelay:0.3];
        
        NSLog(@"responseObject - %@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        hud.mode = MBProgressHUDModeText;
        
        hud.labelText = @"操作失败";
        
        [hud hide:YES afterDelay:0.3];
        NSLog(@"error - %@",error);
        
    }];
    
   
    
    
}


//!< click takePhoto
- (void)clickTakePhoto
{
    
    //!< 必须展示在当期view，否则其他按钮是可以点击的，
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlStr = @"http://192.168.63.9/cgi-bin/Control.cgi?type=snapshot&";
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showSuccess:@"拍照成功"];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
         [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"拍照失败"];
        
    }];
    
 }


- (void)clickRecordVideo
{
    
   MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //!< 获取当前的录制状态，如果状态是正在录制：发送停止录制消息，设置按钮背景，隐藏倒计时
    //!< 如果当前状态不是处于录制状态：发送开始录制消息，设置背景按钮，显示倒计时
    
    //!< 获取当前录制信息
     NSString *urlStr = [DVRHost stringByAppendingString:@"type=system&action=getrecstatus"];
    
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLData:responseObject];
        
        //!< 根据当前录制状态执行响应操作
        [self controlRecordingStatusWithDic:dic];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        hud.mode = MBProgressHUDModeText;
        
        hud.labelText = @"连接错误";
        
        [hud hide:YES afterDelay:0.2];
        
        return ;
        
    }];
    
   
    
    
    
}

- (void)clickSDCardImage
{
    
    //!< 显示远程文件控制器
    
    XMDVRImageViewController *sdCardVC = [XMDVRImageViewController new];
    
    [self.navigationController pushViewController:sdCardVC animated:YES];
    
   
    
}

- (void)clickSetting
{
    
    //!< 显示设置控制器
    XMDVRSettingViewController *setVC = [XMDVRSettingViewController new];
    
    [self.navigationController pushViewController:setVC animated:YES];
    
    
}

- (void)clickLocalImage
{
    //!< 显示本地文件控制器
    XMDVRLocalFileViewController *localFileVC = [XMDVRLocalFileViewController new];
    
    [self.navigationController pushViewController:localFileVC animated:YES];

    
    
}
 
- (void)fullScreenBtnDidClick:(UIButton *)sender
{
    
    NSString *wifiName = [self getCurrentWIFIName];
    
    if ((wifiName == nil || ![wifiName containsString:WIFIIdentifier]) && sender.tag !=4) {
        
        [self showAlert];
        
        return;
    }
    
    if (!isPlay) {
        
        return;
        
    }
     //!< 转换屏幕
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    delegate.allowRotation = YES;
    
    //!< 强制转换屏幕
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = UIInterfaceOrientationLandscapeRight;
    [invocation setArgument:&val atIndex:2];//前两个参数已被target和selector占用
    [invocation invoke];
    
    //!< 隐藏tabbar和全屏按钮
    self.tabBarController.tabBar.hidden = YES;
    
    sender.hidden = YES;

    isFull = YES;
//    self.player.view.frame = CGRectMake(0, 0, mainSize.width, mainSize.height);
    
    
    [self.videoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view);
        
        make.right.equalTo(self.view);
        
        make.top.equalTo(self.view);
        
        make.bottom.equalTo(self.view);
        
    }];
    
    //!< 播放视图上添加底部栏和
    
    [self showFullScreenBottomBar:self.videoImageView];
    
    
    /**
    //  转换视图
    sender.hidden = YES; //!< 隐藏放大按钮
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.tabBarController.tabBar.hidden = YES;//!< 隐藏底部栏
    
    [self showFullScreenBottomBar:self.player.view];  //!< 创建子视图
    
    //!< 改变大小
    CGRect frame = self.player.view.frame;
    frame.size.width = mainSize.width;
    frame.size.height = mainSize.height;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
     self.player.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    self.player.view.frame = frame;
        
    */
    
    
}

- (void)showFullScreenBottomBar:(UIView*)superView
{
    
    //!< 底部容器
    
//    XMLOG(@"%f",mainSize.height);
    UIImageView *bottomView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"DVR_FULL_BarBackground"]];;
    
    bottomView.userInteractionEnabled = YES;
    
    bottomView.contentMode = UIViewContentModeScaleAspectFill;
    
//    bottomView.backgroundColor = [UIColor greenColor];
    
    [superView addSubview:bottomView];
    
    self.fullScreenBar = bottomView;
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.equalTo(60);
        
        make.bottom.equalTo(superView);
        
        make.width.equalTo(mainSize.width - 289);
        
        make.centerX.equalTo(superView.mas_centerX);
       
    }];
    
    
    //!< 录像按钮
    
    UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [videoBtn setImage:[UIImage imageNamed:@"update_continue_full"] forState:UIControlStateNormal];
    
    [videoBtn setImage:[UIImage imageNamed:@"update_continue_full"] forState:UIControlStateHighlighted];

    [videoBtn setImage:[UIImage imageNamed:@"update_pause_full" ] forState:UIControlStateSelected];
    
    [videoBtn addTarget:self action:@selector(clickRecordVideo) forControlEvents:UIControlEventTouchUpInside];
    
    videoBtn.selected = self.recordBtn.selected;
    
//    videoBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
//    videoBtn.backgroundColor = [UIColor redColor];
    
    [bottomView addSubview:videoBtn];
    
    self.fullScreenVideoBtn = videoBtn;
    
    [videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.equalTo(60);
        
        make.width.equalTo((155/2));
        
        make.top.equalTo(bottomView);
        
        make.left.equalTo(bottomView.mas_centerX);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 锁定按钮
    UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [lockBtn setImage:[UIImage imageNamed:@"update_lock_full"] forState:UIControlStateNormal];
    
//    [lockBtn setImage:[UIImage imageNamed:@"update_lock_full" ] forState:UIControlStateHighlighted];
    
    [lockBtn addTarget:self action:@selector(clickLockVideo) forControlEvents:UIControlEventTouchUpInside];
    
    lockBtn.selected = self.recordBtn.selected;
    
    lockBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
//    lockBtn.backgroundColor = [UIColor blueColor];
    
    [bottomView addSubview:lockBtn];
    
//    self.fullScreenVideoBtn = videoBtn;
    
    [lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(60);
        
        make.width.equalTo((155/2));
        
        make.top.equalTo(bottomView);
        
        make.right.equalTo(bottomView.mas_centerX);
        
    }];

    
    //!< 拍照按钮
    
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [takePhotoBtn setImage:[UIImage imageNamed:@"update_photo_full"] forState:UIControlStateNormal];
    
//    takePhotoBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
//    takePhotoBtn.backgroundColor = [UIColor yellowColor];
    
//    [takePhotoBtn setBackgroundImage:[UIImage imageNamed:@"DVR_FULL_takePhoto_Highlighted"] forState:UIControlStateHighlighted];
    
    [takePhotoBtn addTarget:self action:@selector(clickTakePhoto_fullScreen) forControlEvents:UIControlEventTouchUpInside];
    
//    takePhotoBtn.backgroundColor = [UIColor yellowColor];
    
//    takePhotoBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [bottomView addSubview:takePhotoBtn];
    
    [takePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(60);
        
        make.width.equalTo(lockBtn);
        
        make.right.equalTo(lockBtn.mas_left);
        
        make.top.equalTo(bottomView);
        
        
    }];
    
    //!< 退出全屏按钮
    
    UIButton *exitFullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [exitFullScreenBtn setImage:[UIImage imageNamed:@"update_back_full"] forState:UIControlStateNormal];
    
//     [exitFullScreenBtn setImage:[UIImage imageNamed:@"DVR_FULL_back_Highlighted"] forState:UIControlStateHighlighted];
    
    [exitFullScreenBtn addTarget:self action:@selector(clickExitFullScreen_fullScreen) forControlEvents:UIControlEventTouchUpInside];
    
//    exitFullScreenBtn.backgroundColor = [UIColor brownColor];
    
//    exitFullScreenBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    
//    exitFullScreenBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [bottomView addSubview:exitFullScreenBtn];
    
    [exitFullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(60);
        
        make.left.equalTo(videoBtn.mas_right);
        
        make.top.equalTo(bottomView);
        
        make.width.equalTo(lockBtn);
        
    }];
    
    
    
    //!< timeLabel
    
    UILabel *timeLabel = [UILabel new];
    
    timeLabel.textColor = [UIColor whiteColor];
    
    timeLabel.text = @"";
    
    timeLabel.font = [UIFont systemFontOfSize:14];
    
    [superView addSubview:timeLabel];
    
    self.fullScreenTimeLabel = timeLabel;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(12);
        
        make.right.equalTo(superView).offset(-15);
        
        make.top.equalTo(superView).offset(11);
        
        make.width.equalTo(50);
        
    }];
    
    
    //!< add twinkle btn
    
    UIButton *twinkleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [twinkleBtn setImage:[UIImage imageNamed:@"DVR_noRecording"] forState:UIControlStateNormal];
    
    [twinkleBtn setImage:[UIImage imageNamed:@"DVR_isRecording"] forState:UIControlStateSelected];
    
    [superView addSubview:twinkleBtn];
    
    self.fullScreenTwinkleBtn = twinkleBtn;
    
    [twinkleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(timeLabel.mas_left).offset(-14);
        
        make.centerY.equalTo(timeLabel);
        
        make.size.equalTo(CGSizeMake(10, 10));
        
        
    }];
    
    timeLabel.hidden = self.timeLabel.hidden;
    
    twinkleBtn.hidden = self.twinkleBtn.hidden;
    
    
    self.timeLabel.hidden = YES;
    
    self.twinkleBtn.hidden = YES;
 
}



#pragma mark --- click operate when full screen



//!< 全屏时候点击拍照
- (void)clickTakePhoto_fullScreen
{
         //!< 必须展示在当期view，否则其他按钮是可以点击的，
  MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlStr = @"http://192.168.63.9/cgi-bin/Control.cgi?type=snapshot&";
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        hud.mode = MBProgressHUDModeText;
        
         hud.labelText = @"拍照成功";
        
        [hud hide:YES afterDelay:0.3];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
         hud.mode = MBProgressHUDModeText;
        
        hud.labelText = @"拍照失败";
        
        [hud hide:YES afterDelay:0.3];

        
    }];

    
}

//!< 退出全屏
- (void)clickExitFullScreen_fullScreen
{
    
    //!< 法1
     //!< 转换屏幕
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    delegate.allowRotation = NO;
    
    //!< 强制转换屏幕
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = UIInterfaceOrientationPortrait;
    [invocation setArgument:&val atIndex:2];//前两个参数已被target和selector占用
    [invocation invoke];
    
    self.tabBarController.tabBar.hidden = NO;//!< 显示tabbar
    
    self.fullScreenBtn.hidden = NO;//!< 显示全屏按钮
    
    //!< 修改播放界面大小
//    self.player.view.frame = self.videoImageView.frame;
    
    
    
    
    self.timeLabel.hidden = self.fullScreenTwinkleBtn.hidden;
    
    self.twinkleBtn.hidden = self.fullScreenTimeLabel.hidden;
    
    
    [self.fullScreenBar removeFromSuperview];
    
    [self.fullScreenTwinkleBtn removeFromSuperview];
    
    [self.fullScreenTimeLabel removeFromSuperview];
    
    isFull = NO;
    
    [self.videoImageView remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
//        make.bottom.equalTo(_recordBtn.mas_top).offset(-FITHEIGHT(53 * 0.5));
//        
//        if (mainSize.height == 480)
//        {
//            make.top.equalTo(_titleLabel.mas_bottom).offset(5);
//        }else
//        {
//            make.height.equalTo(coverHeight);
//        }
//        
        make.bottom.equalTo(self.bottomView.mas_top);
        
        make.height.equalTo(FITHEIGHT(211));
        
    }];
    
    /**
     // 法2
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.player.view.transform = CGAffineTransformIdentity;
    
    self.player.view.frame = self.videoImageView.frame;
    
    [self.fullScreenBar removeFromSuperview];//!< 删除子视图
    
    [self.fullScreenTwinkleBtn removeFromSuperview];
    
    [self.fullScreenTimeLabel removeFromSuperview];
    
    self.tabBarController.tabBar.hidden = NO;
    
    self.fullScreenBtn.hidden = NO;
    
    */
    
    
    
    
    
    
}



#pragma mark --- judge curretn network Status

- (void)judgeCurrentNetWork
{
    
    //!< judge the WIFI is DVR WIFI?, get current WIFI name
    
    NSString *wifiName = [self getCurrentWIFIName];
    
    if (wifiName == nil || ![wifiName containsString:WIFIIdentifier])
    {
        
        if(self.view.window)
        [self showAlert];
        
        return;
    }
    
    //!< connect seccess
     self.isConnetDVR = YES;
    
    
}


- (void)showAlert
{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
   
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                            message:@"手机未连接设备"
                             delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    [alert show];
    
  
    
    
}



#pragma mark --- monitor net

- (void)netStatisDidChanged:(NSNotification *)noti
{
    
    [MBProgressHUD hideHUDForView:self.view];
    
    NSString *wifiName = [self getCurrentWIFIName];
    
    if (wifiName && [wifiName containsString:WIFIIdentifier])
    {
        self.isConnetDVR = YES;
 
        
    }else
    {
        
         self.fullScreenBtn.hidden = YES;
        
        if(mainSize.width > mainSize.height )//!< 如果处于横屏执行
        {
        
        [self clickExitFullScreen_fullScreen];
        
        }
        self.isConnetDVR = NO;
        
//        if(self.player)
//        {
//            [self.player pause];
//            
//            [self.player.view removeFromSuperview];
//            
//            self.player = nil;
//        
//        
//        }
        
        if (self.timer)
        {
            
         [self.timer invalidate];
        
        self.timer = nil;
        
        self.timeLabel.hidden = YES;
        
        self.twinkleBtn.hidden = YES;
        
         }
        
        
        //!< 当显示当前控制器的时候提示设备已经断开
        if (self.isViewLoaded && self.view.window)
        {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"设备已断开连接" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            
            
            [alert show];
        }
       
    }
    
    
    
    
}


#pragma mark --- quickly method

//!< get WIFI  current name

- (NSString *)getCurrentWIFIName
{
 
    NSString *WIFIName = nil;
    
    NSArray *allWIFI = CFBridgingRelease(CNCopySupportedInterfaces());//!< all wifi
    
    
    for (NSString *wifi in allWIFI)
    {
        CFDictionaryRef dic = CNCopyCurrentNetworkInfo((__bridge CFStringRef)wifi);
        
        WIFIName = ((__bridge NSDictionary *)dic)[@"SSID"];
        
        NSLog(@"%@",WIFIName);
 
    
    }
    
    
    if([WIFIName containsString:WIFIIdentifier])
    {
    
//    http://192.168.57.150/cgi-bin/Control.cgi?
        
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        
        df.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
        
        NSString *timeStr = [df stringFromDate:[NSDate date]];
        
         NSString *urlStr = [DVRHost
                             stringByAppendingFormat:@"type=system&action=setdatetime&%@",timeStr];
        
        [self.session GET:urlStr parameters:nil progress:nil success:nil failure:nil];
        
    }
    
 
    return WIFIName;
    
    
}

//!< data to string

- (NSString *)transferDataToString:(NSData *)data
{
    
    const char * result = [data bytes];
    
    NSString *string = [NSString stringWithCString:result encoding:NSUTF8StringEncoding];
    
    return string;

}

//!< control recording status

- (void )controlRecordingStatusWithDic:(NSDictionary *)dic
{

    int status = [dic[@"RecStat"] intValue];
    
    [MBProgressHUD hideHUDForView:self.view];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if(status == 0) //!< 当前处于停止录制状态
    {
        //!< Not recording
        
        NSString *setRecUrl = [DVRHost stringByAppendingString:@"type=system&action=setrecstatus&recstat=1"];
        
        [self.session GET:setRecUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            
            //!< 设置按钮状态，销毁定时器，隐藏倒计时
            
            if (isFull)
            {
                //!< 全屏状态发送停止录制指令成功
                self.fullScreenVideoBtn.selected = YES;
                
                
            }else
            {
                //!< 非全屏状态发送停止录制指令成功
                
                
                self.recordBtn.selected = YES;
                
            }
            
           

            
            //!< 改变状态，打开定时器，显示倒计时
            hud.mode = MBProgressHUDModeText;
            
            hud.labelText = @"开始录制";
            
            [hud hide:YES afterDelay:0.2];
            
            
            
            [self getRecordTime];
            
            
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"连接超时";
            [hud hide:YES afterDelay:0.2];
            
        }];
        
        
        
        
    }else //!< 当前处于录制状态
    {
        //!<  recording
        NSString *setNotRecUrl = [DVRHost stringByAppendingString:@"type=system&action=setrecstatus&recstat=0"];
        
        [self.session GET:setNotRecUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"停止录制";
            [hud hide:YES afterDelay:0.2];
            
            //!< 设置按钮状态，销毁定时器，隐藏倒计时
            
            if (isFull)
            {
                //!< 全屏状态发送停止录制指令成功
                 self.fullScreenVideoBtn.selected = NO;
                
                self.fullScreenTwinkleBtn.hidden = YES;
                
                self.fullScreenTimeLabel.hidden = YES;
                
                self.fullScreenTimeLabel.text = @"";
                
            }else
            {
                //!< 非全屏状态发送停止录制指令成功
                self.timeLabel.hidden = YES;
                
                self.twinkleBtn.hidden = YES;
                
                self.timeLabel.text = @"";
                
                self.recordBtn.selected = NO;

            
            }
                      
            [self.timer invalidate];
            
            self.timer = nil;
            
            
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
           
            
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"操作失败";
            [hud hide:YES afterDelay:0.2];
            
         
            
        }];
        
    }

    

}



- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;
}


#pragma mark --- notification

- (void)userManualChangeRecordStatus:(NSNotification *)noti
{
   NSInteger status = [noti.userInfo[@"info"] integerValue];
    
    if (status)
    {
        //!< 开始录制
        
        if (self.timer)
        {
            return;
        }
        
        [self getRecordTime];
        
        
    }else
    {
        //!< 停止录制
        
        if(self.timer)
        {
            [self.timer invalidate];
            
            self.timer = nil;
            
            self.twinkleBtn.hidden = YES;
            
            self.timeLabel.hidden = YES;
        
            self.timeLabel.text = @"";
        
        }
    
    
    
    }
    
    
}

//!< 点击返回按钮
- (void)backToLast
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (tempAppDelegate.sliderVC.closed)
    {
        [tempAppDelegate.sliderVC openLeftView];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

/**
 *  计算角度
 *
 *  @return 角度
 */
-(CGFloat)angleForStartPoint:(CGPoint)startPoint EndPoint:(CGPoint)endPoint{
    
    CGPoint Xpoint = CGPointMake(startPoint.x + 100, startPoint.y);
    
    CGFloat a = endPoint.x - startPoint.x;
    CGFloat b = endPoint.y - startPoint.y;
    CGFloat c = Xpoint.x - startPoint.x;
    CGFloat d = Xpoint.y - startPoint.y;
    
    CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
    
    //    if (startPoint.y>endPoint.y) {
    //        rads = -rads;
    //    }
    return rads * 180 / M_PI;
}



@end






    
    
    
    
    
    
    
    
