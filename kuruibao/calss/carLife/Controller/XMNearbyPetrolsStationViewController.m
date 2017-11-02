//
//  XMNearbyPetrolsStationViewController.m
//  kuruibao
//
//  Created by x on 17/4/19.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMNearbyPetrolsStationViewController.h"

#import <AMapNaviKit/AMapNaviKit.h>

#import "AFNetworking.h"

#import "CLLocation+YCLocation.h"

#import "XMNearbyPetrolStationModel.h"

#import "XMPetrolModuleCustomAnnotationView.h"

#import "XMPetrolCustomAnnotation.h"

#import <AMapFoundationKit/AMapFoundationKit.h>

@import CoreLocation;

#define HOSTAddress @"http://apis.juhe.cn/oil/local"

@interface XMNearbyPetrolsStationViewController ()<MAMapViewDelegate,UIAlertViewDelegate,AMapNaviDriveManagerDelegate,AMapNaviDriveViewDelegate>

@property (weak, nonatomic) MAMapView *mapView;

@property (strong, nonatomic) CLLocation *baiduLocation;//!< baidu location

@property (assign, nonatomic) BOOL isrequested;//!< idntifier whether had request

@property (assign, nonatomic) BOOL isConnected;

@property (nonatomic,strong)XMPetrolCustomAnnotation* selectedAnno;

@property (nonatomic,strong)AMapNaviDriveManager* driveManager; //-- navi manager

@property (strong, nonatomic) AMapNaviDriveView *driveView;//!< 导航视图



@end

@implementation XMNearbyPetrolsStationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
   
    [self setSubviews];
    
    //-- monitor notificatin
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(naviBtnClicknotify:) name:kXMNaviToPetrolStationNotification object:nil];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"附近加油站页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"附近加油站页面");
    
}

- (void)naviBtnClicknotify:(NSNotification *)noti
{
    //-- hide the callout
    XMPetrolModuleCustomAnnotationView *view = [noti.userInfo objectForKey:@"info"];
    
    [_mapView deselectAnnotation:view.annotation animated:YES];
    
    //-- start navi
    [MBProgressHUD showMessage:nil];
    
    XMNearbyPetrolItemModel *model = [noti.userInfo objectForKey:@"model"];
    
    
    //-- tranfer coordinate baiduBD_09-> GCJ-02
   CLLocationCoordinate2D huoxingCoordinate = AMapCoordinateConvert(CLLocationCoordinate2DMake(model.lat.floatValue, model.lon.floatValue), AMapCoordinateTypeBaidu);
    
    
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:huoxingCoordinate.latitude longitude:huoxingCoordinate.longitude];
    
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:_mapView.userLocation.location.coordinate.latitude longitude:_mapView.userLocation.location.coordinate.longitude];
    
    [self.driveManager calculateDriveRouteWithStartPoints:@[startPoint] endPoints:@[endPoint] wayPoints:nil drivingStrategy:AMapNaviDrivingStrategySinglePrioritiseDistance];
    
    
    
    
}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//
//    [super viewDidAppear:animated];
//    
//    [_mapView showAnnotations:@[_mapView.userLocation] animated:YES];
//    
//    _mapView.zoomLevel = 17.5;
//
//}

- (void)setSubviews
{
    self.navigationController.navigationBar.hidden = YES;
    
    //!< add mapView
    MAMapView *mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
    
    mapView.delegate = self;
    
    mapView.showsUserLocation = YES;
    
    mapView.touchPOIEnabled = NO;
    
    mapView.showsCompass = NO;
    
    mapView.showsScale = NO;
    
    mapView.distanceFilter = 2;
    
    mapView.headingFilter = 2;
    
    mapView.zoomLevel = 17.5;
    
    mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    [self.view addSubview:mapView];
    
    self.mapView = mapView;
    
    //!< add location button
//    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    
//    [locationBtn setTitle:@"定位" forState:UIControlStateNormal];
//    
//    [locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:locationBtn];
//    
//    [locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//       
//        make.left.equalTo(self.view).offset(30);
//        
//        make.bottom.equalTo(self.view).offset(-30);
//        
//        make.size.equalTo(CGSizeMake(40, 40));
//        
//    }];
    
    //!< add back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setImage:[UIImage imageNamed:@"carLife_saveCar_back"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backButton];
    
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view).offset(45);
        
        make.left.equalTo(self.view).offset(20);
        
        make.size.equalTo(CGSizeMake(33, 33));
        
    }];
    
    [MBProgressHUD showMessage:@"正在加载数据"];
    
}


