//
//  XMMonitorViewController.m
//  KuRuiBao
//
//  Created by x on 16/6/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
/***********************************************************************************************
 一级页面 监控汽车状态，包括启程行驶状态及其他的一些相关信息
 
 
 ************************************************************************************************/


#import "XMMonitorViewController.h"

#import "AppDelegate.h"

#import "UIViewController+alert.h"

#import "XMTabBarButton.h"

#import "XMMessageViewController.h"

#import "AFNetworking.h"

#import "XMUser.h"

#import "XMDefaultCarModel.h"

#import "NSDictionary+convert.h"

#import "XMAddViewController.h"

#import "XMCheckView.h"

#import "XMTroubleItemModel.h"

#import "XMMonitorTroubleShowViewController.h"

#import "MenuView.h"

#import "JPUSHService.h"

#import "XMCompanyCarListViewController.h"

#import "XMSearchBar.h"

#import "XMCompanySearchViewController.h"

#import "XMHistoryRecordViewController.h"

#import "XMScrollView.h"

#import "UMTool.h"

//!< 控制分数的等级
#define level_1 90

#define level_2 75

#define kUpdateStateTimeinterval 8 //更新默认车辆状态时间间隔

//-- 点击cell发送通知的名称  在这个控制器里边监听这个通知
#define kXMSettingCellDidClickNotification @"kXMSettingCellDidClickNotification"

#define kCheXiaoMiUserAllCarDidUpdateNotification @"kCheXiaoMiUserAllCarDidUpdateNotification"


@interface XMMonitorViewController ()<UIAlertViewDelegate,XMCheckViewDelegate>

//-----------------------------seperate line---------------------------------------//
@property (assign, nonatomic) BOOL isApns;

@property (nonatomic,weak)UILabel* stateLabel;//!<  显示车况信息(状态良好)

@property (nonatomic,weak)UILabel* scoreLabel;//!< 显示分数（100分)

@property (nonatomic,weak)UIImageView* centerIV;//!< 中间大圆

//@property (nonatomic,weak)UILabel* percentageLabel;//!< 显示百分号

@property (nonatomic,weak)UIButton* checkBtn;//!< 检测按钮

@property (strong, nonatomic) NSMutableArray *labelArr;//!< 存放小标题的label数组

@property (strong, nonatomic) NSMutableArray *btnArr;//!< 存放btn的数组

@property (strong, nonatomic) NSArray *titleArr;//!< PBCU数组

//-----------------------------seperate line---------------------------------------//

@property (nonatomic,strong)XMDefaultCarModel* defaultCar;//->>当前默认车辆

@property (strong, nonatomic) XMCar *deliverCar;//!< 传给企业用户的汽车模型

@property (nonatomic,weak)UIButton* carNumber;//->>更新导航栏中间车牌号

@property (strong, nonatomic)  AFHTTPSessionManager *session;

@property (assign, nonatomic) BOOL isConnect;//!< 是否连接到网络

@property (copy, nonatomic) NSString *recordNumber;//!< 下发给终端的记录编号

@property (copy, nonatomic) NSString *tboxid;//!< 默认车辆的终端编号（如果车两没有激活成功，服务器激活成功后返回）

@property (strong, nonatomic) NSArray *troubleInfo;//!< 故障码信息

@property (assign, nonatomic) BOOL noTrouble;//!< 是否存在故障信息（检测结果是否为100）

@property (assign, nonatomic) BOOL userAction;//!< 是否是用户在操作指令  用来区分程序预处理阶段和用户处理阶段

@property (assign, nonatomic) BOOL isCheckSuccess;//!< 是否已经检测车辆信息成功，没成功cell不可点

@property (assign, nonatomic) int troubleScore;

@property (nonatomic,weak)XMCheckView* checkView;

@property (strong, nonatomic) NSMutableDictionary *troubleItemDictionary;//!< 问题项模型数组

@property (copy, nonatomic) NSString *Gpsdatetime;//!<上次定位时间，用来获取实时数据

@property (strong, nonatomic) NSArray *carList;//!< 用户所有车辆

/**
 更新实时数据的定时器
 */
@property (strong, nonatomic) NSTimer *realTimer;


/**
 底部轮播视图
 */
@property (weak, nonatomic) XMScrollView *scrollView;

/**
 显示行驶状态
 */
@property (weak, nonatomic) UILabel *driveState;

/**
 检测动画定时器
 */
@property (strong, nonatomic) NSTimer *animateTimer;

@end

@implementation XMMonitorViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        //!< 监听收到APNS通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kCheXiaoMiDidReceiveRemoteNotification object:nil];
        
        if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable)
        {
            self.isConnect = YES;
        
        }else
        {
            self.isConnect = NO;
        
        }
        
        //!< 获取所有车辆
        [self getUserAllCars];
        
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"typeId"] == 1) {
            
            //!< 获取用户默认车辆
            [self getDefaultCarInfo];
            
            [self updatePushID];//!< 是否更新pushid
            
            
        }
       
        
    }
    
    return self;
}


#pragma mark --- life cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //监听通知
    [self addObserver];
    
    //初始化信息
    [self setupInfo];
    
    
    
    
}


- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    
    MobClickBegain(@"监控主界面");

}

#pragma mark --- init
/**
 *  设置初始化信息
 */
- (void)setupInfo
{
    
    //!< 初始化按钮和label数组
    self.labelArr = [NSMutableArray arrayWithCapacity:4];
    
    self.btnArr  = [NSMutableArray arrayWithCapacity:4];
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    
    //-----------------------------seperate line---------------------------------------//
    
     //->>创建背景图，覆盖整个view
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, mainSize.height)];
    
    backgroundView.image = [UIImage imageNamed:@"monitor_background"];
    
    [self.view addSubview:backgroundView];
    
    //-----------------------------seperate line---------------------------------------//
    
   
    //->>侧滑按钮
    XMTabBarButton *leftBtn = [XMTabBarButton buttonWithType:UIButtonTypeCustom];

    [leftBtn setImage:[UIImage imageNamed:@"monitor_leftNaviItem"] forState:UIControlStateNormal];
    
    [leftBtn addTarget:self action:@selector(leftBarButtonItemClick) forControlEvents:UIControlEventTouchDown];
    
     [self.view addSubview:leftBtn];
    
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
 
         make.top.equalTo(backgroundView).offset(27);
        
         make.size.equalTo(CGSizeMake(30, 30));
        
         make.left.equalTo(backgroundView).offset(7);
    }];
    
    //!< 添加搜索框
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monitor_search_back"]];
    
    imageView.userInteractionEnabled = YES;
    
    [self.view addSubview: imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(leftBtn.mas_right).offset(8);
        
        make.top.equalTo(backgroundView).offset(31);
        
        make.height.equalTo(23);
        
        make.width.equalTo(FITWIDTH(273));
        
    }];
    
    //!< 添加放大镜
    UIImageView *glass = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monitor_search"]];
    
    [imageView addSubview:glass];
    
    [glass mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(imageView).offset(8);
        
        make.size.equalTo(CGSizeMake(12, 12));
        
        make.centerY.equalTo(imageView);
        
    }];
    
    //!< 添加文字
    UILabel *textLabel = [UILabel new];
    
    textLabel.text = @"输入车牌号进行查询";
    
    textLabel.textColor = XMGrayColor;
    
    textLabel.font = [UIFont systemFontOfSize:14];
    
    [imageView addSubview:textLabel];
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(glass.mas_right).offset(10);
        
        make.height.equalTo(13);
        
        make.right.equalTo(imageView);
        
        make.centerY.equalTo(imageView);
        
    }];
    
    //!< 添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchClick)];
    
    [imageView addGestureRecognizer:tap];
    
    
    //->>消息按钮
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn addTarget:self action:@selector(rightBarButtonItemClick) forControlEvents:UIControlEventTouchDown];
    
    [rightBtn setImage:[UIImage imageNamed:@"monitor_rightNaviItem"] forState:UIControlStateNormal];
    
    [self.view addSubview:rightBtn];
    
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(backgroundView).offset(27);
        
        make.right.equalTo(backgroundView).offset(-7);
        
        make.size.equalTo(CGSizeMake(30, 30));
        
    }];
    
    
    //->>车牌号
     UIButton *carNumber = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [carNumber setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    carNumber.titleLabel.font = [UIFont boldSystemFontOfSize:25];
 
    [carNumber setTitle:@"" forState:UIControlStateNormal];
    
    //!< 按钮点击事件为显示历史记录
    [carNumber addTarget:self action:@selector(righrArrowClick:event:) forControlEvents:UIControlEventTouchUpInside];
    
    carNumber.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    carNumber.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    carNumber.tag = 999;
    
    [self.view addSubview:carNumber];
    
    self.carNumber = carNumber;
    
     [carNumber mas_makeConstraints:^(MASConstraintMaker *make) {
   
        make.top.equalTo(imageView.mas_bottom).offset(FITHEIGHT(32));
         
        make.left.equalTo(backgroundView).offset(29);
         
        make.height.equalTo(25);
         
//        make.width.equalTo(200);
         make.right.equalTo(backgroundView).offset(-20);
        
    }];
    
    //!< 添加右边的箭头
    UIButton *rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightArrow setImage:[UIImage imageNamed:@"monitor_rightArrow"] forState:UIControlStateNormal];
    
    [rightArrow addTarget:self action:@selector(righrArrowClick:event:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:rightArrow];
    
    [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(backgroundView).offset(-15);
        
        make.size.equalTo(CGSizeMake(14, 25));
        
        make.centerY.equalTo(carNumber);
        
    }];
    
    //!< 显示行驶状态
    UILabel *driveStateLabel = [UILabel new];
    
    driveStateLabel.textColor = XMGrayColor;
    
    driveStateLabel.text = @"行驶状态";
    
    driveStateLabel.font = [UIFont systemFontOfSize:11];
    
    if (!isCompany)
    {
        driveStateLabel.hidden = YES;
        
        driveStateLabel.alpha = 0;
    }
    
    [self.view addSubview:driveStateLabel];
    
    self.driveState = driveStateLabel;
    
    [driveStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(carNumber);
        
        make.top.equalTo(carNumber.mas_bottom).offset(FITHEIGHT(12));
        
        make.size.equalTo(CGSizeMake(200, 11));
        
    }];
    
    
 //-----------------------------seperate line---------------------------------------//
    
    //!< 最中间大圆背景 上半部分的适配都以背景圆为基准
