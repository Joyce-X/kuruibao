//
//  XMEnlargeMapViewController.m
//  kuruibao
//
//  Created by x on 17/3/20.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
 点击上一页面的地图，进入当前界面，负责动态显示这一段行程的路径，
 
 附加：已经显示的路径，显示为其他颜色，显示急转弯，急加速的点
 
 ************************************************************************************************/

#import "XMEnlargeMapViewController.h"
#import "XMUser.h"
#import "XMTrackLocationModel.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "NSString+extention.h"
#import "NSDictionary+convert.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "XMAnimateAnnotation.h"


#define animationFactor 10 //动画时长系数，参数越小，动画时间越长

@interface XMEnlargeMapViewController ()<MAMapViewDelegate>



@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (strong, nonatomic) MAPointAnnotation *startAnno;//!< 起点标注

@property (strong, nonatomic) MAPointAnnotation *endAnno;//!< 终点标注

@property (strong, nonatomic) MAPolyline *polyline;//!< 整体路径遮盖

@property (strong, nonatomic) MAMapView *mapView;

@property (strong, nonatomic) XMAnimateAnnotation *animationAnno;//!< 动画标注

/**
 动画的时间
 */
@property (assign, nonatomic) float animationTime;

@end

@implementation XMEnlargeMapViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    //!< 初始化界面
    [self setupSubviews];
    
    
    
 }


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"高德地图轨迹回放界面");

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.animationAnno)
    {
        for (MAAnnotationMoveAnimation *movie in self.animationAnno.allMoveAnimations) {
            
            [movie cancel];
            
        }
    }

    MobClickEnd(@"高德地图轨迹回放界面");
    

}

- (void)setupSubviews
{
    
    self.view.backgroundColor = XMWhiteColor;
    
    //!< 显示导航
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationItem.title = @"轨迹回放";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backItemClcik)];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{
                                                                    NSForegroundColorAttributeName:[UIColor blackColor]
                                                                   
                                                                    } forState:UIControlStateNormal];
    
//    self.qicheid = [XMUser user].qicheid;
    
    
    //!< 添加地图
    self.mapView = [[MAMapView alloc]init];
    
    _mapView.delegate = self;
    
    _mapView.showsScale = NO;
    
    _mapView.showsCompass = NO;
    
    _mapView.zoomLevel = 18;
    
    _mapView.mapType = MAMapTypeStandard;
    
    
    [self.view addSubview:_mapView];
    
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.right.left.bottom.equalTo(self.view);
        
        
    }];
    
    
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showError:@"网络未连接"];
        
        return;
    
    }
    
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


/**
 * @brief 点击显示全部路径或者终点和起点
 */
- (void)backBtnClick:(UIButton *)sender
{
    
     if (sender.selected)
    {
        [self.mapView showOverlays:@[_polyline]  animated:YES];
    }else
    {
        [self.mapView showAnnotations:@[_startAnno,_endAnno] animated:YES];
    
    }
    
    sender.selected = !sender.selected;
    
    
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
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        XMLOG(@"---------%@---------",dic);
        
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
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:array.count];
    
     //-- 取出路径所有形状点个数
    NSInteger count = array.count;
    
    //!< 设置动画时间
    self.animationTime = (int)count * 1.0 / animationFactor;
    
    
    XMLOG(@"---------动画时间为-%f秒---------",self.animationTime);
    
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++)
    {
        NSDictionary *dic = [NSDictionary nullDic:array[i]];
        
        //!< 百度坐标转换高德坐标
        CLLocationCoordinate2D baiduLocation = CLLocationCoordinate2DMake([dic[@"locationy"] doubleValue], [dic[@"locationx"] doubleValue]);

        CLLocationCoordinate2D gaodeLocation = AMapCoordinateConvert(baiduLocation, AMapCoordinateTypeBaidu);
//        CLLocationCoordinate2D temLocation = AMapCoordinateConvert(baiduLocation, AMapCoordinateTypeBaidu);
        
        //!< 近似转换
        
//        CLLocationCoordinate2D gaodeLocation  = CLLocationCoordinate2DMake(temLocation.latitude + 0.0060, temLocation.longitude += 0.0065);
        
        XMTrackLocationModel *model = [XMTrackLocationModel new];
        
        model.locationx = gaodeLocation.longitude;
        
        model.locationy = gaodeLocation.latitude;
        
        model.eventType = dic[@"eventtype"];
        
//#warning ---  add speed up annotation
        /*
        //!< 添加急刹车急加油标注   待解决
        if ([model.eventType isEqualToString:@"10"] || [model.eventType isEqualToString:@"11"])
        {
            [self.pointArray addObject:model];
            
            //!< 急刹车急加油模型部分
            NSLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        }
        **/
        [arrM addObject:model];
        
        coords[i].latitude = model.locationy;
        coords[i].longitude = model.locationx;
    }
    
    //!< 添加遮盖
    self.polyline = [MAPolyline polylineWithCoordinates:coords count:count];
    
    
    //-- 删除所有遮盖
    [_mapView removeOverlays:_mapView.overlays];
    
    [_mapView addOverlay:_polyline];
    
    
    //!< 起点
    XMTrackLocationModel *startModel = [arrM firstObject];
    
    //!< 终点
    XMTrackLocationModel *endModel = [arrM lastObject];
 
   
    
    //!< 添加起点和终点的标注
    MAPointAnnotation *anno_start = [[MAPointAnnotation alloc]init];
    
    anno_start.title = @"start";
    
    anno_start.coordinate = CLLocationCoordinate2DMake(startModel.locationy, startModel.locationx);
    
    self.startAnno = anno_start;
    
    MAPointAnnotation *anno_end = [[MAPointAnnotation alloc]init];
    
    anno_end.title = @"end";
    
    anno_end.coordinate = CLLocationCoordinate2DMake(endModel.locationy, endModel.locationx);
    
    self.endAnno = anno_end;
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    [_mapView addAnnotations:@[anno_start,anno_end]];
 
    
   
    
    //!< 首先显示全部路程