- (void)requestData
{
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        //!< location service disabled
        return;
    }
    
    if([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"主人，网络不给力啊~"];
        
        return;
    
    
    }
    
    self.isrequested = YES;
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    session.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    session.requestSerializer.timeoutInterval = 3;
    
    
     NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    
    paras[@"key"] = @"77d8dcc2b48d23aa71693327e02ffd78";
    
    paras[@"lon"] = [NSNumber numberWithFloat:_baiduLocation.coordinate.longitude];
    
     paras[@"lat"] = [NSNumber numberWithFloat:_baiduLocation.coordinate.latitude];
    
    paras[@"r"] = @3000;
    
    [session POST:HOSTAddress parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        XMLOG(@"*** request message success");
        
        [MBProgressHUD hideHUD];
        
        XMNearbyPetrolStationModel *model = [XMNearbyPetrolStationModel mj_objectWithKeyValues:responseObject];
        
        //!< show data
        [self treatData:model];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"*** error happened\n errdesc:%@",error);
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"网络不给力呀~"];
        
    }];
    
 
    
    
}

- (void)treatData:(XMNearbyPetrolStationModel *)model
{
    
    if (model.resultcode.intValue != 200)
    {
        //!< there is no useful message back
        NSLog(@"no useful message\n reson:%@,\tresultcode:%@,errorcode:%d",model.reason,model.resultcode,model.error_code);
        
        [MBProgressHUD showError:@"附近好像没有加油站"];
        
        return;
    }
    
    //!< show petrol stations
    NSArray *items = model.result.data;
    
    //-- if not search pertrol station, show the message to user
    if(items.count == 0 || items.count == NSNotFound)
    {
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"没有找到附近的加油站"];
    
    
    }
    
    NSMutableArray *temArr = [NSMutableArray arrayWithCapacity:items.count];
    
    for (XMNearbyPetrolItemModel *item in items)
    {
        XMPetrolCustomAnnotation *anno = [[XMPetrolCustomAnnotation alloc]init];
        
        anno.model = item;
        
        anno.coordinate = CLLocationCoordinate2DMake(item.lat.floatValue, item.lon.floatValue);
        
        anno.title = item.name;
        
        anno.subtitle = item.address;
        
        [temArr addObject:anno];
        
    }
    
    [_mapView addAnnotations:temArr];
    
    [_mapView showAnnotations:temArr animated:YES];
    
}

#pragma mark --lazy
-(AMapNaviDriveManager *)driveManager
{

    if (!_driveManager)
    {
        _driveManager = [[AMapNaviDriveManager alloc]init];
        
        _driveManager.delegate = self;
        
        [_driveManager setDetectedMode:AMapNaviDetectedModeNone];
    }
    
    return _driveManager;


}

- (AMapNaviDriveView *)driveView
{
    if (_driveView == nil)
    {
        _driveView = [[AMapNaviDriveView alloc] initWithFrame:self.view.bounds];
        _driveView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_driveView setDelegate:self];
        
        
    //        _driveView.showTrafficBar = NO;//-- 路况光柱
        
        _driveView.showTrafficButton = NO;//-- 实时交通按钮
        
        _driveView.showTrafficLayer = NO;//-- 实时交通图层

    }
    return _driveView;
}


#pragma mark ------- btn click

- (void)locationBtnClick:(UIButton *)sender
{
    if (_mapView)
    {
        [_mapView showAnnotations:@[_mapView.userLocation] animated:YES];
        
        [_mapView setZoomLevel:17.5 animated:YES];
        
    }
    
    
}


- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
    
}



#pragma mark -------  MAMapViewDelegate


- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{

    XMLOG(@"*** %f",mapView.zoomLevel);

}

