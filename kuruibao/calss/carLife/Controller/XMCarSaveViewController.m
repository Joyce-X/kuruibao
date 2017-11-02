//
//  XMCarSaveViewController.m
//  kuruibao
//
//  Created by x on 17/4/19.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarSaveViewController.h"

#import <AMapNaviKit/AMapNaviKit.h>

#import "AFNetworking.h"

#import "XMSearchCityListModel.h"

#import "XMParkSearchResultModel.h"

#import "XMParkingCustomAnnotationView.h"

#import "XMCarLife_SaveCarAnnotation.h"

@import CoreLocation;


#define kLastUpdateTime @"lastUpdateTime_cityList" //last update

#define fileName @"cityList.data"

#define kParkingKey @"1a12913ca9de19f10c61db4f943be5f8"


@interface XMCarSaveViewController ()<MAMapViewDelegate,CLLocationManagerDelegate,AMapNaviDriveManagerDelegate,AMapNaviDriveViewDelegate>

@property (nonatomic,weak)MAMapView* mapView;

@property (nonatomic,strong)NSArray* cityList;// support search nearby car park cities

@property (nonatomic,strong)AFHTTPSessionManager* session;

@property (nonatomic,strong)CLLocationManager* manager;

@property (nonatomic,assign)BOOL isRequested;//-- identifier whether has send request

@property (nonatomic,copy)NSString* currentCity;//-- city of user location

@property (nonatomic,strong)CLLocation* currentLocation;

@property (nonatomic,strong)AMapNaviDriveManager* driveManager; //-- navi manager

@property (strong, nonatomic) AMapNaviDriveView *driveView;//!< 导航视图



@end

@implementation XMCarSaveViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setSubviews];
   
    [self startLocations];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"停车场页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"停车场页面");
    
}

- (void)startLocations
{
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        //!< location service disabled
        [MBProgressHUD showError:@"定位服务不可用"];
        return;
    }
    
    if([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"网络似乎出了点问题"];
        
        return;
        
        
    }

    
    [self.manager startUpdatingLocation];

    
}



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
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"carLife_saveCar_back"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.view).offset(45);
        
        make.left.equalTo(self.view).offset(20);
        
        make.size.equalTo(CGSizeMake(33, 33));
        
    }];
    
//    [MBProgressHUD showMessage:@"正在加载数据"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBrnclickNotify:) name:kXMNaviToParkingStationNotification object:nil];
    
}

- (void)requestCityList
{
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *lastTimeStr = [[NSUserDefaults standardUserDefaults] stringForKey:kLastUpdateTime];
    
    XMLOG(@"last time - %@",lastTimeStr);

    
    if (lastTimeStr == nil)
    {
        //-- request city list
         [self sendRequestForCityList];
        
    }else
    {
        NSDate *lastdDate = [format dateFromString:lastTimeStr];
        
        NSDate *currentDate = [NSDate date];

        double interval = [lastdDate timeIntervalSinceDate:currentDate];
        
        NSLog(@"interval---%f",interval);
        
        //-- if time interval greater than five days,refresh city list
        if (interval > 60 * 60 *24 * 5)
        {
            //-- refresh city list
            [self sendRequestForCityList];
            
            XMLOG(@"refresh city list");

            
        }else
        {
        
            XMLOG(@"load source city list");

            //-- the time interval less than five days,return current city list
        
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            self.cityList = [NSArray arrayWithContentsOfFile:filePath];
            
            [self requestNearbyParking];
            
        }
    
    }
    
}

- (void)sendRequestForCityList
{
//    http://japi.juhe.cn/park/citylist.from  1a12913ca9de19f10c61db4f943be5f8
    
    [MBProgressHUD showMessage:nil];
    
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    
    paras[@"key"] = kParkingKey;
    
    [self.session POST:@"http://japi.juhe.cn/park/citylist.from" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        XMLOG(@"request city list success");
        [MBProgressHUD hideHUD];
        
        XMSearchCityListModel *model = [XMSearchCityListModel mj_objectWithKeyValues:responseObject];
        
        NSMutableArray *tem = [NSMutableArray arrayWithCapacity:model.result.count];
        
        for (XMParkSupportCityModel *city in model.result)
        {
             [tem addObject:city.cityName];
            
        }
        
        self.cityList = [tem copy];

        //-- write to local
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        
        [self.cityList writeToFile:filePath atomically:YES];
        
        //-- set save time
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        
        format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSString *timeStr = [format stringFromDate:[NSDate date]];
        
        NSLog(@"refresh time - %@",timeStr);
        
        [[NSUserDefaults standardUserDefaults] setObject:timeStr forKey:kLastUpdateTime];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self requestNearbyParking];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@" request city list failed erroe description %@",error);

        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"网络超时"];
        
    }];
    
    
}

