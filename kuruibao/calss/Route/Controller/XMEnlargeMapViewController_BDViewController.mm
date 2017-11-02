//
//  XMEnlargeMapViewController_BDViewController.m
//  kuruibao
//
//  Created by X on 2017/6/3.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//



#import "XMEnlargeMapViewController_BDViewController.h"

#import "XMUser.h"
#import "XMTrackLocationModel.h"

#import "NSString+extention.h"
#import "NSDictionary+convert.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

#import "BMKSportNode.h"

//#define animateSpeed 10 //动画时长系数，参数越小，动画时间越长

#define kAngle 3  //角度
#define kDistance 9  //距离
#define kSpeed 18  //速度

#define pi 3.14159265358979323846

#define degreesToRadian(x) (pi * x / 180.0)

#define radiansToDegrees(x) (180.0 * x / pi)

#define animationTime 15


// 运动结点信息类
//@interface BMKSportNode : NSObject
//
////经纬度
//@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
////方向（角度）
//@property (nonatomic, assign) CGFloat angle;
////距离
//@property (nonatomic, assign) CGFloat distance;
////速度
//@property (nonatomic, assign) CGFloat speed;
//
//@end
//
//@implementation BMKSportNode

//@synthesize coordinate = _coordinate;
//@synthesize angle = _angle;
//@synthesize distance = _distance;
//@synthesize speed = _speed;
//
//@end

// 自定义BMKAnnotationView，用于显示运动者
@interface SportAnnotationView : BMKAnnotationView

@property (nonatomic, strong) UIImageView *imageView;



@end

@implementation SportAnnotationView

@synthesize imageView = _imageView;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBounds:CGRectMake(0.f, 0.f, 22.f, 22.f)];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 22.f, 22.f)];
        _imageView.image = [UIImage imageNamed:@"icon_center_point.png"];
        [self addSubview:_imageView];
    }
    return self;
}

@end


@interface XMEnlargeMapViewController_BDViewController ()<BMKMapViewDelegate>
{
    BMKPolyline *pathPloygon;
    BMKPointAnnotation *sportAnnotation;
    SportAnnotationView *sportAnnotationView;
    
    NSMutableArray *sportNodes;//轨迹点
    NSInteger sportNodeNum;//轨迹点数
    NSInteger currentIndex;//当前结点

}

@property (assign, nonatomic) double totalDistance;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (nonatomic,weak)BMKMapView* mapView;


@property (nonatomic)BMKCoordinateRegion regon;

@property (nonatomic,assign)int animateSpeed;

/**
 平均速度
 */
@property (assign, nonatomic) double  averageSpeed;

@end

@implementation XMEnlargeMapViewController_BDViewController

//!< 计算两点间距离
CGFloat distanceBetweenPoints (CGPoint first, CGPoint second) {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
}



//!< 计算两点之间角度
CGFloat angleBetweenPoints(CGPoint first, CGPoint second) {
    CGFloat height = second.y - first.y;
    CGFloat width = first.x - second.x;
    CGFloat rads = atan(height/width);
    return rads;//!< 返回弧度
//    return radiansToDegrees(rads);//返回角度
    //degs = degrees(atan((top - bottom)/(right - left)))
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //!< 初始化界面
    [self setupSubviews];
    
    
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    MobClickBegain(@"百度地图轨迹回放界面");
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    
    MobClickEnd(@"百度地图轨迹回放界面");
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    

}

- (void)setupSubviews
{
    
//    self.animateSpeed = arc4random_uniform(3) + 1;
    
    self.view.backgroundColor = XMWhiteColor;
    
    //!< 显示导航
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationItem.title = @"轨迹回放";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backItemClcik)];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{
                                                                    NSForegroundColorAttributeName:[UIColor blackColor]
                                                                    
                                                                    } forState:UIControlStateNormal];
    
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showError:@"网络未连接"];
        
        return;
        
    }
    
    //-- 构造百度地图
    BMKMapView *mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    
//    mapView.userTrackingMode = BMKUserTrackingModeFollow;
    
//    mapView.showsUserLocation = YES;
    
    mapView.mapType = BMKMapTypeStandard;
    
    [self.view addSubview:mapView];
    
    self.mapView = mapView;
    
    [self hideLogo];
    
    //!< 开始转模型，查找位置，添加遮盖
    [self searchLocation];
    
    
    
}

#pragma mark ---------- lazy

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

#pragma mark ------- btn click


/**
 * @brief 点击返回按钮触发
 */