/**
 * @brief 根据anntation生成对应的View
 * @param mapView 地图View
 * @param annotation 指定的标注
 * @return 生成的标注View
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    
    
    if ([annotation isKindOfClass:[XMPetrolCustomAnnotation class]])
    {
        static NSString *petrolIdetifier = @"petrolIdetifier";
        
        XMPetrolModuleCustomAnnotationView *view = (XMPetrolModuleCustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:petrolIdetifier];
        
        if (view == nil)
        {
            view = [[XMPetrolModuleCustomAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:petrolIdetifier];
            
        }
        
            view.canShowCallout = NO;
            
            view.image = [UIImage imageNamed:@"carLife_petrolStation_annoView"];
        
            view.centerOffset = CGPointMake(0, -18);
        
            view.calloutView.userInteractionEnabled = YES;
        
        
        
            return view;
        
    }

    

    return nil;
}

/**
 * @brief 当mapView新添加annotation views时，调用此接口
 * @param mapView 地图View
 * @param views 新添加的annotation views
 */
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    XMLOG(@"*** add annotationView");
    MAAnnotationView *view = views.firstObject;
    
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        view.canShowCallout = NO;
    }
    

}

/**
 * @brief 当选中一个annotation views时，调用此接口
 * @param mapView 地图View
 * @param view 选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    XMLOG(@"*** did select annotationView");
    
//    [_mapView showAnnotations:@[view.annotation] animated:YES];
    
//    self.selectedAnno = (XMPetrolCustomAnnotation *)view.annotation;

    [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
    
}

/**
 * @brief 当取消选中一个annotation views时，调用此接口
 * @param mapView 地图View
 * @param view 取消选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{

    XMLOG(@"*** did deselect annotationView");

}

/**
 * @brief 在地图View将要启动定位时，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView
{
    XMLOG(@"*** map will start location");

}

/**
 * @brief 在地图View停止定位后，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView
{

    XMLOG(@"*** map did stop location");

}

/**
 * @brief 位置或者设备方向更新后，会调用此函数
 * @param mapView 地图View
 * @param userLocation 用户定位信息(包括位置与设备方向等数据)
 * @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    XMLOG(@"*** user location did update");
        //!< if the idntifier is no, request or do nothing
    if (!self.isrequested)
    {
       
        
//        [mapView showAnnotations:@[mapView.userLocation] animated:YES];
        
//        mapView.zoomLevel = 17.5;
        
        if (mapView.userLocation)
        {
            
            
            self.baiduLocation = [mapView.userLocation.location locationBaiduFromMars];
            
            XMLOG(@"*** location success  baidu:latitude:%f longitude:%f",_baiduLocation.coordinate.latitude,_baiduLocation.coordinate.longitude);
            
            XMLOG(@"*** location success AMap: latitude:%f longitude:%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
            
             [self requestData];
            
        }else
        {
            XMLOG(@"*** location failed");
        }

    }
    
}


/**
 * @brief 标注view的accessory view(必须继承自UIControl)被点击时，触发该回调
 * @param mapView 地图View
 * @param view callout所属的标注view
 * @param control 对应的control
 */
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    XMLOG(@"*** accessoryView did click");

}

/**
 * @brief  标注view的calloutview整体点击时，触发改回调。
 *
 *  @param mapView 地图的view
 *  @param view calloutView所属的annotationView
 */