//-- request nearby car park
- (void)requestNearbyParking
{
    if (!self.currentCity)
    {
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"获取位置信息失败"];
    }
    
    //-- whether support current city
    BOOL support = NO;
    
    NSString *temName = [self.currentCity stringByReplacingOccurrencesOfString:@"市" withString:@""];
    
    for (NSString *cityName in self.cityList)
    {
        
        if ([cityName containsString:temName])
        {
            support = YES;
            
            break;
        }
        
    }
    
    if (!support)
    {
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"当前城市不支持查询附近停车场"];
        
        return;
        
    }
    
    //-- request nearby park
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    
    paras[@"key"] = kParkingKey;
    
    paras[@"JLCX"] = @1000;
    
    paras[@"JD"] = @(self.currentLocation.coordinate.longitude);
    
    paras[@"WD"] = @(self.currentLocation.coordinate.latitude);
    
    paras[@"TCCFL"] = @4;
    
    paras[@"SDXX"] = @1;
    
    [MBProgressHUD showMessage:nil];
    
    [self.session POST:@"http://japi.juhe.cn/park/nearPark.from" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUD];
        
        XMParkSearchResultModel *model = [XMParkSearchResultModel mj_objectWithKeyValues:responseObject];
        
        if (model.result.count == 0)
        {
            [MBProgressHUD showError:@"没有发现附近的停车场"];
            
            return ;
        }
        
        [self treatData:model];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"网络超时"];
        
        XMLOG(@"request nearby park failed error description - %@",error);

        
    }];
    
    
    
}

- (void)treatData:(XMParkSearchResultModel*)model
{
    
    //!< if model.result count more than 20,delete which greater
    if (model.result.count > 20)
    {
        NSMutableArray *tem = [model.result mutableCopy];
        
        [tem removeObjectsInRange:NSMakeRange(21, tem.count - 21)];
        
        model.result = tem;
    }
    
    NSMutableArray *temArr = [NSMutableArray arrayWithCapacity:model.result.count];
    
    for (XMParkStationModel *smodel in model.result)
    {
        XMCarLife_SaveCarAnnotation *anno = [[XMCarLife_SaveCarAnnotation alloc]init];
        
        anno.coordinate = CLLocationCoordinate2DMake(smodel.WD.floatValue, smodel.JD.floatValue);
        
//        anno.title = smodel.CCID;
        
//        smodel.KCW = [NSString stringWithFormat:@"%d",arc4random_uniform(200)];
        
        //!< use the property of title and subtitle to record the total count of park and left park
        anno.title = smodel.ZCW;//!< total
        
        anno.subtitle = smodel.KCW;//!< left
        
        anno.model = smodel;
        
        [temArr addObject:anno];
    }
    
    [_mapView addAnnotations:temArr];
    
    [_mapView showAnnotations:temArr animated:YES];
    
    
    
}

#pragma mark -- CLLocationManagerDelegate


