//
//  XMBaiduMapViewController.m
//  kuruibao
//
//  Created by x on 17/6/9.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMBaiduMapViewController.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>

#import <BaiduMapAPI_Location/BMKLocationComponent.h>

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

#import "AFNetworking.h"

#import "XMDefaultCarModel.h"

#import "XMBaiduLocationModel.h"

#import "XMCar.h"

#import "XMMapCustomCalloutView.h"

#import "BMKClusterManager.h"

#import "BMKClusterItem.h"

#define kCalloutWidth       220.0
#define kCalloutHeight      90.0


//#import "XMTestModel.h"
/*
 *点聚合Annotation
 */
@interface ClusterAnnotation : XMBaiduAnnotation

///所包含annotation个数
@property (nonatomic, assign) NSInteger size;

@end

@implementation ClusterAnnotation

//@synthesize size = _size;

@end


/*
 *点聚合AnnotationView
 */
@interface ClusterAnnotationView : BMKAnnotationView {
    
}

@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) UILabel *label;

@end

@implementation ClusterAnnotationView



- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setBounds:CGRectMake(0.f, 0.f, 48.f, 48.f)];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 48.f, 48.f)];
        
        _label.textColor = [UIColor whiteColor];
        
        _label.font = [UIFont systemFontOfSize:11];
        
        _label.textAlignment = NSTextAlignmentCenter;
        
        _label.clipsToBounds = YES;
        
        _label.layer.cornerRadius = 24;
        
        _label.layer.borderColor = [UIColor whiteColor].CGColor;
        
        _label.layer.borderWidth = 1;
        
        _label.userInteractionEnabled = YES;
        
        self.userInteractionEnabled = YES;
        
        [self addSubview:_label];
        
//        self.alpha = 0.85;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kClusterAnnotationViewDidClickNotification" object:nil userInfo:@{@"info":self}];

}

- (void)setSize:(NSInteger)size {
    _size = size;
    if (_size == 1) {
        self.label.hidden = YES;
//        self.pinColor = BMKPinAnnotationColorRed;
        
       
        
        return;
    }
    self.label.hidden = NO;
    if (size > 50) {
        
        self.label.backgroundColor = XMColor(0x18, 0x7a, 0xe5);
//        self.label.backgroundColor = [UIColor redColor];
        
    } else if (size > 10) {
        
        self.label.backgroundColor = XMColor(0x5d, 0xd6, 0x72);
//         self.label.backgroundColor = [UIColor orangeColor];
        
    } else {
        
        self.label.backgroundColor = XMColorFromRGB(0xc5c5c5);
//         self.label.backgroundColor = [UIColor blueColor];
        
    }
    
    _label.text = [NSString stringWithFormat:@"%ld", size];
}

@end
@interface XMBaiduMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>{

    NSInteger _clusterZoom;//聚合级别
    NSMutableArray *_clusterCaches;//点聚合缓存标注
}

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

@property (strong, nonatomic) NSMutableDictionary *annos;//!< 存放所有标注的数组

@property (assign, nonatomic) double maxX;

@property (assign, nonatomic) double maxY;

@property (assign, nonatomic) double minX;

@property (assign, nonatomic) double minY;

@property (strong, nonatomic)BMKClusterManager  *clusterManager;//!< 点聚合管理类

//@property (assign, nonatomic) BOOL lastSelected;//!< 按钮的选中状态

@property (assign, nonatomic) BOOL canChange;//!< 是否需要更新聚合点

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
        
        _clusterManager = [BMKClusterManager new];

        
        if (isCompany)
        {
            self.stops = [NSMutableArray array];
            
            self.drives = [NSMutableArray array];
            
            self.lost = [NSMutableArray array];
            
        }
        
        self.allmodels = [NSMutableArray array];
        
        self.annos = [NSMutableDictionary dictionary];
        
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
    
    _clusterCaches = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 3; i < 22; i++) {
        [_clusterCaches addObject:[NSMutableArray array]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveClickClusterAnnoViewNotification:) name:@"kClusterAnnotationViewDidClickNotification" object:nil];
    
}


- (void)receiveClickClusterAnnoViewNotification:(NSNotification *)noti
{
    
    ClusterAnnotationView *view = noti.userInfo[@"info"];
    
    [self mapView:_mapView didSelectAnnotationView:view];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    MobClickBegain(@"百度地图主界面");
   
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    
    MobClickEnd(@"百度地图主界面");
}