//    
//    CGFloat circleWidth = mainSize.height > 480 ? 210 : 190;
//    CGFloat circleMargin = mainSize.height > 480 ? 42 : 20;
    
    UIImageView *centerBackIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    
    
    [self.view addSubview:centerBackIV];
    
 
    
    XMLOG(@"---------0000000000000%@---------",NSStringFromCGRect([UIScreen mainScreen].bounds));
    
    
     
    if (mainSize.width == 320)
    {
        
        [centerBackIV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(backgroundView);
            
            make.size.equalTo(CGSizeMake(FITHEIGHT(150),FITHEIGHT(150)));
            
            make.top.equalTo(carNumber.mas_bottom).offset(FITHEIGHT(15));
            
        }];
        
    }else
    {
        [centerBackIV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(backgroundView);
            
            make.size.equalTo(CGSizeMake(FITHEIGHT(180),FITHEIGHT(180)));
            
            make.top.equalTo(driveStateLabel.mas_bottom).offset(FITHEIGHT(20));
            
        }];
    
    }
    
    
    
    
    //!< 要显示的大圆
    UIImageView *centerIV = [[UIImageView alloc]init];
    
    [self.view addSubview:centerIV];
    
    self.centerIV = centerIV;
    
    [centerIV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.equalTo(centerBackIV);
        
        make.size.equalTo(centerBackIV);
        
     }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 获取上一次保存的数据 显示字体颜色都根据上一次的结果来显示
    NSString *lastScore = [df objectForKey:@"lastScore"];
    
    UIColor *color;//!< 检测部分颜色
    
    NSString *title = lastScore ? @"上次体检结果" : @"点我进行体检";
    
    if (lastScore.intValue >= 90)
    {
        color = XMGreenColor;
        
        centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_green"];
        
       
        
    }else if (lastScore.intValue >= 75)
    {
        color = XMPurpleColor;
        
        centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_purple"];
        
        
        
    }else if(lastScore.intValue > 0)
    {
        
        color = XMRedColor;
        
        centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_red"];
        
       
        
    }else
    {
         //!< 上次没有数据
        color = XMGrayColor;
        
        centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_gray"];
        
        lastScore = @"100";
    }

    lastScore = [lastScore stringByAppendingString:@"%"];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示车况的label
    UILabel *stateLabel = [UILabel new];
    
    stateLabel.font = [UIFont systemFontOfSize:11];
    
    stateLabel.textColor = color;
    
    stateLabel.textAlignment = NSTextAlignmentCenter;
    
    stateLabel.text = title;
    
    [self.view addSubview:stateLabel];
    
    self.stateLabel = stateLabel;
        
    [stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(centerIV).offset(-FITHEIGHT(39));
        
        make.centerX.equalTo(centerIV);
        
        make.height.equalTo(9);
        
        make.width.equalTo(150);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:lastScore];
    
    NSRange range = [lastScore rangeOfString:@"%"];
    
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22] range:range];
    
    //!< 分数
    UILabel *scoreLabel = [UILabel new];

    scoreLabel.font = [UIFont systemFontOfSize:mainSize.width == 320 ? 40 : 65];

    scoreLabel.textColor = color;
    
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    
    scoreLabel.attributedText = str;
    
    scoreLabel.adjustsFontSizeToFitWidth = YES;//!< 根据宽度调整字体
    
    [self.view addSubview:scoreLabel];
    
    self.scoreLabel = scoreLabel;
    
     [scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(stateLabel.mas_top).offset(-FITHEIGHT(mainSize.width == 320 ? 9 : 19));
        
         make.centerX.equalTo(centerIV);
        
         make.height.equalTo(FITHEIGHT(65));
        
         make.width.equalTo(centerIV);
        
    }];
 
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加检测按钮
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [checkBtn addTarget:self action:@selector(checkBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    checkBtn.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:checkBtn];
    
    self.checkBtn = checkBtn;
    
    [checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.equalTo(centerIV);
        
        make.size.equalTo(centerIV);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加下边四项内容
    
    CGFloat width = (mainSize.width - 30) / 4;
    
    NSArray *titleArr = @[@"发动机系统",@"电子刹车系统",@"车身控制系统",@"车辆其他项"];
    
    UIButton *stateBtn;
    
    CGFloat labelMargin = mainSize.height> 480 ? 33 : 18;
    
    float fotSize = mainSize.width > 320 ? 13 : 11;
    
    CGFloat btnMargin = mainSize.height > 480 ? 16 : 12;
    
     for (int i = 0;i < titleArr.count; i++)
    {
        
        //!< 第一排label
        UILabel *engineLabel = [UILabel new];
        
        engineLabel.adjustsFontSizeToFitWidth = YES;
        
        engineLabel.text = titleArr[i];
        
        engineLabel.textColor = [UIColor whiteColor];
        
        engineLabel.textAlignment = NSTextAlignmentCenter;
        
        engineLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:fotSize];
        
        [self.view addSubview:engineLabel];
        
        [engineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(backgroundView).offset(15 + width * i);
            
            make.top.equalTo(centerIV.mas_bottom).offset(FITHEIGHT(labelMargin));
            
            make.height.equalTo(12);
            
            make.width.equalTo(width);
            
        }];
        
        
        //!< 添加第二排Label
        UILabel *subLabel = [UILabel new];
        
        subLabel.textColor = XMGrayColor;
        
        subLabel.font = [UIFont systemFontOfSize:12];
        
        subLabel.text = @"未检测";
        
        subLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:subLabel];
        
        [self.labelArr addObject:subLabel];
        
        [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerX.equalTo(engineLabel);
            
            make.top.equalTo(engineLabel.mas_bottom).offset(9);
            
            make.width.equalTo(engineLabel);
            
            make.height.equalTo(9);
            
            
        }];
        
        //!< 添加底部图片
        
        stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [stateBtn setImage:[UIImage imageNamed:@"monitor_check_wait"] forState:UIControlStateDisabled];
        
        stateBtn.enabled = NO;
        
        stateBtn.tag = i;
        
        [stateBtn addTarget:self action:@selector(troubleBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:stateBtn];
        
        [self.btnArr addObject:stateBtn];
     
        [stateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
             make.top.equalTo(subLabel.mas_bottom).offset(FITHEIGHT(btnMargin));
            
            make.size.equalTo(CGSizeMake(32, 32));
            
            make.centerX.equalTo(subLabel);
        }];
      }
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加底部的滚动视图
    
    XMScrollView *bottomView = [[XMScrollView alloc]init];
    
    [self.view addSubview:bottomView];
    
    self.scrollView = bottomView;
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.equalTo(self.view);
        
        make.top.equalTo(stateBtn.mas_bottom).offset(FITHEIGHT(20));
        
        make.bottom.equalTo(self.view).offset(-64);
    }];
    
}


