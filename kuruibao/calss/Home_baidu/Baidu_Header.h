//
//  Baidu_Header.h
//  kuruibao
//
//  Created by x on 17/6/20.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#ifndef Baidu_Header_h
#define Baidu_Header_h


#endif

/* Baidu_Header_h */
//
//  XMBaiduMapViewController.m
//  kuruibao
//
//  Created by x on 17/6/9.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMBaiduMapViewController.h"

#import "XMBauduMapSetingViewController.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>

#import <BaiduMapAPI_Location/BMKLocationComponent.h>

#import "AFNetworking.h"

#import "XMDefaultCarModel.h"

#import "XMBaiduLocationModel.h"

#import "XMCar.h"

#import "XMMapCustomCalloutView.h"

#define kCalloutWidth       220.0
#define kCalloutHeight      90.0


//#import "XMTestModel.h"

@interface XMBaiduMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>

@property (weak, nonatomic) IBOutlet BMKMapView *mapView;

//!< 定位服务
@property (strong, nonatomic) BMKLocationService *locationServer;

//!< 用户默认车辆
@property (strong, nonatomic) XMDefaultCarModel *defaultCar;

//!<  request manager
@property (strong, nonatomic) AFHTTPSessionManager *session;

/**
 用户位置信息
 */
@property (strong, nonatomic) BMKUserLocation *userLocation;

@property (nonatomic,strong)NSMutableArray<XMBaiduLocationModel *>* allmodels;//-- 全部数据模型

@property (nonatomic,strong)XMBaiduLocationModel* defaultModel;//-- 默认数据模型

@property (nonatomic,strong)NSMutableArray<XMBaiduLocationModel *>* drives;//-- 行驶的数据模型数组

@property (nonatomic,strong)NSMutableArray<XMBaiduLocationModel *>* stops;//-- 停驶的数据模型

@property (nonatomic,strong)NSMutableArray<XMBaiduLocationModel *>* lost;//-- 失联的数据模型

@property (weak, nonatomic) IBOutlet UIButton *stateBtn;//-- 需要显示当前车辆还是所有车辆的状态

@property (strong, nonatomic) NSMutableArray *annos;//!< 存放所有标注的数组

@property (assign, nonatomic) double maxX;

@property (assign, nonatomic) double maxY;

@property (assign, nonatomic) double minX;

@property (assign, nonatomic) double minY;

//@property (assign, nonatomic) BOOL lastSelected;//!< 按钮的选中状态

@end

@implementation XMBaiduMapViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        //!< 监听用户的默认车辆获取成功或全部车辆获取成功的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carInfodidChanged:) name:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil];
        
        //-- 启动定位服务
        _locationServer = [BMKLocationService new];
        
        _locationServer.delegate = self;
        
        [_locationServer startUserLocationService];
        
        
        if (isCompany)
        {
            self.stops = [NSMutableArray array];
            
            self.drives = [NSMutableArray array];
            
            self.lost = [NSMutableArray array];
            
        }
        
        self.allmodels = [NSMutableArray array];
        
        self.annos = [NSMutableArray array];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    [self setupSubviews];
    
    
    
    
}


/**
 init
 */
- (void)setupSubviews
{
    
    _mapView.showsUserLocation = YES;
    
    //!< 设置定位圈为跟随模式
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    
    _mapView.showMapScaleBar = YES;
    
    _mapView.mapScaleBarPosition = CGPointMake(60, mainSize.height - 60);
    
    _mapView.delegate = self;
    
    
    //!< 初始化显示全部标注的区域边界数据
    self.maxX = 0;
    
    self.maxY = 0;
    
    self.minX = 181;
    
    self.minY = 91;
    
    
}

#pragma mark ------- lazy

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

#pragma mark ------- 响应通知的方法
/*!
 @brief 监听用户更换默认车辆 || 获取全部车辆信息成功的通知
 */
