//
//  AppDelegate.m
//  KuRuiBao
//
//  Created by x on 16/6/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "AppDelegate.h"
#import "XMSettingViewController.h"
#import "AFNetworking.h"

//-- 高德
#import <AMapFoundationKit/AMapFoundationKit.h>
//#import <AMapNaviKit/AMapNaviKit.h>
#import <CoreLocation/CoreLocation.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

#import "WXApi.h"
#import "WeiboSDK.h"

//->>加载广告业
//#import "LSLaunchAD.h"
//#import "NSString+Hash.h"
#import "XMLoginViewController.h"
#import "XMLoginNaviController.h"
#import "XMUser.h"
#import "XMOfflineMapProgress.h"//单例数据

//!< Bugtags
#import <Bugtags/Bugtags.h>

// 引入JPush功能所需头文件
#import "JPUSHService.h"

// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "XMSDK.h"

#import<BaiduMapAPI_Map/BMKMapComponent.h>

#import "UMMobClick/MobClick.h"

BMKMapManager* _mapManager;

static NSString *channel = @"Publish channel";

#ifdef DEBUG // 开发环境

static BOOL const isProduction = FALSE; // 极光FALSE为开发环境

#else // 生产环境

static BOOL const isProduction = TRUE; // 极光TRUE为生产环境

#endif


@interface AppDelegate ()<JPUSHRegisterDelegate,XMReqDelegate>

@property (nonatomic,strong)CLLocationManager* locationManager;

@property (strong, nonatomic)XMOfflineMapProgress *offlineProgress;


@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
    
    //-- 创建窗口
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //-- 选择根控制器
    [self chooseRootViewController];
    
  
    //-- 设置为主窗口
    [self.window makeKeyAndVisible];
    
    self.allowRotation = NO;
    
    /*
    //!< bugtags 禁用此SDK
    BugtagsOptions *options = [[BugtagsOptions alloc] init];
     
    options.trackingUserSteps = YES; // 具体可设置的属性请查看 Bugtags.h
    
    options.trackingCrashes = YES;
    
    options.trackingNetwork = YES;
     
    [Bugtags startWithAppKey:@"c3a744ce0cfef0aea080c4ed4e22b65d" invocationEvent:BTGInvocationEventNone options:options];
     */
    
    //!< 初始化shareSDK
    [self verifyShareSDK];
    
    //-- 对导航SDK 地图SDK 搜索SDK 进行key机制验证
    [self verifyAMapSDK];
    
    //!< 初始化极光
    [self verifyJpushWithDic:launchOptions];
    
    
    //-- 申请用户定位授权
    [self rquestAuthorization];
    
    
    //!< 监控网络
    [self monitorNetChange];
    
   
    
    //!< 判断是否是点击推送进入程序
    // apn 内容获取：
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    BOOL isAPNS = remoteNotification ? YES : NO;
    
    if(isAPNS)
    {
    
        [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiDidReceiveRemoteNotification object:nil userInfo:@{@"info":[NSNumber numberWithBool:isAPNS]}];
    
    }
    
    //!< 注册喜马拉雅
    [[XMReqMgr sharedInstance]registerXMReqInfoWithKey:@"e37142b72e331e6a2c09679d6606ddbe" appSecret:@"e4c0c5a4692e6b20ade552933debd91c"];
    
    [XMReqMgr sharedInstance].delegate = self;
    
   
    //-- baidu
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    
    /**
     *百度地图SDK所有接口均支持百度坐标（BD09）和国测局坐标（GCJ02），用此方法设置您使用的坐标类型.
     *默认是BD09（BMK_COORDTYPE_BD09LL）坐标.
     *如果需要使用GCJ02坐标，需要设置CoordinateType为：BMK_COORDTYPE_COMMON.
     */
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        NSLog(@"经纬度类型设置成功-000");
    } else {
        NSLog(@"经纬度类型设置失败-000");
    }
    
    BOOL ret = [_mapManager start:@"lwdZw0T3LoPYP7IX7VB5GTe9Xisdj1Kn" generalDelegate:self];
    if (!ret) {
        NSLog(@"000manager start failed!");
    }

    
    //!< 初始化友盟
    [self setupUM];
    
    return YES;
    
}



//-- 选择根控制器
- (void)chooseRootViewController
{
    
    //-- 取出用户信息
    XMUser *user = [XMUser user];
    
     //-- 判断账户信息是否存在
    if (user)
    {
        //-- 设置tabBarController为根控制器
        XMSettingViewController *setVC = [[XMSettingViewController alloc]init];
        
        UITabBarController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                                      instantiateViewControllerWithIdentifier:@"XMMainTabBarController"];
        
        XMSlideViewController *slideVC = [[XMSlideViewController alloc]initWithLeftView:setVC andMainView:mainVC];
        
        self.window.rootViewController = slideVC;
        
        self.sliderVC = slideVC;
        
        self.tabBarController = mainVC;
        
        
    }else
    {
        
        //-- 账户信息不存在设置登录界面为根窗口 XMLoginViewController
        XMLoginViewController *loginViewController = [XMLoginViewController new];
        
        XMLoginNaviController *naviVC = [[XMLoginNaviController alloc]initWithRootViewController:loginViewController];
        
        self.window.rootViewController = naviVC;
    }
    
    
    
}


/**
 初始化友盟
 */