/**
 *  监听通知
 */
- (void)addObserver
{
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    //-- 监听点击主设置界面cell的通知 跳转到对应的控制器
    [center addObserver:self selector:@selector(settingCellDidClick:) name:kXMSettingCellDidClickNotification object:nil];
    
    
    //->>监听车辆设置界面修改为默认车辆发送的通知
    [center addObserver:self selector:@selector(defaultCarDidChanged:) name:kCheXiaoMiUserSetDefaultCarSuccessNotification object:nil];

    
    //!< 监听网络变化的通知
    [center addObserver:self selector:@selector(networkDidChanged:) name:XMNetWorkDidChangedNotification object:nil];
    
    
    //!< 监听进入后台的通知
    [center addObserver:self selector:@selector(applicationWillEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    
    
    //!< 监听进入前台的通知
    [center addObserver:self selector:@selector(applicationWillBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //!< 监听用户新添加车辆的通知
    [center addObserver:self selector:@selector(userAllCarsInfoDidUpDate:) name:kCheXiaoMiUserAllCarDidUpdateNotification object:nil];
    
    
    //!< 监听用户选择企业车辆的通知
    [center addObserver:self selector:@selector(companyUserDidSelectedCar:) name:kXMShowCarVCCellClickNotification object:nil];
    
    
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

- (NSMutableDictionary *)troubleItemDictionary
{
    if (!_troubleItemDictionary)
    {
        _troubleItemDictionary = [NSMutableDictionary dictionary];
        
        [_troubleItemDictionary setValue:[NSMutableArray array] forKey:@"P"];
        [_troubleItemDictionary setValue:[NSMutableArray array] forKey:@"B"];
        [_troubleItemDictionary setValue:[NSMutableArray array] forKey:@"C"];
        [_troubleItemDictionary setValue:[NSMutableArray array] forKey:@"U"];
    }

    return _troubleItemDictionary;

}

- (NSArray *)titleArr
{

    if (!_titleArr)
    {
        _titleArr = @[@"P",@"B",@"C",@"U"];
    }
    
    return _titleArr;

}

#pragma mark -------------- 按钮点击事件

//!< 点击检测按钮
- (void)checkBtnDidClick:(UIButton *)sender
{
    
  
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        //!< 网络连接失败
        [self showAlertWithMessage:@"网络连接失败" btnTitle:@"确定"];
        
        return;
    
    }
    
    //!< 用户第一次点击
    if ((self.defaultCar && self.defaultCar.chepaino.length == 0))
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"还没有添加车辆是否去添加" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        alert.tag = 100;
        
        [alert show];
        
        return;
    }
 
     sender.enabled = NO;
    
    if (isCompany)
    {
        
        switch (self.defaultCar.currentstatus.integerValue)
        {
            case 0:
                
                 [self showAlertWithMessage:@"车辆为停止状态" btnTitle:@"确定"];
                
                sender.enabled = YES;

                break;
                
            case 1:
                
                //-- 如果是企业用户直接发送检测指令
                //!< 终端编号存在，发送检测指令
                self.userAction = YES;
                
                
                
                [self sendCheckCommand];
                
                break;
                
            case 2:
                
                 [self showAlertWithMessage:@"车辆为失联状态" btnTitle:@"确定"];
                
                 sender.enabled = YES;
                
                break;
                
            default:
                break;
        }
        
        
     
        
    }else
    {
    
        //!< 用户默认车辆存在，且车牌号，汽车id都存在  判断是否激活
        if([_defaultCar.tboxid intValue] > 0)
        {
            
            //!< 终端编号存在，发送检测指令
            self.userAction = YES;
            
            [self sendCheckCommand];
            
        }else
        {
            
            self.userAction = YES;//!< 标志当前为用户在操作指令
            
            //!< 还未激活,发送激活指令
            [self sendActiveCommand];
            
            
        }

    
    
    }
    

    
}

//!< 点击项目按钮,推出显示问题项的控制器
- (void)troubleBtnDidClick:(UIButton *)sender
{
    
    NSString *title = self.titleArr[sender.tag];
    
    NSMutableArray *troubleArr = [self.troubleItemDictionary objectForKey:title];
    
    XMMonitorTroubleShowViewController *showVC = [XMMonitorTroubleShowViewController new];
    
    showVC.troubleArray = troubleArr;
    
    showVC.hidesBottomBarWhenPushed = YES;
    
    showVC.index = sender.tag;
    
    showVC.qicheid = _defaultCar.qicheid;
    
    showVC.userid = _defaultCar.userid;
    
    [self.navigationController pushViewController:showVC animated:YES];
    
    
}

/**
 点击搜索框
 */
- (void)searchClick
{
    XMCompanySearchViewController *vc = [XMCompanySearchViewController new];
    
    vc.allCars = self.carList;
    
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    XMLOG(@"---------点击搜索框---------");
    
}

/**
 点击历史记录按钮
 */
- (void)righrArrowClick:(UIButton *)sender event:(UIEvent *)event
{
    XMLOG(@"--------- 点击历史记录按钮---------");
    
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showError:@"网络未连接"];
        
        return;
    
    }
    
    XMHistoryRecordViewController * vc = [XMHistoryRecordViewController new];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    vc.qicheid =  self.defaultCar.qicheid;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    if (sender.tag == 999)
    {
        //!< 友盟统计
        
        UITouch *touch = [event.allTouches anyObject];
        
        CGPoint p = [touch locationInView:sender];
        
        CGFloat w = CGRectGetWidth(sender.bounds);
        
        float percentage = p.x / w;
        
        NSString *value = percentage < 0.6 ? @"左" : @"右";
        
        NSString *location_touch = NSStringFromCGPoint(p);
        
        NSString *btnBounds = NSStringFromCGRect(sender.bounds);
        
        [MobClick event:@"Car_FaultCode" attributes:@{@"result":value}];
        
        XMLOG(@"---------youmeng 点坐标：%@，按钮大小：%@--比例：%f-------",location_touch,btnBounds,percentage);
        
        
        
        
    }
    
}


- (void)setDriveState
{
    
    //!< 每隔10秒去更新当前默认车辆的状态
    switch (self.defaultCar.currentstatus.integerValue)
    {//!< 0 停驶  1 行驶  2 失联
        case 0:
            
            self.driveState.text = @"停驶";
            
            if (_scrollView.isAnimating)
            {
                [_scrollView stop];
            }
            
            
            break;
        case 1:
            
            if (_scrollView.isAnimating == NO )
            {
                [self openRealTimeMonitor];
            }
            
            self.driveState.text = @"行驶中";
            
            break;
        case 2:
            
            self.driveState.text = @"失联";
            
            if (_scrollView.isAnimating)
            {
                [_scrollView stop];
            }
            
            break;
            
        default:
            break;
    }

    
    
}



#pragma mark --- 指令操作

 //!< 获取用户所有车辆
- (void)getUserAllCars
{

    if (isCompany)
    {
        [self getUserAllCars_company];
        
        return;
        
    }
   
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_list&Userid=%ld",(long)[XMUser user].userid];
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        NSString *stateCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([stateCode isEqualToString:@"0"])
        {
            XMLOG(@"---------获取个人用户车辆信息返回0 ---------");
            [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil userInfo:@{@"mode":@"cars",@"result":@[]}];
            
            return ;
        }else if ([stateCode isEqualToString:@"-1"])
        {
            XMLOG(@"---------获取个人用户车辆信息返回-1 ---------");
            return;
        }
        
        
        
        NSArray *carList = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSMutableArray *mutableCars = [NSMutableArray array];
        
        for (NSDictionary *dic in carList)
        {
            XMCar *car = [[XMCar alloc]initWithDictionary:dic];
            
            [mutableCars addObject:car];
            
        }
        
        self.carList = [mutableCars copy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil userInfo:@{@"mode":@"cars",@"result":mutableCars}];
        
        XMLOG(@"成功获取用户车辆列表");
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        XMLOG(@"获取用户汽车列表失败");
        
    }];


}