- (void)carInfodidChanged:(NSNotification *)noti
{
    
    NSString *changMode = noti.userInfo[@"mode"];//!< 默认车辆发生变化还是全部车辆
    
    id object = noti.userInfo[@"result"];//!< 改变的结果
    
    if([changMode isEqualToString:@"car"])
    {
        XMLOG(@"默认车辆获取成功");
        
        XMDefaultCarModel *model = (XMDefaultCarModel *)object;
        
        self.defaultCar = model;
        
        XMBaiduLocationModel *dModel = [XMBaiduLocationModel new];
        
        dModel.qicheid = self.defaultCar.qicheid;
        
        dModel.tboxid = self.defaultCar.tboxid;
        
        dModel.chepaino = self.defaultCar.chepaino;
        
        dModel.carbrandid = self.defaultCar.carbrandid;
        
        if (isCompany)
        {
            //-- 设置状态
            switch (self.defaultCar.currentstatus.integerValue)
            {
                case 0:
                    dModel.showName = @"停驶";
                    break;
                case 1:
                    dModel.showName = @"行驶";
                    break;
                case 2:
                    dModel.showName = @"失联";
                    break;
                    
                default:
                    break;
            }
            
        }
        
        self.defaultModel = dModel;
        
        
    }else
    {
        
        
        [self.allmodels removeAllObjects];
        
        [self.stops removeAllObjects];
        
        [self.drives removeAllObjects];
        
        [self.lost removeAllObjects];
        
        
        //!< 全部车辆获取成功
        
        if (isCompany)
        {
            //-- 如果是企业用户的话，需要进行分类
            
            for (XMCar *temCar in object)
            {
                //--过滤无效车辆
                if (temCar.tboxid <= 0)continue;
                
                XMBaiduLocationModel *model = [XMBaiduLocationModel new];
                
                model.qicheid = [NSString stringWithFormat:@"%ld",temCar.qicheid];
                
                model.tboxid = [NSString stringWithFormat:@"%ld",temCar.tboxid];
                
                model.chepaino = temCar.chepaino;//!<车牌号码
                
                model.carbrandid = [NSString stringWithFormat:@"%ld",temCar.brandid];//!< 品牌编号
                
                XMLOG(@"---------%ld---------",temCar.carbrandid);
                
                if (isCompany)
                {
                    //-- 设置状态
                    switch (temCar.currentstatus)
                    {
                        case 0:
                            model.showName = @"停驶";
                            break;
                        case 1:
                            model.showName = @"行驶";
                            break;
                        case 2:
                            model.showName = @"失联";
                            break;
                            
                        default:
                            break;
                    }
                    
                }
                
                
                //                XMLOG(@"---------%@---------",model.showName);
                
                [self.allmodels addObject:model];
                
                switch (temCar.currentstatus)
                {
                    case 0:
                        
                        [self.stops addObject:model];
                        
                        break;
                        
                    case 1:
                        [self.drives addObject:model];
                        break;
                        
                    case 2:
                        
                        [self.lost addObject:model];
                        
                        break;
                        
                    default:
                        break;
                }
                
                
                
                
            }
            
            
            
        }else
        {
            
            //-- 不是企业用户，直接转模型
            for (XMCar *temCar in object)
            {
                //--过滤无效车辆
                if (temCar.tboxid <= 0)continue;
                
                XMBaiduLocationModel *model = [XMBaiduLocationModel new];
                
                model.qicheid = [NSString stringWithFormat:@"%ld",temCar.qicheid];
                
                model.tboxid = [NSString stringWithFormat:@"%ld",temCar.tboxid];
                
                model.chepaino = temCar.chepaino;//!<车牌号码
                
                model.carbrandid = [NSString stringWithFormat:@"%ld",temCar.brandid];//!< 品牌编号
                
                [self.allmodels addObject:model];
                
                
            }
            
        }
        
        
        
        
        
        
        
    }
    
}


#pragma mark ------- 按钮的点击事件

/**
 点击设置
 
 @param sender
 */