//更新聚合状态
- (void)updateClusters {
    _clusterZoom = (NSInteger)_mapView.zoomLevel;
    @synchronized(_clusterCaches) {
        __block NSMutableArray *clusters = [_clusterCaches objectAtIndex:(_clusterZoom - 3)];
        
        if (clusters.count > 1000) {
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotations:clusters];
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                ///获取聚合后的标注
                __block NSArray *array = [_clusterManager getClusters:_clusterZoom];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    for (BMKCluster *item in array) {
                        
                        ClusterAnnotation *annotation = [[ClusterAnnotation alloc] init];
                        
                        annotation.coordinate = item.coordinate;
                        
                        annotation.size = item.size;
                        
                        annotation.title = nil;
                        
                        NSString *key = [NSString stringWithFormat:@"%.6f+%.6f",annotation.coordinate.longitude,annotation.coordinate.latitude];
                        
                        if([self.annos objectForKey:key])
                        {
                            //!< 如果存在值的话就赋值给anno
                            XMBaiduAnnotation *anno = [self.annos objectForKey:key];
                            
                            annotation.deadLine = anno.deadLine;
                            annotation.brindId = anno.brindId;
                            annotation.carNumber = anno.carNumber;
                            annotation.showName = anno.showName;
                        
                        
                        }
                        
                        
                        [clusters addObject:annotation];
                    }
                    
                    [_mapView removeAnnotations:_mapView.annotations];
                    
                    [_mapView addAnnotations:clusters];
                    
                });
            });
        }
    }
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
        
        
        dModel.qicheid = self.defaultCar.qicheid;
        
        dModel.tboxid = self.defaultCar.tboxid;
        
        dModel.chepaino = self.defaultCar.chepaino;
        
        dModel.carbrandid = self.defaultCar.carbrandid;
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
            int index = 0;
            //-- 如果是企业用户的话，需要进行分类
            for (XMCar *temCar in object)
            {
                
                
                
//                XMLOG(@"---%d------Joyce qicheid:%ld,tboxid:%ld---------",index,temCar.qicheid,temCar.tboxid);
                index++;
                //--过滤无效车辆
//                if (temCar.tboxid <= 0)continue;
                
                XMBaiduLocationModel *model = [XMBaiduLocationModel new];
                
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
                model.qicheid = [NSString stringWithFormat:@"%ld",temCar.qicheid];
                
                model.tboxid = [NSString stringWithFormat:@"%ld",temCar.tboxid];
                
                
                model.chepaino = temCar.chepaino;//!<车牌号码
                
                model.carbrandid = [NSString stringWithFormat:@"%ld",temCar.brandid];//!< 品牌编号
                
                
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
                
               model.carbrandid = [NSString stringWithFormat:@"%ld",temCar.carbrandid];//!< 品牌编号
                
                [self.allmodels addObject:model];
                
                
            }
            
        }
        
        
    }
    
}


#pragma mark ------- 按钮的点击事件


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
    
    self.canChange = NO;
    
    if (self.userLocation)
    {
        
//        NSMutableArray *temArr = [NSMutableArray array];
//        
//        for (id obj in _mapView.annotations)
//        {
//            if ([obj isKindOfClass:[BMKUserLocation class]])
//            {
//                continue;
//            }
//            
//            [temArr addObject:obj];
//        }
        
       
        
        
        
        BMKCoordinateRegion region;
        
        BMKCoordinateSpan span;
        
        span.latitudeDelta = 0.02;
        
        span.longitudeDelta = 0.02;
        
        region.center = _userLocation.location.coordinate;
        
        region.span = span;
       
        [_mapView removeAnnotations:_mapView.annotations];
        
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
            self.canChange = YES;
            
            [self.annos removeAllObjects];
        
            [_clusterManager clearClusterItems];
            
            for (XMBaiduLocationModel *model in self.allmodels)
            {
            
                
                if (model.annotation)
                {
                
                    
                
                    double longitude = model.annotation.coordinate.longitude;
                
                    double latitude = model.annotation.coordinate.latitude;
                    
                    NSString *key = [NSString stringWithFormat:@"%.6f+%.6f",longitude,latitude];
                    
                    [self.annos setObject:model.annotation forKey:key];
                
                    _maxX = longitude > _maxX ? longitude : _maxX;
                
                    _maxY = latitude > _maxY ? latitude : _maxY;
                    
                    _minX = longitude < _minX ? longitude : _minX;
                
                    _minY = latitude < _minY ? latitude : _minY;
                    
                    //!< 添加需要点聚合的数据
                    BMKClusterItem *item = [[BMKClusterItem alloc]init];
                    
                    item.coor = model.annotation.coordinate;
                    
                    [_clusterManager addClusterItem:item];
                
                
                }else
                {
                    model.tboxid = model.tboxid;
                    
                }
            
            }
        
            [_mapView removeAnnotations:temArr];
            
//            [_mapView addAnnotations:_annos];
            [self updateClusters];
        
        
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
    
        self.canChange = NO;
        //-- 移除原来标注，显示默认车辆
        [_mapView removeAnnotations:temArr];
        
        if (_defaultModel.noLocation)
        {
            [MBProgressHUD showError:@"无法获取当前车辆位置信息"];
            
             return;
        }
        
        
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
    
    [MobClick event:@"Switch"];
    
    XMLOG(@"---------youmeng 切换车辆---------");
    
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
    
    _clusterZoom = mapView.zoomLevel;
    
}