//!< 获取用户所有车辆在企业账户登录的时候
- (void)getUserAllCars_company
{
    
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"c_qiche_list&companyid=%ld&Page=1&Pagesize=100000",(long)[XMUser user].companyid];
    
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *stateCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([stateCode isEqualToString:@"0"])
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil userInfo:@{@"mode":@"cars",@"result":@[]}];
            
            return ;
            
        }else if ([stateCode isEqualToString:@"-1"])
        {
            
            XMLOG(@"用户没有车辆信息");

            self.carList = nil;
            
            return;
        }
        
        
        //!< 有车辆信息
        //-- 转换模型，保存用户所有车辆
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSArray *carList = result[@"rows"];
        
        NSMutableArray *mutableCars = [NSMutableArray array];
        
        for (NSDictionary *dic in carList)
        {
            XMCar *car = [[XMCar alloc]initWithDictionaryForCompany:dic];
            
            [mutableCars addObject:car];
            
        }
        
        self.carList = [mutableCars copy];
        
        //-- 设置第一辆车为默认车辆
        self.defaultCar = [self changeCarToDefault:mutableCars.firstObject];
        
        //!< 设置行驶状态
        [self setDriveState];
        
        if (self.defaultCar.currentstatus.integerValue == 1)
        {
            //!< 行驶状态，开启实时监控
            [self openRealTimeMonitor];
            
            
        }
        
        //-- 应该开启一个定时器，间隔固定的时间去判断当前车辆的状态
        NSTimer *timer = [NSTimer timerWithTimeInterval:kUpdateStateTimeinterval repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            if (self.view.window == nil)
            {
                //-- 当前不在主界面就不更新
                return ;
            }
            
            //!< 之请求当前默认车辆车牌一一致的车辆信息
            NSString *urlStr = [mainAddress stringByAppendingFormat:@"c_qiche_list&companyid=%ld&Skey=%@",(long)[XMUser user].companyid,self.defaultCar.chepaino];
            
            urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
               
                
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                
                NSArray *arr = result[@"rows"];
                
                NSDictionary *dic = arr.firstObject;
                
                //-- 更新默认车辆状态
                self.defaultCar.currentstatus = [NSString stringWithFormat:@"%@",dic[@"currentstatus"]];
                
                self.deliverCar.currentstatus = self.defaultCar.currentstatus.integerValue;
                
                //!< 更新行驶状态
                [self setDriveState];
                 XMLOG(@"更新默认车辆信息成功");
                XMLOG(@"---------%@---------",dic[@"chepaino"]);
                
            } failure:nil];

            
        }];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        
        
        [self.carNumber setTitle:self.defaultCar.chepaino forState:UIControlStateNormal];
        
        //-- 更新默认车辆和全部车辆的通知
        //-- 发送通知通知其他界面数据更新
        [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil userInfo:@{@"mode":@"cars",@"result":mutableCars}];
        
        //-- 发送通知通知其他界面数据更新
        [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil userInfo:@{@"mode":@"car",@"result":self.defaultCar}];
        
        XMLOG(@"成功获取用户车辆列表");
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"获取用户汽车列表失败，网络原因");
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         [_carNumber setTitle:nil forState:UIControlStateNormal];
        
    }];
    
}

//-- 企业对应的车辆模型转换成默认车辆数据模型
- (XMDefaultCarModel *)changeCarToDefault:(XMCar *)car
{
    self.deliverCar = car;
    
    XMDefaultCarModel *dCar = [XMDefaultCarModel new];
    
    dCar.mobil = car.mobil;
        
    dCar.userid = [NSString stringWithFormat:@"%ld",car.userid];
    
    dCar.companyid = [NSString stringWithFormat:@"%ld",car.companyid];
    
    dCar.qicheid = [NSString stringWithFormat:@"%ld",car.qicheid];
    
    dCar.chepaino = car.chepaino;
    
    dCar.tboxid = [NSString stringWithFormat:@"%ld",car.tboxid];
    
    
    dCar.imei = car.imei;
    
    dCar.carbrandid = [NSString stringWithFormat:@"%ld",car.brandid];
    
    dCar.carseriesid = [NSString stringWithFormat:@"%ld",car.seriesid];
    
    dCar.carstyleid = [NSString stringWithFormat:@"%ld",car.styleid];
    
    dCar.brandname = car.brandname;
    
    dCar.seriesname = car.seriesname;
    
    dCar.stylename = car.stylename;
    
    
    
    dCar.currentstatus = [NSString stringWithFormat:@"%ld",car.currentstatus];
    
    return dCar;
    
}
/**
 *  初始化的时候获取用户默认车辆信息
 */
- (void)getDefaultCarInfo
{

    XMUser *user = [XMUser user];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"user_qiche_first_get&Userid=%d",(int)user.userid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        NSString * result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] ;
        
        if ([result isEqualToString:@"-1"])
        {
            XMLOG(@"初始化时获取默认车辆信息失败，error：网络错误");//!< 请求失败，不执行操作，点击体检按钮会再判断
            
        }else if([result isEqualToString:@"0"])
        {
            
            //!< 只有用户编号错误的时候出现这种错误 可以排除用户标号错误的情况
        
        }else{
            
           XMLOG(@"初始化时获取用户默认车辆成功");
            
            //!< 转模型
            NSArray *carInfo = (NSArray *)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            NSDictionary *dic = [NSDictionary nullDic:[carInfo firstObject]];
            
            self.defaultCar = [XMDefaultCarModel defaultWithDictionary:dic];
            
            //!< 发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil userInfo:@{@"mode":@"car",@"result":self.defaultCar}];
            
            //!< 设置标题 在页面加载完毕时候调用
            if(_defaultCar.chepaino.length > 4)
            {
                [_carNumber setTitle:_defaultCar.chepaino forState:UIControlStateNormal];

            }else
            {
                //!< 用户没有添加车辆，设置主界面顶部的体检信息
//                [_carNumber setTitle:@"无车辆" forState:UIControlStateNormal];
                
                self.centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_gray"];
                
//                self.stateLabel.text = @"未添加车辆";
                
                self.stateLabel.textColor = XMGrayColor;
                
                self.scoreLabel.textColor = XMGrayColor;
                
                self.scoreLabel.text = @"0";
                
                
              
            
            }
            //!< 车牌号大于0且汽车编号大于0（长度） 则有默认车辆存在，可以进行下一步操作
            if(_defaultCar.chepaino.length > 0 && _defaultCar.qicheid.length > 0)
            {
                XMLOG(@"用户默认车辆存在。准备检测是否激活");
                //!< 用户默认车辆存在，进行下一步操作
                 //!< 检测车辆当前状态
                [self checkCarState];
            
             }
            
           
            
         }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"初始化时获取默认车辆失败，error：网络错误");//请求失败，不执行操作，点击体检按钮是会再判断
         [_carNumber setTitle:nil forState:UIControlStateNormal];
    }];
    
}