- (void)setupUM
{
//    [MobClick setLogEnabled:YES];//!< 使用集成测试
    
    //!< 获取版本号
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    UMConfigInstance.appKey = @"59632154a32511195b001275";
    
    UMConfigInstance.channelId = @"App Store";
    
    //!< 配置以上参后，调用此方法开始初始化SDK
    [MobClick startWithConfigure:UMConfigInstance];
    
    
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = @selector(openUDIDString);
//    NSString *deviceID = nil;
//    if(cls && [cls respondsToSelector:deviceIDSelector]){
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:nil];
//    
//    NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    
}


#pragma mark --- lazy  离线地图使用到的单例类存储数据

- (XMOfflineMapProgress *)offlineProgress
{
    if (!_offlineProgress)
    {
         _offlineProgress = [XMOfflineMapProgress shareInstance];
    }
     return _offlineProgress;

}


//!< 监控网络
- (void)monitorNetChange
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status)
        {
                
            case AFNetworkReachabilityStatusNotReachable:
                
                
                [center postNotificationName:XMNetWorkDidChangedNotification object:self userInfo:@{@"info":@(0)}];
                
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
                 [center postNotificationName:XMNetWorkDidChangedNotification object:self userInfo:@{@"info":@(1)}];
                
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                
                 [center postNotificationName:XMNetWorkDidChangedNotification object:self userInfo:@{@"info":@(2)}];
                
                break;
                
            case AFNetworkReachabilityStatusUnknown:
                
                 [center postNotificationName:XMNetWorkDidChangedNotification object:self userInfo:@{@"info":@(-1)}];
                
                break;
            default:
               
                
                
                
                break;
        }
    }];
   
        
    [manager startMonitoring];
     
    
}




/**
 *  高德key机制验证
 */
- (void)verifyAMapSDK
{
     [AMapServices sharedServices].apiKey = APPKEY_GAODE;
 
 }
/*!
 @brief 初始化极光
 */
- (void)verifyJpushWithDic:(NSDictionary *)launchOptions
{
     // 注册apns通知
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) // iOS10
    {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
        
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
        
#endif
        
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) //  iOS9
    {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |     UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    }

    
    //是否是发布模式
    
    [JPUSHService setupWithOption:launchOptions appKey:APPKEY_JPUSH
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
}


/*!
 @brief 初始化share
 */
- (void)verifyShareSDK
{
    [ShareSDK registerApp:APPKEY_ShareSDK activePlatforms:@[@(SSDKPlatformTypeSinaWeibo),@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),] onImport:^(SSDKPlatformType platformType) {
        
        switch (platformType)
        {
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            
            case SSDKPlatformTypeSinaWeibo:
                [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                break;
             
            default:
                break;
        }
        
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        switch (platformType)
        {
            case SSDKPlatformTypeSinaWeibo:
                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                [appInfo SSDKSetupSinaWeiboByAppKey:@"2861585468"
                                          appSecret:@"a076f3865166a6fc10410fda721d19f3"
                                        redirectUri:@"https://api.weibo.com/oauth2/default.html"
                                           authType:SSDKAuthTypeBoth];
                break;
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:@"wx43f834338c8fc527"
                                      appSecret:@"858f94c80f6147b66c3eab0f7f62087a"];
                break;
                
             default:
                break;
        }
    }];
    
    
}




//!< 获取deviceTocken回调方法
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    XMLOG(@"注册远程通知失败");
}//


#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
}
#endif



- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}


#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
        
    }
    else {
        // 判断为本地通知
       
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    
    //!< 程序运行在后台，点击推送的话，准备进入前台，会回调此方法
    [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiDidReceiveRemoteNotification object:nil userInfo:@{@"info":[NSNumber numberWithBool:YES]}];
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;

    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
    }
    else {
        // 判断为本地通知
        
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif


//
/**
// *  申请用户授权
// */
- (void)rquestAuthorization
{
    if(![CLLocationManager locationServicesEnabled])
    {
        //-- 定位服务不可用
        return;
    
    }
    //-- 判断定位服务是否可用
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        //-- 用户授权不确定,申请授权
        [self.locationManager requestWhenInUseAuthorization];
        
        
    }
    
}


#pragma mark -- lazy

- (CLLocationManager *)locationManager
{

    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc]init];
 
    }
    return _locationManager;

}
//

#pragma mark --- XMReqDelegate
//!< 两个回调方法，目前并不会每一次都会被调用。因为SDK会保存服务端的验证token，只有token超过有效期后，才会向喜马拉雅开放平台的服务端请求新的token，此时，才会调用以上两个回调方法
-(void)didXMInitReqOK:(BOOL)result
{
    
    XMLOG(@"注册成功");
    
}


-(void)didXMInitReqFail:(XMErrorModel *)respModel
{
    
    XMLOG(@"注册失败");
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
//    [[EMClient sharedClient] applicationDidEnterBackground:application];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
//    [[EMClient sharedClient] applicationWillEnterForeground:application];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.allowRotation)
    {
        //!< 如果是yes就只支持横屏
        return UIInterfaceOrientationMaskLandscapeRight;
    }

    //!< 如果是NO就只支持竖屏
    return UIInterfaceOrientationMaskPortrait;
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"000联网成功");
    }
    else{
        NSLog(@"000onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"000授权成功");
    }
    else {
        NSLog(@"000onGetPermissionState %d",iError);
    }
}

@end