/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    
    
    //!< 如果是用户位置就返回nil，系统自行处理
    if([annotation isKindOfClass:[BMKUserLocation class]])
    {
        
        return nil;
    }
    
    
    //!< 如果是聚合的标注：
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
            //!< 当聚合的点大于1的时候，返回对应的原型标注视图
            if ([(ClusterAnnotation *)annotation size] > 1)
            {
                
                //普通annotation
                NSString *AnnotationViewID = @"ClusterMark";
                ClusterAnnotation *cluster = (ClusterAnnotation*)annotation;
                ClusterAnnotationView *annotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
                
                if (annotationView == nil)
                {
                  annotationView = [[ClusterAnnotationView alloc] initWithAnnotation:cluster reuseIdentifier:AnnotationViewID];
                    
                }
               
                annotationView.size = cluster.size;
    
                return annotationView;
                
            }
        
        //!< 当聚合的点小于1的时候，就返回自定义的百度视图
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
            
            view.frame = CGRectMake(0, 0, 25, 35);
                
            return view;
    
    }else
    {
        
        //!< 当不是聚合点的时候和聚合点小于1的处理方法一样
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
        
        view.frame = CGRectMake(0, 0, 25, 35);
        
        return view;
    
    }
}

/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
//    if ([view isKindOfClass:[ClusterAnnotationView class]]) {
//        ClusterAnnotation *clusterAnnotation = (ClusterAnnotation*)view.annotation;
//        if (clusterAnnotation.size > 1) {
//            [mapView setCenterCoordinate:view.annotation.coordinate];
//            [mapView zoomIn];
//        }
//    }
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
    
    
    if ([view isKindOfClass:[ClusterAnnotationView class]]) {
        ClusterAnnotation *clusterAnnotation = (ClusterAnnotation*)view.annotation;
        if (clusterAnnotation.size > 1) {
            
            [mapView setCenterCoordinate:view.annotation.coordinate];
            [mapView zoomIn];
            
            if (_mapView.zoomLevel == 21)
            {
                [self.mapView removeAnnotations:_mapView.annotations];
                
                NSMutableArray *annos = [NSMutableArray array];
                
                for (XMBaiduLocationModel *model in self.allmodels)
                {
                    
                    
                    if (model.annotation)
                    {
                        [annos addObject:model.annotation];
                       
                        
                    }else
                    {
                        model.tboxid = model.tboxid;
                        
                    }
                    
                }
                
                
                    [_mapView addAnnotations:annos];
  
            }
            
        } }
}

/**
 *当取消选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 取消选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
    
}




/**
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    
        if (self.canChange) {
            if (_clusterZoom != 0 && _clusterZoom != (NSInteger)mapView.zoomLevel) {
                [self updateClusters];
            }
        }
    
    ///获取聚合后的标注
//    NSArray *array = [_clusterManager getClusters:_mapView.zoomLevel];
//    NSMutableArray *clusters = [NSMutableArray array];
//    for (BMKCluster *item in array) {
//        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
//        annotation.coordinate = item.coordinate;
////        annotation.size = item.size;
//        annotation.title = [NSString stringWithFormat:@"我是%ld个", item.size];
//        [clusters addObject:annotation];
//    }
//    [_mapView removeAnnotations:_mapView.annotations];
//    [_mapView addAnnotations:clusters];
//


}


#pragma mark ------- BMKLocationServiceDelegate

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    userLocation.title = nil;
    
    self.userLocation = userLocation;
  
    
    
}


- (void)didFailToLocateUserWithError:(NSError *)error
{
    XMLOG(@"---------百度地图定位失败---------");

    self.userLocation = nil;
}

@end