- (IBAction)settingClick:(id)sender {
    
    [self judge];
    
    XMBauduMapSetingViewController *vc = [XMBauduMapSetingViewController new];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

/**
 点击放大地图
 
 @param sender
 */
- (IBAction)enlargeClick:(id)sender {
    
    
    [_mapView zoomIn];
    
}

/**
 点击缩小地图
 
 @param sender
 */
- (IBAction)reduceClick:(id)sender {
    
    [_mapView zoomOut];
    
    
}

/**
 点击定位人按钮
 
 @param sender
 */
- (IBAction)userLocationClick:(id)sender {
    
    if (self.userLocation)
    {
        
        NSMutableArray *temArr = [NSMutableArray array];
        
        for (id obj in _mapView.annotations)
        {
            if ([obj isKindOfClass:[BMKUserLocation class]])
            {
                continue;
            }
            
            [temArr addObject:obj];
        }
        
        
        
        [_mapView removeAnnotations:temArr];
        
        BMKCoordinateRegion region;
        
        BMKCoordinateSpan span;
        
        span.latitudeDelta = 0.02;
        
        span.longitudeDelta = 0.02;
        
        region.center = _userLocation.location.coordinate;
        
        region.span = span;
        
        
        [_mapView setRegion:region animated:YES];
        
        
        
        
        
    }else
    {
        
        [MBProgressHUD showError:@"定位失败"];
        
    }
    
}


/**
 点击定位车按钮
 
 @param sender
 */
- (IBAction)carLocationClick:(id)sender {
    
    [self judge];
    
    //-- 显示当前车辆
    NSMutableArray *temArr = [NSMutableArray array];
    
    for (id anno in _mapView.annotations)
    {
        if ([anno isKindOfClass:[BMKUserLocation class]])
        {
            continue;
            
        }
        
        [temArr addObject:anno];
    }
    
    
    if (self.stateBtn.selected)
    {
        //-- 显示所有车辆
        
        //!< 如果存放标注的数组长度和存放模型的数组长度一直，且边界数据不等于初始化的值，就直接添加存放标注的数组
        if (self.annos.count == self.allmodels.count && self.maxX != 0 && self.maxY != 0 && self.minX != 181 && self.minY != 91 && 0)
        {
            [_mapView removeAnnotations:temArr];
            
            [_mapView addAnnotations:self.annos];
            
            //!< 显示区域
            BMKCoordinateRegion region;
            
            BMKCoordinateSpan span;
            
            span.latitudeDelta = _maxY - _minY + 0.09;
            
            span.longitudeDelta = _maxX - _minX + 0.09;
            
            region.center = CLLocationCoordinate2DMake((_minY + (_maxY - _minY)/2), (_minX + (_maxX - _minX)/2));
            
            region.span = span;
            
            [_mapView setRegion:region animated:YES];
            
            XMLOG(@"---------99999标注数组已经存在---------");
            
        }else
        {
            //!< 重新计算模型数组
            
            [self.annos removeAllObjects];
            
            for (XMBaiduLocationModel *model in self.allmodels)
            {
                
                
                if (model.annotation)
                {
                    
                    [_annos addObject:model.annotation];
                    
                    double longitude = model.annotation.coordinate.longitude;
                    
                    double latitude = model.annotation.coordinate.latitude;
                    
                    _maxX = longitude > _maxX ? longitude : _maxX;
                    
                    _maxY = latitude > _maxY ? latitude : _maxY;
                    
                    _minX = longitude < _minX ? longitude : _minX;
                    
                    _minY = latitude < _minY ? latitude : _minY;
                    
                    
                }else
                {
                    model.tboxid = model.tboxid;
                    
                }
                
            }
            
            [_mapView removeAnnotations:temArr];
            
            [_mapView addAnnotations:_annos];
            
            
            //!< 显示区域
            BMKCoordinateRegion region;
            
            BMKCoordinateSpan span;
            
            span.latitudeDelta = _maxY - _minY + 0.09;
            
            span.longitudeDelta = _maxX - _minX + 0.09;
            
            region.center = CLLocationCoordinate2DMake((_minY + (_maxY - _minY)/2), (_minX + (_maxX - _minX)/2));
            
            region.span = span;
            
            [_mapView setRegion:region animated:YES];
            
        }
        
    }else
    {
        
        //-- 移除原来标注，显示默认车辆
        [_mapView removeAnnotations:temArr];
        
        if (_defaultModel.annotation == nil)
        {
            [MBProgressHUD showError:@"正在获取位置信息"];
            
            _defaultModel.tboxid = _defaultModel.tboxid;
            
            return;
        }
        
        [_mapView addAnnotation:_defaultModel.annotation];
        //
        //        [_mapView showAnnotations:@[_defaultModel.annotation] animated:YES];
        
        
        //!< 显示区域
        BMKCoordinateRegion region;
        
        BMKCoordinateSpan span;
        
        span.latitudeDelta = 0.02;
        
        span.longitudeDelta = 0.02;
        
        region.center = _defaultModel.annotation.coordinate;
        
        region.span = span;
        
        
        [_mapView setRegion:region animated:YES];
        
    }
    
    
    
    
}

//-- 点击显示状态的按钮
- (IBAction)stateBtnClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    
}