//    [_mapView showAnnotations:@[anno_start,anno_end] animated:YES];
    
    //!< 显示所有轨迹
    [_mapView showOverlays:@[self.polyline] edgePadding:UIEdgeInsetsMake(30, 30, 30, 30) animated:YES];
    
    //!< 间隔一秒开始显示动画
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        //!< 添加动画的标注
        XMAnimateAnnotation *animatAnnotation = [[XMAnimateAnnotation alloc]init];
        
        animatAnnotation.title = @"car";
        
        animatAnnotation.coordinate = CLLocationCoordinate2DMake(startModel.locationy, startModel.locationx);
        
        [self.mapView addAnnotation:animatAnnotation];
        
        self.animationAnno = animatAnnotation;
        
        [animatAnnotation addMoveAnimationWithKeyCoordinates:coords count:count withDuration:self.animationTime withName:@"carAnimation" completeCallback:^(BOOL isFinished) {
            
            [_mapView showOverlays:@[_polyline] animated:YES];
            
            //-- 释放内存
            free(coords);
            
        }];
        
    });
   
    
}

#pragma mark -------------- MAMapViewDelegate

/**
 * @brief 将要显示标注的时候调用
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
        //!< 区分进行处理
    if([annotation isKindOfClass:[MAAnimatedAnnotation class]])
    {
        static NSString *carIdentifier = @"carIdentifier";
        //!< 生成汽车标注
        MAAnnotationView *carView = [mapView dequeueReusableAnnotationViewWithIdentifier:carIdentifier];
        
        if (carView == nil)
        {
            carView = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:carIdentifier];
            
             carView.image = [UIImage imageNamed:@"car"];
        }
    
       
    
        carView.canShowCallout = NO;
        
        return carView;
    
    }else
    {
    
        static NSString*identifier_AnnoView = @"identifier_AnnoView";
    
        MAAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier_AnnoView];
        
        if (view == nil) {
    
            view = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier_AnnoView];
        }
        
        MAPointAnnotation *anno = (MAPointAnnotation *)annotation;
      
        if ([anno.title isEqualToString:@"start"])
        {
            view.image = [UIImage imageNamed:@"annotation_start"];

            NSLog(@"开始标注");
            

        }else
        {
            NSLog(@"结束标注");
            view.image = [UIImage imageNamed:@"annotation_end"];

 
        }
 
        view.centerOffset = CGPointMake(0, -15);
        
         view.canShowCallout = NO;
        
        return view;
    
    }
    
     
    
}



/**
 *  添加遮盖返回遮盖样式
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    
    MAPolylineRenderer *render  =[[MAPolylineRenderer alloc]initWithOverlay:overlay];
    
    render.lineWidth  = 5;
    
//  render.strokeColor = [UIColor blueColor];
    return render;
}

#pragma mark ------- dealloc

- (void)dealloc
{

    NSLog(@"当前页面已经销毁------------------------------999");

}


@end
