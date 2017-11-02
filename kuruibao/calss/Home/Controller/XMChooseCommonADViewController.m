//
//  XMChooseCommonADViewController.m
//  kuruibao
//
//  Created by x on 16/11/25.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:在地图上显示搜索结果，设置默认地址
 
 **********************************************************/
#import "XMChooseCommonADViewController.h"
#import "XMMapUserCommonAddressModel.h"

#define kCommonAddressDidChangeNotification @"kCommonAddressDidChangeNotification"
#define bottomViewHeight 150

@interface XMChooseCommonADViewController ()<MAMapViewDelegate>
{
    MAMapView *_mapView;

    UILabel *_messageLabel;
    
    id<MAAnnotation> _selectedAnnotation;
    
    
}

@end

@implementation XMChooseCommonADViewController


#pragma mark -------------- life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
}


- (void)setupInit
{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, mainSize.height - bottomViewHeight)];
    
    _mapView.showsCompass = NO;
    
    _mapView.showsScale = NO;
    
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    UILabel *showLabel = [UILabel new];
    
    showLabel.numberOfLines = 0;
    
    showLabel.font = [UIFont systemFontOfSize:15];
    
    showLabel.textColor = XMGrayColor;
    
    showLabel.backgroundColor = [UIColor whiteColor];
    
    showLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:showLabel];
    
    _messageLabel = showLabel;
    
    [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view);
        
        make.right.equalTo(self.view);
        
        make.top.equalTo(_mapView.mas_bottom);
        
        make.height.equalTo(bottomViewHeight/2);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    UIButton *determineBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    NSString *btnTitle = self.index ? @"设置为默认地址二": @"设置为默认地址一";
    
    [determineBtn setTitle:btnTitle forState:UIControlStateNormal];
    
    [determineBtn addTarget:self action:@selector(determineBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:determineBtn];
    
    [determineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(_mapView);
        
        make.right.equalTo(_mapView);
        
        make.top.equalTo(showLabel.mas_bottom);
        
        make.height.equalTo(bottomViewHeight/2);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!<确认按钮
    
    //!< back button
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"Map_searchBack"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 10);
    
    [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_mapView);
        
        make.width.equalTo(46);
        
        make.height.equalTo(40);
        
        make.bottom.equalTo(_mapView.mas_top).offset(64);
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    //!< 添加标记
    for (AMapPOI *poi in self.pois)
    {
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc]init];
        
        annotation.title = poi.name;
        
        annotation.subtitle = poi.address;
        
        annotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        
        [_mapView addAnnotation:annotation];
        
    }
    
    [_mapView showAnnotations:_mapView.annotations edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    
    
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //!< 默认选中第一个标记
    [_mapView selectAnnotation:_mapView.annotations[0] animated:YES];
    
}


#pragma mark -------------- 按钮点击事件

//!< 返回上一级界面
- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


//!< 点击确定按钮
- (void)determineBtnDidClick:(UIButton *)sender
{
    
    XMMapUserCommonAddressModel *model = [XMMapUserCommonAddressModel new];
    
    model.name = _selectedAnnotation.title;
    
    model.subTitle = _selectedAnnotation.subtitle;
    
    model.latitude = _selectedAnnotation.coordinate.latitude;
    
    model.longitude = _selectedAnnotation.coordinate.longitude;
    
    if (self.index == 0)
    {
        //!< 左边按钮
        
        [XMMapUserCommonAddressModel saveFirstCommonAddress:model];

        
    }else
    {
        //!< 右边按钮
        [XMMapUserCommonAddressModel saveSecondCommonAddress:model];

    
    }
    
    //!< 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kCommonAddressDidChangeNotification object:nil userInfo:@{@"index":@(self.index),@"name":model.name}];
    

    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}




#pragma mark -------------- MAMapViewDelegate

/*!
 @brief 当选中一个annotation views时，调用此接口
 @param mapView 地图View
 @param views 选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{

     
    _messageLabel.text = [NSString stringWithFormat:@"%@%@",view.annotation.title,view.annotation.subtitle];

     view.image = [UIImage imageNamed:@"annotation_blue"];
    
    _selectedAnnotation = view.annotation;
    
    
}

/*!
 @brief 当取消选中一个annotation views时，调用此接口
 @param mapView 地图View
 @param views 取消选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{

    view.image = [UIImage imageNamed:@"annotation_red"];

}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
      
        static NSString *reuseIdentifier = @"reuseIdentifier";
        
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
     
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
            
 
        }

        annotationView.image = [UIImage imageNamed:@"annotation_red"];
        
        annotationView.centerOffset = CGPointMake(0, -18);
        
        annotationView.canShowCallout = NO;
        
        
        NSUInteger index = [_mapView.annotations indexOfObject:annotation] + 1;

        
        UILabel *label = [annotationView viewWithTag:101];
        
        if (!label)
        {
            UILabel *label = [[UILabel alloc]initWithFrame:annotationView.bounds];
            
            
            label.text = [NSString stringWithFormat:@"%ld",(unsigned long)index];
            
            label.textColor = [UIColor whiteColor];
            
            label.font = [UIFont systemFontOfSize:14];
            
            label.textAlignment = NSTextAlignmentCenter;
            
            label.tag = 101;
            
            [annotationView addSubview:label];
            
            label.transform = CGAffineTransformMakeTranslation(-1, -5);
            
            
        }else
        {
            label.text = [NSString stringWithFormat:@"%ld",(unsigned long)index];

            
        }
        
        
        
    return annotationView;

        }
    
    return nil;
}

@end