#pragma mark --tools

- (void)judge
{
    
    //-- 判断网络
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showError:@"网络未连接"];
        
        return;
    }
    
    //-- 判断默认车辆
    if(self.defaultCar.tboxid == 0 || self.defaultCar.chepaino.length < 6)
    {
        
        [MBProgressHUD showError:@"未添加车辆"];
        
        return;
        
    }
    
    
    
}
#pragma mark ------- BMKMapViewDelegate

/**
 *地图初始化完毕时会调用此接口
 *@param mapview 地图View */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    
    [mapView updateLocationData:self.userLocation];
    
    [self userLocationClick:nil];
    
}




/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    
    
    if([annotation isKindOfClass:[BMKUserLocation class]])
    {
        
        return nil;
    }
    
    XMBaiduAnnotation *anno = (XMBaiduAnnotation *)annotation;
    
    BMKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
    
    if (view == nil)
    {
        view = [[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"identifier"];
    }
    
    view.canShowCallout = YES;
    
    //!< 显示在线还是不在线
    if ([anno.showName isEqualToString:@"行驶"])
    {
        
        view.image = [UIImage
                      imageNamed:@"map_annotation_online"];
        
    }else
    {
        view.image = [UIImage
                      imageNamed:@"map_annotation_offline"];
        
    }
    
    
    XMMapCustomCalloutView *contentView = [[XMMapCustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth,kCalloutHeight)];
    
    
    
    
    contentView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",anno.brindId]];
    
    if (contentView.image == nil)
    {
        contentView.image = [UIImage imageNamed:@"companyList_placeholderImahe"];
    }
    
    contentView.time = anno.deadLine;
    
    contentView.title = anno.carNumber;
    
    contentView.subtitle = anno.showName;
    
    
    BMKActionPaopaoView *pView = [[BMKActionPaopaoView alloc]initWithCustomView:contentView];
    
    pView.backgroundColor = XMClearColor;
    
    pView.frame = CGRectMake(0, 0, kCalloutWidth, kCalloutHeight);
    
    view.paopaoView = nil;
    
    view.paopaoView  = pView;
    
    
    return view;
    
}

/**
 *当mapView新添加annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 新添加的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    
    if ([[views.firstObject annotation] isKindOfClass:[BMKUserLocation class]])
    {
        BMKAnnotationView *view = views.firstObject;
        
        view.paopaoView = nil;
        
    }
    
    
}

/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    
}

/**
 *当取消选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 取消选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
    
}

/**
 *拖动annotation view时，若view的状态发生变化，会调用此函数。ios3.2以后支持
 *@param mapView 地图View
 *@param view annotation view
 *@param newState 新状态
 *@param oldState 旧状态
 */
- (void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState
   fromOldState:(BMKAnnotationViewDragState)oldState{
    
}

/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
    
}

/**
 *根据overlay生成对应的View
 *@param mapView 地图View
 *@param overlay 指定的overlay
 *@return 生成的覆盖物View
 */
//- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
//
//}

/**
 *当mapView新添加overlay views时，调用此接口
 *@param mapView 地图View
 *@param overlayViews 新添加的overlay views
 */
- (void)mapView:(BMKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    
}




#pragma mark ------- BMKLocationServiceDelegate

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    userLocation.title = nil;
    
    self.userLocation = userLocation;
    
    //-- 更新地图用户的位置
    //    [self.mapView updateLocationData:userLocation];
    
    
    
    
}


- (void)didFailToLocateUserWithError:(NSError *)error
{
    XMLOG(@"---------百度地图定位失败---------");
    
    self.userLocation = nil;
}

@end