- (void)mapView:(MAMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view
{

    XMLOG(@"*** did click callout view");

}

 

/**
 * @brief 单击地图回调，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    XMLOG(@"*** latitude:%f,longitude:%f",coordinate.latitude,coordinate.longitude);
    
    

}
  

/**
 * @brief 地图加载失败
 * @param mapView 地图View
 * @param error 错误信息
 */
- (void)mapViewDidFailLoadingMap:(MAMapView *)mapView withError:(NSError *)error
{
    XMLOG(@"*** map load failed, error description:%@",error);
    
    [MBProgressHUD showError:@"亲，地图跑到火星去了~"];
    
    
}


/**
 * @brief 定位失败后，会调用此函数
 * @param mapView 地图View
 * @param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
    XMLOG(@"*** location failed,error description : %@",error);
    
    //!< judge whether has authorize
    
    [MBProgressHUD hideHUD];
    
    if(![CLLocationManager locationServicesEnabled])
    {
        //!< location service disabled
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"定位服务未开启" message:@"请到手机系统的[设置]->[隐私]->[定位服务]中打开定位服务，并允许酷锐宝使用定位服务" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        
        [alert show];
        
        
        
        return;
        
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"应用无权限" message:@"请到手机系统的[设置]->[酷锐宝]->[位置]中开启权限" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        
        [alert show];
        
        
    }
    
}



#pragma mark ------- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

 
    
    if (alertView.tag == 100)
    {
        //-- navi relate alert
        if (buttonIndex == 0)
        {
            //                [_manager dismissNaviViewControllerAnimated:YES];
            
            [_driveManager stopNavi];
            
            [_driveView removeFromSuperview];
            
            _driveView = nil;
            
//            [self exitToMapView];
            
            [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
            
            [_mapView showAnnotations:@[_mapView.userLocation] animated:YES];
            
//            NSMutableArray *annoM = [NSMutableArray array];
            
//            for (id anno in _mapView.annotations)
//            {
//                if ([anno isKindOfClass:[MAUserLocation class]])
//                {
//                    //!< 如果是系统大头针
//                    continue;
//                }
//                
//                [annoM addObject:anno];
//            }
//            
//            [_mapView removeAnnotations:annoM];
//            
//            [self.view endEditing:YES];
            
        }

    }else
    {
        //-- other alert
        [self.navigationController popViewControllerAnimated:YES];

    }

}

#pragma mark --AMapNaviDriveManagerDelegate

/**
 *  发生错误时,会调用代理的此方法
 *
 *  @param error 错误信息
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    
    [MBProgressHUD showError:@"导航规划失败"];

}

/**
 *  驾车路径规划成功后的回调函数
 */
- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
     [MBProgressHUD hideHUD];
    
//    [MBProgressHUD showSuccess:@"路径规划成功"];

     [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:@"路径规划成功"];

    [self.view addSubview:self.driveView];
    
    [_driveManager addDataRepresentative:self.driveView];
    
    [_driveManager startGPSNavi];
    
}

/**
 *  驾车路径规划失败后的回调函数
 *
 *  @param error 错误信息,error.code参照AMapNaviCalcRouteState
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error
{

     [MBProgressHUD hideHUD];
    
    [MBProgressHUD showError:@"路径规划失败"];

//    [_driveManager startGPSNavi];

}

/**
 *  启动导航后回调函数
 *
 *  @param naviMode 导航类型，参考AMapNaviMode
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode
{
    
    XMLOG(@" did start navi");




}

/**
 *  出现偏航需要重新计算路径时的回调函数
 */
- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager
{

    //-- recalculate route
    [driveManager recalculateDriveRouteWithDrivingStrategy:AMapNaviDrivingStrategySinglePrioritiseDistance];

}

/**
 *  前方遇到拥堵需要重新计算路径时的回调函数
 */
- (void)driveManagerNeedRecalculateRouteForTrafficJam:(AMapNaviDriveManager *)driveManager
{
    //-- recalculate route
    [driveManager recalculateDriveRouteWithDrivingStrategy:AMapNaviDrivingStrategySinglePrioritiseDistance];

}

/**
 *  导航到达某个途经点的回调函数
 *
 *  @param wayPointIndex 到达途径点的编号，标号从1开始
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager onArrivedWayPoint:(int)wayPointIndex
{


}

/**
 *  导航播报信息回调函数
 *
 *  @param soundString 播报文字
 *  @param soundStringType 播报类型,参考AMapNaviSoundType
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{

    //-- read the message
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

/**
 *  模拟导航到达目的地停止导航后的回调函数
 */
- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{


}

/**
 *  导航到达目的地后的回调函数
 */
- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:@"已到达目的地附件"];

    

}

#pragma mark -- - AMapNaviDriveViewDelegate  --- 导航控制器的代理方法
/**
 *  导航界面关闭按钮点击时的回调函数
 */
- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView
{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"您确定要退出导航吗？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
    alert.tag = 100;
    [alert show];
    
}

/**
 *  导航界面更多按钮点击时的回调函数
 */
- (void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView
{
    XMLOG(@"点击更多按钮");
    
}

- (void)dealloc
{

    XMLOG(@"***XMNearbyPetrolsStationViewController dealloc");

 
    //-- remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