- (void)backItemClcik
{
    self.navigationItem.title = nil;
    
    self.navigationController.navigationBar.hidden = YES;
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}



#pragma mark ------- searchLocaton

/**
 * @brief 获取当前行程id对应的一系列的坐标点
 */
- (void)searchLocation
{
    
    //!< 获取一段行程内的GPS数据
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_xc_gps_byxcid&qicheid=%@&Xingchengid=%@",_qicheid,self.segmentData.xingchengid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
//        XMLOG(@"---------%@---------",dic);
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if (result.length > 2)
        {
            //!< 获取GPS数据成功
            
            NSArray *locationArray = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            [self parserLocationData:locationArray];//!< 解析坐标数组
            
        }else
        {
            
            //!< 0 : 没有行程数据 1 :参数或网络错误
            [MBProgressHUD showError:@"没有行程数据"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                
                [self backItemClcik];
            });
            
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        [MBProgressHUD showError:@"获取数据失败"];
    }];
    
    
    
}


//!< 解析请求来的位置数据
- (void)parserLocationData:(NSArray *)array
{

    
    double maxLatitude = 0;
    
    double minLatitude = 91;
    
    double maxLongitude = 0;
    
    double minLongitude = 181;
    
    double lastX = 0;
    
    double lastY = 0;
    
    
    sportNodes = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dic in array)
    {
       NSDictionary * newDic = [NSDictionary nullDic:dic];
        
        
        double latitude = [newDic[@"locationy"] doubleValue];
        
        double longitude = [newDic[@"locationx"] doubleValue];
        
        
        
        //-- 求最大经度
        maxLongitude = MAX(maxLongitude, longitude);
        
        //-- 求最大纬度
        maxLatitude = MAX(maxLatitude, latitude);
        
        //-- 求最小经度
        minLongitude = MIN(minLongitude, longitude);
        
        //-- 求最小纬度
        minLatitude = MIN(minLatitude, latitude);
        
        
        BMKSportNode *node = [BMKSportNode new];
        
        node.coordinate = CLLocationCoordinate2DMake(latitude,longitude);
        
        BMKMapPoint p = BMKMapPointForCoordinate(node.coordinate);
        
//        XMLOG(@"---------Joyce p.x:%f  p.y:%f---------",p.x,p.y);
        
        
//        node.angle = kAngle;
        
//        node.speed = kAngle;
        
//        node.distance = kDistance;
        
        
        //!< 计算总距离
        if (lastX > 0 && lastY > 0)
        {
            CGPoint p1 = CGPointMake(lastX, lastY);
            
            CGPoint p2 = CGPointMake(longitude, latitude);
            
            float distance = distanceBetweenPoints(p1, p2);
            
            node.distance = distance;//!< 当前点对上一个点的距离
            
            self.totalDistance += distance;//!< 总距离
            
            node.angle = angleBetweenPoints(p1, p2);//当前点对上一个点的角度
            
            
        }else
        {
            lastX = longitude;
            
            lastY = latitude;
            
            node.distance = -1;//标记第一个节点的距离
        }

        [sportNodes addObject:node];
        
    }
    
    self.averageSpeed = self.totalDistance / animationTime; //!< 平均速度
    
    sportNodeNum = sportNodes.count;
    
    //-- 计算地图显示区域regon
    
    //-- 经度范围
    double longitudeScope = maxLongitude - minLongitude;
    
    //-- 纬度范围
    double latitudeScope = maxLatitude - minLatitude;
    
    BMKCoordinateSpan span;
    
    span.latitudeDelta = latitudeScope;
    
    span.longitudeDelta = longitudeScope;
    
    
    //-- 计算中心经纬度坐标点
    double centerX = minLongitude + longitudeScope/2;
    
    double centerY = minLatitude + latitudeScope/2;
    
    BMKCoordinateRegion regon;
    
    regon.span = span;
    
    regon.center = CLLocationCoordinate2DMake(centerY, centerX);
    
    self.regon = regon;
   
    
    [self start];
    
}