//!< 用户有默认车辆存在
- (void)checkCarState
{
    //!< 检测tboxid是否有值，有值说明已经激活成功 可以发送检测指令，没有值还没有激活成功，发送激活指令
    if ([_defaultCar.tboxid intValue] > 0)
    {
         XMLOG(@"设备已经激活过，向服务器下发检测指令");
        //已经激活过了 打开实时监控

         [self openRealTimeMonitor];
        
    }else
    {
        XMLOG(@"设备还未激活，下发激活指令");
        
        //还没有激活  //!< 发送激活指令
         [self sendActiveCommand];
    
    }
   
    
}


//!< 发送激活指令
- (void)sendActiveCommand
{
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Active&Userid=%@&Qicheid=%@",_defaultCar.userid,_defaultCar.qicheid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        int statusCode = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
        
        if (statusCode == -1)
        {
            
            //!< 设备激活失败 失败原因，网络错误
            
            [self hideHUD];
            
            if (_userAction)
            {
                [self showAlertWithMessage:@"通讯失败" btnTitle:@"确定"];
                 self.checkBtn.enabled = YES;//!< 激活检测按钮
                 self.userAction = NO;
            }
          XMLOG(@"设备激活失败，原因：网络错误");
           
            
        }else if(statusCode == 0)
        {
        
            //!< 设备激活失败，失败原因，终端不在线
            [self hideHUD];
            
            if (_userAction)
            {
                [self showAlertWithMessage:@"终端不在线" btnTitle:@"确定"];
                 self.checkBtn.enabled = YES;//!< 激活检测按钮
                self.userAction = NO;
            }
             XMLOG(@"设备激活失败，原因：终端不在线");
         
        }else if(statusCode > 0)
        {
        
            XMLOG(@"设备激活成功，返回的结果（终端编号）为：%d",statusCode);
            //!< 激活成功，服务器返回终端编号
            self.tboxid = [[NSString alloc]initWithFormat:@"%d",statusCode ];
            
            //!< 获取到终端编号 发送检测指令
            
            _defaultCar.tboxid = self.tboxid;
            
            if (_userAction)
            {
                [self sendCheckCommand];//!< 如果是用户操作就发送检测指令
            }
        
            
         
         }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //!<激活失败，不执行操作
        XMLOG(@"设备激活失败，网络错误");
        
        [self hideHUD];
        if (_userAction)
        {
            [self showAlertWithMessage:@"通讯失败" btnTitle:@"确定"];
             self.checkBtn.enabled = YES;//!< 激活检测按钮
            self.userAction = NO;
        }
        
    }];
    
    
}

//!< 发送检测指令
- (void)sendCheckCommand
{
 
    XMUser *user = [XMUser user];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"sendcommand&userid=%ld&qicheid=%@&tboxid=%@&commandtype=50&subtype=0",user.userid,_defaultCar.qicheid,_defaultCar.tboxid];
    
    [MBProgressHUD showMessage:nil];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUD];
        
        int result = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
        
        if (result == 0)
        {
            XMLOG(@"发送检测指令成功，但是终端不在线");
            
            [self hideHUD];
            
            if (_userAction)
            {
                [self showAlertWithMessage:@"终端不在线" btnTitle:@"确定"];
                 self.checkBtn.enabled = YES;//!< 激活检测按钮
                
                 self.userAction = NO;
                
                [_scrollView stop];
                
 
                
            }
            
              [XMCheckManager shareManager].isChecking = NO;
            
        }else if(result == -1)
        {
            
            XMLOG(@"发送检测指令成功，但是网络异常");
            [self hideHUD];
            
            
            
            
            if (_userAction)
            {
                [self showAlertWithMessage:@"通讯失败" btnTitle:@"确定"];
                self.userAction = NO;
                 self.checkBtn.enabled = YES;//!< 激活检测按钮

                [XMCheckManager shareManager].isChecking = NO;
            
            }
            
        }else
        {
          
            //!< 下发指令成功，记录下发给终端的记录编号，过几秒用终端编号获取检测结果
            self.recordNumber = [[NSString alloc]initWithFormat:@"%d",result];
            
            XMLOG(@"检测指令发送成功，开始进行检测，下发给终端的记录编号为%@",self.recordNumber);
            
            self.stateLabel.text = @"体检中";
            
             if(_userAction)
             {
                
                //!< 清空数组
                for (NSString *key in self.troubleItemDictionary.allKeys)
                {
                    
                    NSMutableArray *arr = [self.troubleItemDictionary objectForKey:key];
                    
                    [arr removeAllObjects];
                    
                    
                }
            
                 
                //!<  在用户设置默认车辆的时候，进行判定
                [XMCheckManager shareManager].isChecking = YES;
              
                 [self.carNumber setTitleColor:XMGrayColor forState:UIControlStateNormal];
                 
                 //!< 开始检测动画
                 [self startCheckAnimate];
 
                 
            //!< 10秒后后去检测结果
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                //!< 获取检测结果
                [self getCheckedResult];
                
               
                
            });
                
            }
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUD];
        
        XMLOG(@"发送检测指令时，网络错误");
        if (_userAction)
        {
            [self showAlertWithMessage:@"通讯失败" btnTitle:@"确定"];
             self.checkBtn.enabled = YES;//!< 激活检测按钮
            self.userAction = NO;
            
            [XMCheckManager shareManager].isChecking = NO;
        }
        
    }];
    
    
}


- (void)startCheckAnimate
{
    XMLOG(@"---------------------------执行方法");
    
    //!< 修改图片，修改文字
    for (int i = 0;i<4;i++)
    {
        UIButton *btn = self.btnArr[i];
        
        [btn setImage:[UIImage imageNamed:@"monitor_check_wait"] forState:UIControlStateDisabled];
        btn.enabled = NO;
        
        UILabel *label = self.labelArr[i];
        
        label.text = @"等待检测";
        
    }
    
    [self startWithIndex:0];//!< 开始第一个动画
 
    self.animateTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(executeAnimateWithTimer) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.animateTimer forMode:NSRunLoopCommonModes];
    
//    [self.animateTimer fire];
    
//   self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(executeAnimateWithTimer) userInfo:nil repeats:YES];
    
   
 
}


- (void)executeAnimateWithTimer
{
    static int times = 0;
    
    times++;
    
    [self startWithIndex:times];
    
    if (times == 3)
    {
        //!< 销毁定时器
        [self.animateTimer invalidate];
        
        self.animateTimer = nil;
        
        times = 0;
        
        XMLOG(@"定时器已销毁------------------%@",self.animateTimer);
    }
    
    
    
}


- (void)startWithIndex:(int)index
{
    XMLOG(@"------------222");
    UIButton *btn = self.btnArr[index];
    
    [btn setImage:[UIImage imageNamed:@"monitor_checking"] forState:UIControlStateDisabled];
    
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    anima.duration = 1;
    
    anima.removedOnCompletion = NO;
    
    anima.repeatCount = MAXFLOAT;
    
    anima.toValue = @(M_PI *2);
    
    NSString *key = [NSString stringWithFormat:@"%d",index];
    
    [btn.layer addAnimation:anima forKey:key];
    
    UILabel *label = self.labelArr[index];
    
    label.text = @"正在检测";

    
    
}

