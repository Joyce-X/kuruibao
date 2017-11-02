//
//  XMMainTabBarController.m
//  KuRuiBao
//
//  Created by x on 16/6/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMMainTabBarController.h"
//#import "EMSDK.h"
#import "XMTabBarButton.h"

@interface XMMainTabBarController ()

@property (nonatomic,weak)UIButton* lastBtn;

@property (nonatomic,weak)UIButton* mapItem;//!< 离线地图按钮
@end

@implementation XMMainTabBarController

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    //->>自定义tabbar
    [self setupCustomTabbar];
    
    [self chooseSubViewController];
   
    [self monitorNotification];
    

}


//!< 选择显示的子控制器
- (void)chooseSubViewController
{
    self.selectedIndex = 1;
    
    self.selectedIndex = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.002 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
    
    
    });
    
}

#pragma mark --- 监听查看离线地图的通知

- (void)monitorNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivePreviewOfflineMapRequest:) name:XMPreviewOfflineMapNotification object:nil];
    
    
}

- (void)recivePreviewOfflineMapRequest:(NSNotification *)noti
{
    [self tabBarItemDidClick:_mapItem];
    
    
}

/**
 *  自定义tabbar 布局子控件
 */
- (void)setupCustomTabbar
{
    UIView *tabbar = [[UIView alloc]initWithFrame:self.tabBar.bounds];
    
    tabbar.backgroundColor = XMColor(43, 42, 48);
    
    [self.tabBar addSubview:tabbar];

    //-----------------------------seperate line---------------------------------------//
    CGFloat btnWidth = mainSize.width/4;
 
    //->>添加按钮
    
    //->>体检
    XMTabBarButton *checkBtn = [[XMTabBarButton alloc]init];
    
    [checkBtn setImage:[UIImage imageNamed:@"Tabbar_check"] forState:UIControlStateNormal];
    
    [checkBtn setImage:[UIImage imageNamed:@"Tabbar_check_selected"] forState:UIControlStateSelected];
 
    checkBtn.tag = 0;
    
    [checkBtn addTarget:self action:@selector(tabBarItemDidClick:) forControlEvents:UIControlEventTouchDown];
   
    float offset1 = (btnWidth-24)/2;
    
    checkBtn.imageEdgeInsets = UIEdgeInsetsMake(5, offset1, 5, offset1);
    
    
    
    [tabbar addSubview:checkBtn];
    
    self.lastBtn = checkBtn;
    
    self.lastBtn.selected = YES;
    
    self.selectedIndex = 0;
    
    [checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
       
        make.left.equalTo(tabbar);
        
        make.top.equalTo(tabbar);
        
        make.bottom.equalTo(tabbar);
        
        make.width.equalTo(mainSize.width / 4);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //->>地图
    XMTabBarButton *mapBtn = [[XMTabBarButton alloc]init];
    
    [mapBtn setImage:[UIImage imageNamed:@"Tabbar_map"] forState:UIControlStateNormal];
    
    [mapBtn setImage:[UIImage imageNamed:@"Tabbar_map_selected"] forState:UIControlStateSelected];
    
     mapBtn.tag = 1;
    
    [mapBtn addTarget:self action:@selector(tabBarItemDidClick:) forControlEvents:UIControlEventTouchDown];
    
    [tabbar addSubview:mapBtn];
    
    self.mapItem = mapBtn;
    
    float offset2 = (btnWidth-22.5)/2;
    
    mapBtn.imageEdgeInsets = UIEdgeInsetsMake(4, offset2, 4, offset2);
    
    
    [mapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        make.left.equalTo(checkBtn.mas_right);
        
        make.top.equalTo(tabbar) ;
        
        make.bottom.equalTo(tabbar);
        
        make.width.equalTo(mainSize.width / 4);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //->>轨迹
    XMTabBarButton *routeBtn = [[XMTabBarButton alloc]init];
    
    
    
    [routeBtn setImage:[UIImage imageNamed:@"Tabbar_track"] forState:UIControlStateNormal];
    
    [routeBtn setImage:[UIImage imageNamed:@"Tabbar_track_selected"] forState:UIControlStateSelected];
 
    routeBtn.tag = 2;
    
     [routeBtn addTarget:self action:@selector(tabBarItemDidClick:) forControlEvents:UIControlEventTouchDown];
   
    [tabbar addSubview:routeBtn];
    
    float offset3 = (btnWidth-23.5)/2;
    
    routeBtn.imageEdgeInsets = UIEdgeInsetsMake(4, offset3, 4, offset3);

    
    
    [routeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        make.left.equalTo(mapBtn.mas_right);
        
        make.top.equalTo(tabbar) ;
        
        make.bottom.equalTo(tabbar) ;
        
        make.width.equalTo(mainSize.width / 4);
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //->>记录仪
    XMTabBarButton *recordBtn = [[XMTabBarButton alloc]init];
    
    [recordBtn setImage:[UIImage imageNamed:@"Tabbar_record"] forState:UIControlStateNormal];
    
    [recordBtn setImage:[UIImage imageNamed:@"Tabbar_record_selected"] forState:UIControlStateSelected];
    
    recordBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    recordBtn.tag = 3;
    
     [recordBtn addTarget:self action:@selector(tabBarItemDidClick:) forControlEvents:UIControlEventTouchDown];
    
    float offset4 = (btnWidth-35)/2;
    
    recordBtn.imageEdgeInsets = UIEdgeInsetsMake(4, offset4, 4, offset4);
    

    
    [tabbar addSubview:recordBtn];
    
    [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        make.left.equalTo(routeBtn.mas_right);
        
        make.top.equalTo(tabbar) ;
        
        make.bottom.equalTo(tabbar) ;
        
        make.width.equalTo(mainSize.width / 4);
        
    }];

    
}




/**
 *  监控按钮的点击
 */
- (void)tabBarItemDidClick:(UIButton *)sender
{
  
      if (sender.selected)return; //->>如果是选中状态不执行操作
    
      self.lastBtn.selected = NO;
    
      sender.selected = YES;
    
      self.selectedIndex = sender.tag;
    
      self.lastBtn = sender;
    
}


-(void)dealloc
{

    //!< 移除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (UIStatusBarStyle)preferredStatusBarStyle
{

    return [self.selectedViewController preferredStatusBarStyle];
}


@end