/*
 *  locationManager:didUpdateToLocation:fromLocation:
 *
 *  Discussion:
 *    Invoked when a new location is available. oldLocation may be nil if there is no previous location
 *    available.
 *
 *    This method is deprecated. If locationManager:didUpdateLocations: is
 *    implemented, this method will not be called.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_6, __MAC_NA, __IPHONE_2_0, __IPHONE_6_0) __TVOS_PROHIBITED __WATCHOS_PROHIBITED
{
    
    XMLOG(@"location did update");
    
    if(!self.isRequested)
    {
        
        //-- encode current location
        
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            if(!error)
              {
                
                CLPlacemark *placemark = placemarks.firstObject;
                
                  self.currentCity = placemark.addressDictionary[@"City"];
                  
                  self.currentLocation = newLocation;
                  
                  [[NSUserDefaults standardUserDefaults] setFloat:newLocation.coordinate.latitude forKey:@"parkLatitude"];
                  
                   [[NSUserDefaults standardUserDefaults] setFloat:newLocation.coordinate.longitude forKey:@"parkLongitude"];
                  
                  [[NSUserDefaults standardUserDefaults] synchronize];
                  
                  [self requestCityList];
                 
             }else
             {
                 [MBProgressHUD hideHUD];
                 
                 [MBProgressHUD showError:@"请求位置信息失败"];
                 
                 XMLOG(@"reverse geocoder failed");

             
             }
            
        }];
        
        self.isRequested = YES;
        
        [manager stopUpdatingLocation];
        
        /*
         placemark.addressDictionary:
         
         City = "深圳市";
         Country = "中国";
         CountryCode = CN;
         FormattedAddressLines =     (
         "中国广东省深圳市南山区粤海街道粤兴三道6号"
         );
         Name = "中山大学深圳产学研大楼-中大产研基地";
         State = "广东省";
         Street = "粤兴三道6号";
         SubLocality = "南山区";
         Thoroughfare = "粤兴三道6号";
         **/
        
        
        //-- request data
        
        

    }
    
    
    
}

#pragma mark ------- MapViewDelegate


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
 * @brief 根据anntation生成对应的View
 * @param mapView 地图View
 * @param annotation 指定的标注
 * @return 生成的标注View
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    
    
    if ([annotation isKindOfClass:[XMCarLife_SaveCarAnnotation class]])
    {
        static NSString *petrolIdetifier = @"petrolIdetifier";
        
        XMParkingCustomAnnotationView *view = (XMParkingCustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:petrolIdetifier];
        
        if (view == nil)
        {
            view = [[XMParkingCustomAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:petrolIdetifier];
            
        }
        
        view.canShowCallout = NO;
        
        view.centerOffset = CGPointMake(0, -18);
        
        float total = annotation.title.floatValue;
        
        int left = annotation.subtitle.intValue;
        
        float scale = left/total;
        
        NSLog(@"%f",scale);
        
        if (scale >= 0.3)
        {
            
            view.image = [UIImage imageNamed:@"carLife_saveCar_green"];
            
        }else if(scale < 0.3 && scale != 0)
        {
            view.image = [UIImage imageNamed:@"carLife_saveCar_red"];
        
        }else
        {
        
             view.image = [UIImage imageNamed:@"carLife_saveCar_no"];
        }
        
        
       
        
        
        
        
        return view;
        
    }
    
    
    
    return nil;
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


#pragma mark ------- btn click

- (void)locationBtnClick:(UIButton *)sender
{
    if (_mapView)
    {
        [_mapView showAnnotations:@[_mapView.userLocation] animated:YES];
        
        [_mapView setZoomLevel:17.5 animated:YES];
        
    }
    
}

/**
 * @brief back btn click
 */
- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
}



- (void)naviBrnclickNotify:(NSNotification *)noti
{
    
    
    
    MAAnnotationView *view = noti.userInfo[@"info"];
    
    [_mapView deselectAnnotation:view.annotation animated:YES];
    
    if ([noti.userInfo[@"error"] boolValue])
    {
        [MBProgressHUD showError:@"获取数据失败"];
        
    }else
    {
    
        float destinationLatitude = [noti.userInfo[@"latitude"] floatValue];
        
        float destinationLongitude = [noti.userInfo[@"longitude"] floatValue];
        
         [MBProgressHUD showMessage:@"正在规划路径"];
        
        //!< start navi
        AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:destinationLatitude longitude:destinationLongitude];
        
        AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:_mapView.userLocation.location.coordinate.latitude longitude:_mapView.userLocation.location.coordinate.longitude];
        
        [self.driveManager calculateDriveRouteWithStartPoints:@[startPoint] endPoints:@[endPoint] wayPoints:nil drivingStrategy:AMapNaviDrivingStrategySinglePrioritiseDistance];
    
    
    }
    
    
}


#pragma mark -- lazy

- (AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _session.requestSerializer.timeoutInterval = 5;
    }

    return _session;
    
}

-(CLLocationManager *)manager
{
    if (!_manager)
    {
        _manager = [[CLLocationManager alloc]init];
        
        _manager.delegate = self;
    }
    
    return _manager;
    
    
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


-(NSArray *)cityList
{
    if (!_cityList)
    {
        _cityList = [NSArray array];
    }

    return _cityList;
}


@end