//!< 下发指令成功后获取检测结果
- (void)getCheckedResult
{
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Getcommandresult&controlid=%@",self.recordNumber];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [XMCheckManager shareManager].isChecking = NO;
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        int statusCode = [result intValue];
        
        switch (statusCode) {
            case 0:
            {
                
                 //!< 获取检测信息成功（不能转为int 会返回0）
                XMLOG(@"获取检测结果成功，准备解析数据");
                
                self.isCheckSuccess = YES;
                
                NSError *error = nil;
                
                NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
                
                if (error)
                {
                    XMLOG(@"获取检测结果成功，解析数据失败");
                    
                    [self parseFailed];
                    
                }else
                {
                    //!< 存储在属性中；
                
                    self.troubleInfo = resultArray;
                    
                    //上传信息到友盟
                    [UMTool handleFailedWithArray:resultArray carNumber:self.defaultCar.chepaino];
                    
                    
                    if (self.userAction)
                    {
                        
                        [self convertModelWithArray:resultArray];
                        
                        [self parseSuccessWithDictionary:nil isTrouble:YES];
                        
                        self.recordNumber = 0;
                    }
                    
                    
                }
            }
                break;
            case -1:
                
                //!< 网络异常
                XMLOG(@"获取检测结果成功，返回信息：网络异常");
             
                [self hideHUD];
                [self showAlertWithMessage:@"通讯失败 网络超时" btnTitle:@"确定"];
                
                [self parseFailed];
                
                break;
            case -2:
                
                //!< 没有找到任务
                XMLOG(@"获取检测结果成功，返回信息：没有找到任务");
                [self hideHUD];
                [self showAlertWithMessage:@"通讯失败 网络超时" btnTitle:@"确定"];
                [self parseFailed];
                
                break;
            case 100:
                
                //!< 没有检测到问题或者问题在OBD库中没有找到
                XMLOG(@"获取检测结果成功，返回信息：没有检测到问题");
                
                 self.noTrouble = YES;//!< 不存在问题
                
                //!< 上传信息到友盟
                [UMTool handleSuccellWithCarnumber:self.defaultCar.chepaino];
                
                if (self.userAction)
                {
                    
                    [self parseSuccessWithDictionary:nil isTrouble:NO];
                    
                    self.recordNumber = 0;
                }
                
                break;
                
            default:
                break;
        }
        
        XMLOG(@"获取检测成功结果：%@",result);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //!< 关闭指示器
            [XMCheckManager shareManager].isChecking = NO;
            
            [self.carNumber setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.checkBtn.enabled = YES;//!< 激活检测按钮
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"获取检测结果失败，网络错误");
        if (_userAction)
        {
            [self hideHUD];
            [self showAlertWithMessage:@"通讯失败 网络超时" btnTitle:@"确定"];
            
            //!< 关闭指示器
            [XMCheckManager shareManager].isChecking = NO;
            
            [self.carNumber setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.checkBtn.enabled = YES;//!< 激活检测按钮
        }
        
    }];
    
    
}

//!< 打开实时监控
- (void)openRealTimeMonitor
{
    
    
    XMUser *user = [XMUser user];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"sendcommand&userid=%ld&qicheid=%@&tboxid=%@&groupid=1",user.userid,self.defaultCar.qicheid,_defaultCar.tboxid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //!<  0 终端不在线，-1 网络异常，1 成功
        int result = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
        
        if(result == 1)
        {
            [self startRealTimeTimer];//!< 开启实时数据定时器
            [self getRealTimeData];//!< 开启定时器的时候，获取一次数据
          
            [_scrollView move];
         
        }else
        {
          
            XMLOG(@"开启实时监控失败，终端不在线");
            //!< 终端不在线停止底部动画
            [_scrollView stop];
            
 
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"开启实时监控失败，网络原因");
 
    }];
    
    
    

}


//!< 关闭实时监控
- (void)closeRealTimeMonitor
{
    
    
     [self closeRealTimeTimer];//!< 关闭刷新定时器,不需要等到关闭成功
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"sendcommand&userid=%@&qicheid=%@&tboxid=%@&groupid=2",self.defaultCar.userid,self.defaultCar.qicheid,_defaultCar.tboxid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:nil failure:nil];
    
}

//!< 开启实时定时器间隔10秒钟请求数据
- (void)startRealTimeTimer
{
    if(self.realTimer)
    {
        [self closeRealTimeTimer];
    }
    
    self.realTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getRealTimeData) userInfo:nil repeats:YES];

    XMLOG(@"定时器开启，每隔5秒刷新数据");

}


//!< 关闭实时定时器
- (void)closeRealTimeTimer
{
    [self.realTimer invalidate];
    
    self.realTimer = nil;
    
    XMLOG(@"定时器销毁");
    
}



//!< 定时器调用方法获取数据
- (void)getRealTimeData
{
    
    if (!self.view.window)
    {
        return;
    }
    
    //!< 第一次获取实时数据需要传当前时间格式
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        
        df.dateFormat = @"yyyy-MM-dd%20HH:mm:ss";
        
        NSDate *date = [NSDate date];
        
        self.Gpsdatetime = [df stringFromDate:date];
        
    });
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"q_run_info&Tboxid=%@&Qicheid=%@&Gpsdatetime=%@",_defaultCar.tboxid,_defaultCar.qicheid,self.Gpsdatetime];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resultStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        XMLOG(@"实时数据请求地址%@",urlStr);

        
        XMLOG(@"实时数据获取结果%@",resultStr);

        
        
         if(resultStr.length > 2)
        {
             XMLOG(@"获取实时数据成功");
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
             [self updateHeaderViewWithDic:dic];
         
        }else
        {
            XMLOG(@"获取实时数据失败");
            
            //!< 清空数据；
            [_scrollView clearData];
            
           
        }
        
       
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"获取实时数据失败，网络原因");
        
    }];



}