//开始
- (void)start {
    CLLocationCoordinate2D paths[sportNodeNum];
    for (NSInteger i = 0; i < sportNodeNum; i++) {
        BMKSportNode *node = sportNodes[i];
        paths[i] = node.coordinate;
    }
   pathPloygon = [BMKPolyline polylineWithCoordinates:paths count:sportNodeNum];
//    pathPloygon = [BMKPolygon polygonWithCoordinates:paths count:sportNodeNum];
    [_mapView addOverlay:pathPloygon];
    
    
    
    //-- 添加动画标注
    sportAnnotation = [[BMKPointAnnotation alloc]init];
    sportAnnotation.coordinate = paths[0];
    sportAnnotation.title = @"test";
    [_mapView addAnnotation:sportAnnotation];
    
    //-- 添加起点标注
    BMKPointAnnotation *start = [[BMKPointAnnotation alloc]init];
    
    start.coordinate = paths[0];
    
    start.title = @"start";
    
    [_mapView addAnnotation:start];
    
    //-- 添加终点标注
    BMKPointAnnotation *end = [[BMKPointAnnotation alloc]init];
    
    end.title = @"end";
    
    end.coordinate = paths[sportNodeNum -1];
    
    [_mapView addAnnotation:end];
    
//    [_mapView showAnnotations:@[start,end] animated:YES];
    
    [_mapView setRegion:self.regon animated:YES];
    
    currentIndex = 1;
}

//runing
- (void)running {
    
    BMKSportNode *node = [sportNodes objectAtIndex:currentIndex % sportNodeNum];
    
    sportAnnotationView.imageView.transform = CGAffineTransformMakeRotation(node.angle);
    
    float time = node.distance/self.averageSpeed;
    
  
    [UIView animateWithDuration:time animations:^{
    
        sportAnnotation.coordinate = node.coordinate;
        
          currentIndex++;
        
        
    } completion:^(BOOL finished) {
        
        if (currentIndex == sportNodeNum)
        {
            return;//-- 结束动画
        }
        
        [self running];
    }];
    
//    BMKSportNode *node = [sportNodes objectAtIndex:currentIndex % sportNodeNum];
//    sportAnnotationView.imageView.transform = CGAffineTransformMakeRotation(node.angle);
//    [UIView animateWithDuration:node.distance/node.speed animations:^{
//        currentIndex++;
//        BMKSportNode *node = [sportNodes objectAtIndex:currentIndex % sportNodeNum];
//        sportAnnotation.coordinate = node.coordinate;
//    } completion:^(BOOL finished) {
//        if (currentIndex == sportNodeNum-1)
//        {
//            return;//-- 结束动画
//        }
//        
//        [self running];
//    }];
   
    
}

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolygon class]])
    {
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [UIColor redColor];
        polygonView.lineWidth = 4.0;
        return polygonView;
    }
    
    if ([overlay isKindOfClass:[BMKPolyline class]])
    {
        BMKPolylineView *view = [[BMKPolylineView alloc]initWithPolyline:overlay];
        
        view.strokeColor = XMColor(100, 170, 216);
        
        view.lineWidth = 2;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           
            [_mapView zoomOut];
            
        });
        
        return view;
    }
    
    return nil;
}


// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    if ([annotation.title isEqualToString:@"start"] || [annotation.title isEqualToString:@"end"] )
    {
        //-- 起点终点对应的标注
        
        BMKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"point"];
        
        if (view == nil)
        {
            view = [[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"point"];
        }
        
        if ([annotation.title isEqualToString:@"start"])
        {
            view.image = [UIImage imageNamed:@"annotation_start"];
            
            NSLog(@"开始标注");
            
            
        }else
        {
            NSLog(@"结束标注");
            view.image = [UIImage imageNamed:@"annotation_end"];
            
            
        }
        
        view.centerOffset = CGPointMake(0, -12);
        return view;
        
    }
    
    if (sportAnnotationView == nil) {
        sportAnnotationView = [[SportAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"sportsAnnotation"];
        
        
        sportAnnotationView.draggable = NO;
        BMKSportNode *node = [sportNodes firstObject];
        sportAnnotationView.imageView.transform = CGAffineTransformMakeRotation(node.angle);
        
    }
    return sportAnnotationView;
}

- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
    
    for (UIView *view in views)
    {
        if ([view isKindOfClass:[SportAnnotationView class]]) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
            
            [self running];
            
            });
            
            return;
        }
    }
    
    
}



/**
 隐藏logo
 */
- (void)hideLogo
{
    
    for (UIView *subview in _mapView.subviews)
    {
        if (subview.subviews.count > 0)
        {
            for (UIView *s in subview.subviews)
            {
                
                XMLOG(@"Joyce-----ss----%@---------",s);
                
                if ([s isKindOfClass:[UIImageView class]])
                {
                    s.hidden = YES;
                }
                
            }
        }
        
    }
    
    
    
    
}




#pragma mark ------- dealloc

- (void)dealloc
{
    
    if (_mapView)
    {
        _mapView = nil;
    }
    
    NSLog(@"当前页面已经销毁------------------------------999");
    
}





@end