//!< 获取成功后刷新数据
- (void)updateHeaderViewWithDic:(NSDictionary *)dic
{

    //!< 下次需要上传这次获取的GPS时间
    self.Gpsdatetime = dic[@"oTBoxInfo"][@"locationdate"];
    
    //!< 格式化
    self.Gpsdatetime = [self.Gpsdatetime stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    [_scrollView setParas:dic];
  
}

//!< 解析数据失败，情况处理
- (void)parseFailed
{
   
    for (int i = 0;i<self.labelArr.count;i++)
    {
        UILabel *label = self.labelArr[i];
        
        label.text = @"检测失败";
        
        UIButton *btn = self.btnArr[i];
        
        NSString *key = [NSString stringWithFormat:@"%d",i];
        
        [btn.layer removeAnimationForKey:key];
        
        [btn setImage:[UIImage imageNamed:@"monitor_check_wait"] forState:UIControlStateDisabled];
        
        btn.enabled = NO;
        
    }
    
    [MBProgressHUD showError:@"检测超时"];
    
    
}

//!< 解析数据成功，进行处理
- (void)parseSuccessWithDictionary:(NSArray *)arr isTrouble:(BOOL)isTrouble
{
    if (!isTrouble)
    {
        [self hideHUD];
        //!< 没有检测到问题，取消动画，显示检测结果
        for (int i = 0;i<self.labelArr.count;i++)
        {
            UILabel *label = self.labelArr[i];
            
            label.text = @"正常";
            
            UIButton *btn = self.btnArr[i];
            
            NSString *key = [NSString stringWithFormat:@"%d",i];
            
            [btn.layer removeAnimationForKey:key];
            
            btn.enabled = NO;
            
            [btn setImage:[UIImage imageNamed:@"monitor_finish_green"] forState:UIControlStateDisabled];
            
        }
        
        self.stateLabel.text = @"车辆状态良好";
        
        
        self.centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_green"];
        
        
        self.scoreLabel.textColor = XMGreenColor;
        
        self.stateLabel.textColor = XMGreenColor;
        
        
//        [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(changeScore:) userInfo:nil repeats:YES];
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(changeScore:) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

        
        
        
        
    }else
    {
    //!< 检测到问题项
        [self hideHUD];
        
        NSArray *titleArr = @[@"P",@"B",@"C",@"U"];
        
        int problemCount = 0;
        
        for (int i = 0; i<4; i++)
        {
            UILabel *label = self.labelArr[i];
            
            
            UIButton *btn = self.btnArr[i];
            
            NSString *key = [NSString stringWithFormat:@"%d",i];//!< 删除动画
            
            [btn.layer removeAnimationForKey:key];

            NSMutableArray *pros = [self.troubleItemDictionary objectForKey:titleArr[i]];
            
            problemCount += pros.count;//!< 问题项数目，用来计算总分
            
            if (pros.count > 0)
            {
                //!< 改变label文字，
                label.text = [NSString stringWithFormat:@"%lu项问题",(unsigned long)pros.count];
                
                //!< 修改显示图片
                [btn setImage:[UIImage imageNamed:@"monitor_finish_red"] forState:UIControlStateNormal];
                
                //!< 设置可以点击
                btn.enabled = YES;
                
            }else
            {
            //!< 没有检测到问题项，设置”正常“ 不可点，绿色
                label.text = @"正常";
               
                btn.enabled = NO;
                
                [btn setImage:[UIImage imageNamed:@"monitor_finish_green"] forState:UIControlStateDisabled];
            
            
            }
            
        }
        
        //!< 计算分数，决定顶部颜色
        
        int score = 100 - 15 - (problemCount - 1) * 10;
        
        
        
        UIColor *color;
        
        NSString *title;
        
        if (score >= level_1 )
        {
            color = XMGreenColor;
            
            title = @"车辆状况良好";
            
            self.centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_green"];
        }else if(score >= level_2)
        {
        
             title = @"车辆状况一般";
            
            color = XMPurpleColor;
            
            self.centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_purple"];
        
        }else
        {
        
            title = @"请及时检查车辆";
            color = XMRedColor;
            
            self.centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_red"];
        
        }
        
        self.stateLabel.textColor = color;
        
        self.stateLabel.text = title;
        
        self.scoreLabel.textColor = color;
        
    
        
        self.troubleScore = score;
        
        
        [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(changeTroubleScore:) userInfo:nil repeats:YES];
        
       
    
    }
    
    
    
}

- (void)changeTroubleScore:(NSTimer *)timer
{
    static int tro_index = 0;
    
     tro_index++;
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",tro_index];
    
   
    
    if (tro_index == _troubleScore)
    {
        [timer invalidate];
        
        tro_index = 0;
        
    }
    
    
    
    
}


- (void)changeScore:(NSTimer *)timer
{
    
    static int score_index = 0;
    
    score_index++;
    
    NSString *text  = [NSString stringWithFormat:@"%d",score_index];
    
    text = [text stringByAppendingString:@"%"];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:text];
    
    NSRange range = [text rangeOfString:@"%"];
    
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22] range:range];
    
    self.scoreLabel.attributedText = str;
    
    
    
    if (score_index == 100)
    {
        [timer invalidate];
        score_index = 0;
    }
    
    
    
    
}
#pragma mark --- 开始动画


- (void)convertModelWithArray:(NSArray *)array
{
    
     //!< 模型转换
    for (NSDictionary *dic in array)
    {
        XMTroubleItemModel *model = [[XMTroubleItemModel alloc]initWithDictionary:dic];
        
        NSString *prefix = [model.code substringToIndex:1];
        
        if (prefix.length==0)continue;
            
         NSMutableArray *arr = [self.troubleItemDictionary objectForKey:prefix];
        
        [arr addObject:model];
        
    }
    
 }

#pragma mark  监听导航栏按钮点击


/**
 *  点击顶部左侧按钮
 */
- (void)leftBarButtonItemClick
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (tempAppDelegate.sliderVC.closed)
    {
        [tempAppDelegate.sliderVC openLeftView];
    }
    else
    {
        [tempAppDelegate.sliderVC closeLeftView];
    }

}


/**
 *  点击导航栏右侧的按钮
 */
- (void)rightBarButtonItemClick
{
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showError:@"网络未连接"];
        
        return;
        
    }
    
    //->>推出消息控制器
    XMMessageViewController *vc = [XMMessageViewController new];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}



/**
 *  点击导航栏中间的按钮
 */
- (void)titleBarButtonItemClick
{
    
    return;//!< 不让标题响应点击事件
    //!< 如果只有一辆车或者没有车就不响应点击时间
    if(self.carList.count < 2) return;
    
    
    //!< 没有网络也不响应点击事件
    if (!self.isConnect)
    {
        return;
    }
    
    //!< 如果正在检测就不响应点击事件
    if([UIApplication sharedApplication].networkActivityIndicatorVisible)return;
    
    //!< 过滤掉当前选中的车辆
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chepaino != %@",_carNumber.titleLabel.text];
    
    NSArray *arr = [self.carList filteredArrayUsingPredicate:predicate];
    
//    self.leftCarArr = arr;//!< 并记录在点击的时候回游泳
    
    NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:arr.count];
    
    
    //!< 转换模型更新菜单
    for (int i = 0; i<arr.count; i++)
    {
        XMCar*car = arr[i];
        
        NSDictionary *dict = @{
                                @"itemName" : car.chepaino
                                };
        [dataArr addObject:dict];
    }
    
    
    //!< 更新菜单并展示
    [MenuView updateMenuItemsWith:dataArr];
    
     [MenuView showMenuWithAnimation:YES];
    
    
}

#pragma mark -------------- 用来恢复控件为初始状态

//!< 恢复按钮和Label的初始状态
- (void)resumeBtnAndLabelState
{
    
    //!< 还原按钮和Label状态
    for (int i = 0; i < 4; i++)
    {
        UIButton *desBtn = [self.btnArr objectAtIndex:i];
        
        [desBtn setImage:[UIImage imageNamed:@"monitor_check_wait"] forState:UIControlStateDisabled];
        
        desBtn.enabled = NO;
        
        UILabel *desLabel = [self.labelArr objectAtIndex:i];
        
        desLabel.text = @"未检测";
    }
    
    
    //!< 切换上半部分显示内容
    self.stateLabel.text = @"点我进行体检";
    self.stateLabel.textColor = XMPurpleColor;
    
     self.centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_purple"];
    
    self.scoreLabel.textColor = XMPurpleColor;
    self.scoreLabel.text = @"0";
    

}

#pragma mark --- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100  && buttonIndex == 1)
    {
        //!< 跳转到添加车两界面
         XMAddViewController *vc = [XMAddViewController new];
        
         vc.hidesBottomBarWhenPushed = YES;
        
         [self.navigationController pushViewController:vc animated:YES];
        
         self.tabBarController.tabBar.hidden = YES;
    }



}


#pragma mark --- Notification


//-- 响应企业用户点击车辆的通知
- (void)companyUserDidSelectedCar:(NSNotification *)noti
{
    
    //-- 设置默认车辆，返回当前界面
    XMCar * car = noti.userInfo[@"carModel"];
    
    self.defaultCar = [self changeCarToDefault:car];
    
    //-- 发送通知通知其他界面数据更新
    [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil userInfo:@{@"mode":@"car",@"result":self.defaultCar}];
    
    [self.carNumber setTitle:car.chepaino forState:UIControlStateNormal];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //-- 重新设置时间格式，获取实时数据
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    
    df.dateFormat = @"yyyy-MM-dd%20HH:mm:ss";
    
    NSDate *date = [NSDate date];
    
    self.Gpsdatetime = [df stringFromDate:date];
    
    
    [self getRealTimeData];
    
    //!< 如果车辆状态为停止或者失联的话，就清空数据，如果在线的话会自动更新实时数据     //--  0停止 1行驶 2失联
    [self clearRealTimeData];
    
    switch (self.defaultCar.currentstatus.intValue)
    {
        case 0:
            
            self.driveState.text = @"停止";
            
            [self closeRealTimeMonitor];//!< 关闭实时监控
            
            [_scrollView stop];//关闭动画
            
            break;
            
        case 1:
            
            self.driveState.text = @"行驶";
            
            [self openRealTimeMonitor];//!< 如果是行驶状态就开启实时监控
            
//            [_scrollView move];
            
            break;
            
        case 2:
            
            self.driveState.text = @"失联";
            
            [self closeRealTimeMonitor];//!< 关闭实时监控
            
            [_scrollView stop];//关闭动画
            
            break;
            
        default:
            break;
    }
    
    //!< 清空底部数据
    [_scrollView clearData];

    
}


/**
 *  响应时间 --- 点击设置界面的cell发出通知
 */
- (void)settingCellDidClick:(NSNotification *)noti
{
    
        // 点击相应的cell 推出相应设置的控制器（包括点击头像的情况）
    
        Class destination = NSClassFromString(noti.userInfo[@"class"]);
    

        if(isCompany)
        {
            //-- 选中的是显示车辆vc，传参车牌号
            if ([noti.userInfo[@"class"] isEqualToString:@"XMCompanyCarListViewController"])
            {
                
                XMCompanyCarListViewController * desVC = [XMCompanyCarListViewController new];
                
                desVC.carNumber = self.defaultCar.chepaino;
                
                desVC.defaultCar = self.deliverCar;
                
                desVC.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:desVC animated:NO];
                
                return;
            }
            
            
        }
    
        UIViewController *desVC = [[destination alloc]init];
    
    
        desVC.hidesBottomBarWhenPushed = YES;
    
        [self.navigationController pushViewController:desVC animated:NO];

 }

/**
 *  默认车辆已经修改
 */
- (void)defaultCarDidChanged:(NSNotification *)noti
{
    
    //!< 关闭用户操作开关
    self.userAction = NO;
    
    //!< 关闭当前车辆的实时监控
    [self closeRealTimeMonitor];//!< 在获取默认车辆的时候回重新打开实时监控
    
    [self getDefaultCarInfo];//!< 获取用户默认信息
    
    //!<恢复状态
    [self resumeBtnAndLabelState];
    
    
}

//!< 网络发生变化
- (void)networkDidChanged:(NSNotification *)noti
{
    int statusCode = [noti.userInfo[@"info"] intValue];
    
    if (statusCode == 0 || statusCode == -1)
    {
        self.isConnect = NO;
        
        [MBProgressHUD showError:@"网络已断开" toView:self.view];
        
        [_scrollView stop];
        
        
    }else
    {
        self.isConnect = YES;
        
//        [MBProgressHUD showError:@"网络恢复" toView:self.view];
        
        //!< 网络恢复的时候从新获取默认车辆数据，会在默认车辆获取成功后开启实时监控
        if (!isCompany) {
            
            [self getDefaultCarInfo];
            
        }
        
        self.recordNumber = 0;//!< 清除下发给终端的记录编号
        
        if(self.carList == nil)
        {
        
            //!< 重新获取所有车辆数据
            [self getUserAllCars];
            
        }
       
 
    
    }
    
}


- (void)applicationWillEnterBackground
{
    //!< 将要进入后台的时候，关闭更新数据的定时器

    
    [self closeRealTimeMonitor];//!< 关闭实时监控
    
    XMLOG(@"程序将要进入后台，关闭实时监控");
    
    [self saveCurrentCarValue];
    
}


- (void)applicationWillBecomeActive
{
     //!< 开启实时监控
    if (self.defaultCar.tboxid.intValue > 0)
    {
        
        [self openRealTimeMonitor];
         XMLOG(@"程序将要进入前台，开启定时器");
    }
   

}

/*!
 @brief 接收到远程通知的时候
 */

- (void)didReceiveRemoteNotification:(NSNotification *)noti
{
    if ([noti.userInfo[@"info"] boolValue])
    {
         if (!self.isApns)
        {
            
            //!< 让tabbar选择第一个控制器，并且判断是否处于侧滑的状态
            
            self.tabBarController.selectedIndex = 0;
            
            AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!tempAppDelegate.sliderVC.closed)
            {
                [tempAppDelegate.sliderVC closeLeftView];
            }
            self.isApns = YES;
            
             [self.navigationController popToRootViewControllerAnimated:NO];
            //->>推出消息控制器
            XMMessageViewController *vc = [XMMessageViewController new];
            
            vc.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:NO];
            
            //!< 防止这段代码被执行多次
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isApns = NO;
            });
            
        }
    }
   
}

//!< 保存当前数据，下次接入界面显示
- (void)saveCurrentCarValue
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    
    //!< 保存上次体检分数等信息
    
    NSString *score = [self.scoreLabel.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    
    [df setObject:score forKey:@"lastScore"];
    
    //!< 保存车牌
    [df setObject:_carNumber.titleLabel.text forKey:@"carNumber"];
    
    [df synchronize];
    
    
}


//!< 检测是否需要更新用户的registrationid
- (void)updatePushID
{
    if (isCompany)
    {
        return;
    }
   
    //-- 如果是企业用户是否可以考虑不更新registrationID
    XMUser *user = [XMUser user];
    
//    !< 判断是否需要更新用户registrationID
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        
         
        XMLOG(@"最新极光registrationID == %@",registrationID);
        
        //!< 检测到极光id和服务器id一直 不需要修改
         if ([user.registrationid isEqualToString:registrationID])return;
        
        //!< 如果用户id和现在获取的不一样就更新用户注册的id
        NSString *urlStr = [mainAddress stringByAppendingFormat:@"updatepushid&Userid=%lu&Registrationid=%@",(long)user.userid,registrationID];
        
        [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if ([result isEqualToString:@"1"])
            {
                XMLOG(@"更新用户pushid成功");
            }else
            {
                XMLOG(@"更新用户pushid失败");
                
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            XMLOG(@"更新用户registrationID失败，网络原因");
            
        }];
        
    }];
    
    
}


//!< 监听用户新添加车辆之后的通知
- (void)userAllCarsInfoDidUpDate:(NSNotification *)noti
{
    //!< 添加新车辆之后重新获取所有车辆数据
    [self getUserAllCars];
    
}


//-- 选择不在线的车辆时候清空实时数据 当账户为企业账户的时候可能会调用
- (void)clearRealTimeData
{
    
  
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"100%"];
    
    NSRange range = [@"100%" rangeOfString:@"%"];
    
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22] range:range];
    
    self.scoreLabel.attributedText = str;

    
    self.centerIV.image = [UIImage imageNamed:@"monitor_checkCircle_green"];
    
    self.stateLabel.text = @"点我进行体检";
    
    self.stateLabel.textColor = XMGreenColor;
    
    self.scoreLabel.textColor = XMGreenColor;
 
//    self.scoreLabel.text = @"100";
    
    for (UILabel *label in self.labelArr)
    {
        label.text = @"未检测";
    }
    
    for (UIButton *btn in self.btnArr)
    {
        [btn setImage:[UIImage imageNamed:@"monitor_check_wait"] forState:UIControlStateDisabled];
        
        [btn setImage:[UIImage imageNamed:@"monitor_check_wait"] forState:UIControlStateNormal];

    }
    
}



- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;

}


- (void)dealloc
{
    
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //->>显示tabbar 隐藏navigationbar
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [tempAppDelegate.sliderVC setPanEnabled:YES];
    
    tempAppDelegate.tabBarController.tabBar.hidden = NO;
//    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //!< 停止网络指示器
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });

    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //->>页面消失，设置不可以滑动到侧边栏
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [tempAppDelegate.sliderVC setPanEnabled:NO];
    
    MobClickEnd(@"监控主界面");
    
}


@end
