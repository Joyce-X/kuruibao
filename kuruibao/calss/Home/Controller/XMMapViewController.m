//
//  XMMapViewController.m
//  KuRuiBao
//
//  Created by x on 16/6/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
  location：显示当前位置，
  点击定位按钮： 定位到当前默认车辆位置
  + - ： 可以调整比例尺大小
  路况：显示交通情况
  搜索框：可以搜索目的地，点击某个目的地，返回地图界面开始导航
  结伴按钮：可以邀请好友一同前往目的地
 
 ************************************************************************************************/

#import <AVFoundation/AVFoundation.h>
#import "XMMapViewController.h"
#import <AMapNaviKit/AMapNaviKit.h>

#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>
#import "SpeechSynthesizer.h"
#import "XMSearchBar.h"
#import "XMMapSearchResultViewController.h"
#import "XMMapOperateView.h"
#import "XMMapShowListView.h"
#import "XMCalculateDistanceTool.h"
#import "XMSetCommonAddressViewController.h"
#import "XMMapUserCommonAddressModel.h"
#import "XMMapCustomAnnotationView.h"
#import "XMDefaultCarModel.h"
#import "XMCar.h"
#import "XMMapCarLocationModel.h"
#import "AFNetworking.h"
#import "XMMapCustomAnnotation.h"
#import "XMCommonView.h"
#import "XMUser.h"
#import "XMCar.h"

#import "XMBaiduMapViewController.h"

#define CURRENTCITY @"currentCity"

//!< 常用地址改变的通知
#define kCommonAddressDidChangeNotification @"kCommonAddressDidChangeNotification"

@interface XMMapViewController ()<MAMapViewDelegate,UITextFieldDelegate,AMapSearchDelegate,AMapNaviDriveManagerDelegate,UIAlertViewDelegate,AMapNaviDriveViewDelegate,UITableViewDelegate,UITableViewDataSource,XMMapShowListViewDelegate,XMCommonViewDelegate,AMapNaviDriveViewDelegate>
{
    MAMapView *_mapView; //!< 主地图
    AMapSearchAPI *_search; //-- 主搜索对象
    AMapNaviDriveManager *_manager;//-- 导航管理者
    NSMutableArray *_routeInfoArray; //-- 显示遮盖时用
    MAPointAnnotation *_destinationLocation;  //-- 规划路径显示目的地的大头针
    

}

@property (strong, nonatomic) AMapNaviDriveView *driveView;//!< 导航视图

@property (nonatomic,assign)CGFloat zoomLevel;//!< 记录当前地图的缩放级别

@property (nonatomic,strong)UIButton * btn_reduce;//!< 缩小按钮

@property (nonatomic,strong)UIButton* btn_enlarge;//!< 放大按钮

@property (nonatomic,copy)NSString* currentCity;//!< 用户当前所在城市

@property (copy, nonatomic) NSString *offlineItemName; //!< 查看离线地图数据时候的名称

@property (nonatomic,weak)UIView* topView;//!< 顶部view

@property (nonatomic,weak)UIView* bottomView;//!< 底部view

@property (strong, nonatomic) NSArray *tabDataSource;//!< tab数据源

@property (nonatomic,weak)UITableView* historyTableView;

@property (nonatomic,weak)UIView* backView;//!< view上层的view

@property (nonatomic,weak)UIView* searchView;//!< 地图上的搜索视图

@property (assign, nonatomic) BOOL isConnect;

@property (strong, nonatomic) XMMapOperateView *operateView;//!< 点击搜索之后的操作区域


@property (copy, nonatomic) NSString *searchKeyword;//!< 搜索的关键字

@property (strong, nonatomic) NSArray *annotations;//!< 搜索结果展示大头针

@property (nonatomic,weak)XMMapShowListView* listView;//!< 搜索结果展示列表

@property (nonatomic,weak)XMCommonView* firstCommoView;//!< 左边常用地址视图

@property (nonatomic,weak)XMCommonView* secondCommonView;//!< 右边常用地址视图

@property (strong, nonatomic) XMDefaultCarModel *defaultCar;//!< 用户默认车辆

@property (strong, nonatomic) NSArray *userCarList;//!< 用户车辆列表

@property (strong, nonatomic) id<MAAnnotation> defaultCarAnnotation;//!< 默认车辆对应的标注

@property (strong, nonatomic) XMMapCarLocationModel *defaultCarLocationModel;//!< 默认车辆对应坐标模型

@property (strong, nonatomic) NSMutableArray * userAllCarsAnnotations;//!<用户所有车辆对应的标注

@property (strong, nonatomic) NSMutableArray<XMMapCarLocationModel*> *userAllCarsLocationModels;//!< 用户所有车辆对应的位置模型

@property (strong, nonatomic) AFHTTPSessionManager *session;//!<  request manager


@property (nonatomic,weak)UIButton* isDefaultCar;//!< 是否选中默认车辆

@end


@implementation XMMapViewController


#pragma mark --- life cycle


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {

        //!< 监听用户的默认车辆获取成功或全部车辆获取成功的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carInfodidChanged:) name:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
  
    //-- 初始化高德地图
    [self setupGaoDeMap];
    
    //-- 初始化地图操作按钮
    [self setupOperateMapBtn];
    
    
    //!< 监听通知
    [self monitorNotification];

    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     self.tabBarController.tabBar.hidden = !_topView.hidden;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    

    //!< 不显示默认用户的位置，当选择的是默认车辆的时候就显示默认车辆，如果选择的是全部车辆的话就显示全部车辆

    if(self.isDefaultCar.selected == NO)
    {
        
        //!< 默认车辆存在就显示默认车辆位置，不存在就显示用户当前的位置
        //!< 选中的是默认车辆，定位默认车辆
        if (self.defaultCarAnnotation)
        {
           
            [_mapView removeAnnotations:_mapView.annotations];
            
            [_mapView addAnnotation:_defaultCarAnnotation];
            
            [_mapView showAnnotations:@[_defaultCarAnnotation] edgePadding:UIEdgeInsetsMake(130, 100, 130, 100) animated:YES];
            
            [_mapView setZoomLevel:17 animated:YES];
            
        }else
        {
            
            [_mapView setZoomLevel:17 animated:YES];
            
            [_mapView showAnnotations:@[_mapView.userLocation] animated:YES];
        
        }
        
        
     
    
    }else
    {
        //!< 选中的是定位全部车辆，全部车辆的位置信息存在就显示全部车辆的位置信息，不存在就显示用户的位置信息
        if (self.userAllCarsAnnotations.count > 0)
        {

            
            [_mapView removeAnnotations:_mapView.annotations];//!< 删除除过用户位置的其他标注
            
            //!< 重新添加所有车辆
            [_mapView addAnnotations:self.userAllCarsAnnotations];
            
            
            [_mapView showAnnotations:self.userAllCarsAnnotations edgePadding:UIEdgeInsetsMake(130, 100, 130, 100) animated:YES];
            
        }else
        {
            
            [_mapView showAnnotations:@[_mapView.userLocation] animated:YES];
            
        }

    }
    
    
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



#pragma mark --- initGaoDeMap


- (void)setupGaoDeMap
{
    //!< 初始化searchKit
    _search = [[AMapSearchAPI alloc]init];;
    _search.delegate = self;
    
    //!< 初始化导航管理者
    _manager = [[AMapNaviDriveManager alloc]init];
    _manager.delegate  = self;
    [_manager setDetectedMode:AMapNaviDetectedModeNone];

    //-- 初始化地图遮盖数组
    _routeInfoArray = [NSMutableArray array];
    
    //-- 创建地图并添加到view上
    
    UIView *backView = [[UIView alloc]initWithFrame:self.view.bounds];
    
    [self.view addSubview:backView];
    
    self.backView = backView;
    
    _mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
   
    [_backView addSubview:_mapView];
    
    _mapView.delegate = self;
    
    
    
    //-- 保证应用在后台可提供持续定位能力 不会被挂起
//    _mapView.pausesLocationUpdatesAutomatically = NO;
//    _mapView.allowsBackgroundLocationUpdates = YES;
    
    //-- 记录地图的缩放级别
    self.zoomLevel = _mapView.zoomLevel;
    
    _mapView.showsUserLocation = YES;
    
    _mapView.showsCompass = NO;
    
    self.isConnect = YES;
}



 
//!< 初始化地图上的操作按钮
- (void)setupOperateMapBtn
{
    
    //-- 设置搜索框
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(10, 19, mainSize.width - 20, 45)];
    
    searchView.backgroundColor = [UIColor clearColor];
    
    searchView.hidden = YES;
    
    //!< 在tap手势的响应方法中跳转动画，显示底部栏和顶部栏
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchBarDidClick:)];
    
    [searchView addGestureRecognizer:tap];
    
    [_backView addSubview:searchView];
    
    self.searchView = searchView;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 背景图
    
    UIImageView *backIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"map_search_background" ]];
    
    backIV.frame = searchView.bounds;
    
    [searchView addSubview:backIV];
    
    

    //-----------------------------seperate line---------------------------------------//
    
    //!< 放大镜
    UIImageView *enlargeGlass = [[UIImageView alloc]initWithFrame:CGRectMake(10, 13, 18, 18)];
    
    enlargeGlass.image = [UIImage imageNamed:@"Search"];
    
    [searchView addSubview:enlargeGlass];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 提示信息
    UILabel *placeHolder = [UILabel new];
    
    placeHolder.text = @"搜索";
    
    placeHolder.font = [UIFont systemFontOfSize:15];
    
    placeHolder.textColor = XMGrayColor;
    
    [searchView addSubview:placeHolder];
    
    [placeHolder mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(searchView);
        
        make.bottom.equalTo(searchView);
        
        make.right.equalTo(searchView);
        
        make.left.equalTo(enlargeGlass.mas_right).offset(7);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    
    
    //-- 设置路况按钮
    UIButton *btn_traffic = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn_traffic setBackgroundImage:[UIImage imageNamed:@"map_roadStateOff"] forState:UIControlStateNormal];
    
    [btn_traffic setBackgroundImage:[UIImage imageNamed:@"map_roadStateOn"] forState:UIControlStateSelected];
    
     [btn_traffic addTarget:self action:@selector(btn_trafficDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_backView addSubview:btn_traffic];
    
    [btn_traffic mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(36, 36));
        
        make.right.equalTo(searchView);//
        
        make.top.equalTo(searchView.mas_bottom).offset(18);
        
    }];
 
    UIButton *isDefaultCar = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [isDefaultCar setImage:[UIImage imageNamed:@"map_locationCurrentCar"] forState:UIControlStateNormal];
    
    [isDefaultCar setImage:[UIImage imageNamed:@"map_locationAllCar"] forState:UIControlStateSelected];
    
    [isDefaultCar addTarget:self action:@selector(selectCarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    isDefaultCar.selected = NO;
    
    [self.view addSubview:isDefaultCar];
    
    self.isDefaultCar = isDefaultCar;
    
    [isDefaultCar mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(btn_traffic.mas_bottom).offset(20);
        
        make.right.equalTo(btn_traffic);
        
        make.size.equalTo(btn_traffic);
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    
    //-- 设置定位按钮
    UIButton *btn_location = [UIButton buttonWithType:UIButtonTypeCustom];
    
     [btn_location addTarget:self action:@selector(btn_locationDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn_location setBackgroundImage:[UIImage imageNamed:@"map_location"] forState:UIControlStateNormal];
    
    [btn_location setBackgroundImage:[UIImage imageNamed:@"map_location"] forState:UIControlStateHighlighted];
    
    
    
    [_backView addSubview:btn_location];
    
    [btn_location mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_mapView).offset(10);
        
        make.bottom.equalTo(_mapView).offset(-49 -11);
        
        make.size.equalTo(CGSizeMake(37, 37));
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //-- 设置显示车辆位置按钮
    UIButton *btn_showCar = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn_showCar setBackgroundImage:[UIImage imageNamed:@"map_locationDefaultCar"] forState:UIControlStateNormal];
//    map_locationAllCar
    [btn_showCar setBackgroundImage:[UIImage imageNamed:@"map_locationDefaultCar"] forState:UIControlStateSelected];
    
    [btn_showCar addTarget:self action:@selector(btn_showCarDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_backView addSubview:btn_showCar];
    
    [btn_showCar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(37, 37));
        
        make.left.equalTo(btn_location);//
        
        make.bottom.equalTo(btn_location.mas_top).offset(-11);//
    }];


    //-----------------------------seperate line---------------------------------------//
    
    //-- 设置比例尺
    _mapView.showsScale = YES;
    
    CGFloat scaleX = 10 + 37 + 6;
    
    CGFloat scaleY = mainSize.height - 49 - 18 - _mapView.scaleSize.height;
    
    _mapView.scaleOrigin = CGPointMake(scaleX, scaleY);
 
    
    //-----------------------------seperate line---------------------------------------//
    
     //-- 设置缩小按钮  reduce
    UIButton *btn_reduce = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn_reduce setBackgroundImage:[UIImage imageNamed:@"map_reduce_normal"] forState:UIControlStateNormal];
    
    [btn_reduce setBackgroundImage:[UIImage imageNamed:@"map_reduce_Highlighted"] forState:UIControlStateHighlighted];
    
    
    [btn_reduce addTarget:self action:@selector(btn_reduceDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_backView addSubview:btn_reduce];
    
    [btn_reduce mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(36, 42));
        
        make.bottom.equalTo(_mapView).offset(-49 - 17);
        
        make.right.equalTo(_mapView).offset(-9);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    
    //-- 设置放大按钮  reduce
    UIButton *btn_enlarge = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn_enlarge setBackgroundImage:[UIImage imageNamed:@"map_enlarge_normal"] forState:UIControlStateNormal];
    
    [btn_enlarge setBackgroundImage:[UIImage imageNamed:@"map_enlarge_Highlighted"] forState:UIControlStateHighlighted];
    
     [btn_enlarge addTarget:self action:@selector(btn_enlargeDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_backView addSubview:btn_enlarge];
    
    [btn_enlarge mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(36, 42));
        
        make.bottom.equalTo(btn_reduce.mas_top).offset(4);
        
        make.right.equalTo(_mapView).offset(-9);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    [self createSearchPage];//!< 创建搜索界面
    
    
}

- (void)createSearchPage
{
    //!< 顶部导航部分
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 64)];
    
    topView.backgroundColor = XMWhiteColor;
    
    [self.view addSubview:topView];
    
    self.topView = topView;
    
    topView.hidden = YES;
    
    //!< 返回按钮
    
    //!< back button
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"Map_searchBack"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 10);
    
    [topView addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(topView);
        
        make.width.equalTo(46);
        
        make.height.equalTo(40);
        
        make.bottom.equalTo(topView).offset(-6);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< search Bar
    XMSearchBar *searchBar = [XMSearchBar searchBar];
    
    searchBar.placeholder = @"搜索地点";
    
    searchBar.tag = 404;
    
    searchBar.delegate = self;
    
    searchBar.returnKeyType = UIReturnKeySearch;
    
     [topView addSubview:searchBar];
    
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(backBtn);
        
        make.left.equalTo(backBtn.mas_right);
        
        make.right.equalTo(topView).offset(-10);
        
        make.height.equalTo(35);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [searchBtn setBackgroundColor:XMBlueColor];
    
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    searchBtn.tag = 405;
    
    searchBtn.layer.cornerRadius = 5;
    
    
    [searchBtn addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchDown];
    
    searchBtn.hidden = YES;
    
    [_topView addSubview:searchBtn];
    
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(searchBar);
        
        make.left.equalTo(topView.mas_right);
        
        make.size.equalTo(CGSizeMake(50, 30));
        
    }];

    topView.transform = CGAffineTransformMakeTranslation(0, -64);
    
    topView.hidden = YES;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 底部历史部分
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, mainSize.width, mainSize.height - 64)];
    
    bottomView.backgroundColor = XMWhiteColor;
    
    [self.view addSubview:bottomView];
    
    self.bottomView = bottomView;
 
    //-----------------------------seperate line---------------------------------------//
    
    //!< 两个常用地址
    
     //!< 常用地址模型
     XMMapUserCommonAddressModel *firstModel = [XMMapUserCommonAddressModel firstCommonAddress];
    
    XMMapUserCommonAddressModel *secondModel = [XMMapUserCommonAddressModel secondCommonAddress];
    
    XMCommonView *firstView = [XMCommonView new];
    
    firstView.backgroundColor = XMBlueColor;
    
    firstView.tag = 0;
    
    firstView.image = [UIImage imageNamed:@"map_commonAddress_home"];
    
    firstView.address = firstModel ? firstModel.name : @"常用地址1";
    
    firstView.delegate = self;
    
    [bottomView addSubview:firstView];
    
    _firstCommoView = firstView;
    
     [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(bottomView);
        
        make.top.equalTo(bottomView);
        
        make.width.equalTo(mainSize.width * 0.5);
        
        make.height.equalTo(70);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    XMCommonView *secondView = [XMCommonView new];
    
    secondView.backgroundColor = XMGreenColor;
    
    secondView.tag = 1;
    
    secondView.image = [UIImage imageNamed:@"map_commonAddress_work"];
    
    secondView.address = secondModel ? secondModel.name : @"常用地址2";
    
    secondView.delegate = self;
    
    [bottomView addSubview:secondView];
    
    _secondCommonView = secondView;
    
    [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(firstView.mas_right);
        
        make.top.equalTo(bottomView);
        
        make.width.equalTo(mainSize.width * 0.5);
        
        make.height.equalTo(70);
        
    }];
    
    
    
    //-----------------------------seperate line---------------------------------------//
    
    UITableView *tableView = [UITableView new];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
//    tableView.sectionFooterHeight = 33;
    
    [bottomView addSubview:tableView];
    
    self.historyTableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(bottomView);
        
        make.right.equalTo(bottomView);
        
        make.bottom.equalTo(bottomView);
        
        make.top.equalTo(firstView.mas_bottom);
        
    }];
    
    UIButton *clearHistoryRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [clearHistoryRecordBtn setTitleColor:XMGrayColor forState:UIControlStateNormal];
    
    clearHistoryRecordBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    clearHistoryRecordBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [clearHistoryRecordBtn setTitle:@"清除历史记录" forState:UIControlStateNormal];
    
    [clearHistoryRecordBtn addTarget:self action:@selector(clearHistoryRecordBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    clearHistoryRecordBtn.frame = CGRectMake(0, 0, 0, 33);
    
    tableView.tableFooterView = clearHistoryRecordBtn;
    
    bottomView.transform = CGAffineTransformMakeTranslation(0, mainSize.width - 64);
    
    bottomView.hidden = YES;
    



}


//!< 添加监听
- (void)monitorNotification
{
    
    //!< 监听用户点击查看离线地图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePreviewOfflineMapRequest:) name:XMPreviewOfflineMapNotification object:nil];
    
    //!< 监听textFiled文字长度改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    //!< 监听网络变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStateDidChanged:) name:XMNetWorkDidChangedNotification object:nil];
    
    //!< 监听用户设置常用地址
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commonAddressDidChange:) name:kCommonAddressDidChangeNotification object:nil];
    
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;

}


#pragma mark --- lazy

- (NSArray *)tabDataSource
{
    //!< 从本地数据读取
    if (!_tabDataSource)
    {
        _tabDataSource = [NSArray arrayWithContentsOfFile:XMSearchHistoryPath];
    }

    return _tabDataSource;
}

-(NSMutableArray<XMMapCarLocationModel *> *)userAllCarsLocationModels
{
    if (!_userAllCarsLocationModels)
    {
        _userAllCarsLocationModels = [NSMutableArray array];
    }
    
    return _userAllCarsLocationModels;

}

- (NSMutableArray *)userAllCarsAnnotations
{
    if (!_userAllCarsAnnotations)
    {
        _userAllCarsAnnotations = [NSMutableArray array];
        
    }
    
    return _userAllCarsAnnotations;



}

- (XMMapOperateView *)operateView
{

    if (!_operateView)
    {
        _operateView = [[XMMapOperateView alloc]initWithTarget:self];
        
        _operateView.frame = CGRectMake(10, 30, mainSize.width -20, 50);
        
        _operateView.hidden = YES;
        
        [_backView addSubview:_operateView];
    }

    return _operateView;

}


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

- (AMapNaviDriveView *)driveView
{
    if (_driveView == nil)
    {
        _driveView = [[AMapNaviDriveView alloc] initWithFrame:self.view.bounds];
        _driveView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_driveView setDelegate:self];
       
    }
    return _driveView;
}

#pragma mark --- 响应通知的方法

/**
 *  响应预览离线地图的通知
 */
- (void)receivePreviewOfflineMapRequest:(NSNotification *)noti
{
    
    //!< 有网络就找，没有网络就不执行操作
    
    [_mapView removeAnnotations:_mapView.annotations];//!< 删除所有标注
    
    self.offlineItemName = noti.userInfo[@"info"];
    
    AMapGeocodeSearchRequest *request = [[AMapGeocodeSearchRequest alloc]init];
    
    request.address = _offlineItemName;
    
    //!< 地理编码查找地址坐标，地图显示对应坐标位置
    [_search AMapGeocodeSearch:request];
    
 }

//!< textfield长度改变
- (void)searchBarTextDidChanged:(NSNotification *)noti
{
     
    
    //!< 从没有值变为有值 缩小宽度，创建按钮平移近来，没有值就移除按钮，加宽输入框
    UITextField *textField = (UITextField *)noti.object;
    
    if (textField.tag != 404) return;
    
    static BOOL shouldReduce = YES;
    
    if (shouldReduce)
    {
        CGRect frame = textField.frame;
        
        frame.size.width -= 50;
        
        shouldReduce = NO;
        
        UIButton *searchBtn = [_topView viewWithTag:405];
        
        searchBtn.hidden = NO;
        
        [UIView animateWithDuration:0.1 animations:^{
            
            textField.frame = frame;
            
            searchBtn.transform = CGAffineTransformMakeTranslation(-55, 0);
            
        }];
      }
    
    if (textField.text.length == 0)
    {
        CGRect frame = textField.frame;
        
        frame.size.width += 50;
        
        UIButton *searchBtn = [_topView viewWithTag:405];
        
        
        
        [UIView animateWithDuration:0.2 animations:^{
            
            textField.frame = frame;
            
            searchBtn.transform = CGAffineTransformMakeTranslation(55, 0);
            
        }];
        
        shouldReduce = YES;
        
        searchBtn.hidden = YES;
        
        
    }
    
    
    
     
    
    
    
}

//!< 网络发生变化
- (void)netStateDidChanged:(NSNotification *)noti
{
    int stateCode = [noti.userInfo[@"info"] intValue];
    
    if (stateCode > 0)
    {
        self.isConnect = YES;
    }else
    {
        self.isConnect = NO;
    }
    
    
}

//!< 默认地址发生变化
- (void)commonAddressDidChange:(NSNotification *)noti
{
    NSDictionary *dic = noti.userInfo;
    
    int index = [dic[@"index"] intValue];//!< 发生变化的位置
    
    NSString *name = dic[@"name"];//!< 变化后的名称信息
    
    if (index == 0)
    {
        //!< 左边地址发生变化
        _firstCommoView.address = name;
        
        
    }else
    {
        //!< 右边地址发生变化
        _secondCommonView.address = name;
    }
    
    
}

/*!
 @brief 监听用户更换默认车辆 || 获取全部车辆信息成功的通知
 */
- (void)carInfodidChanged:(NSNotification *)noti
{

    NSString *changMode = noti.userInfo[@"mode"];//!< 默认车辆发生变化还是全部车辆
    
    id object = noti.userInfo[@"result"];//!< 改变的结果
    
    if([changMode isEqualToString:@"car"])
    {
        XMDefaultCarModel *model = (XMDefaultCarModel *)object;
        
        //!< 默认车辆变化
        self.defaultCar = object;
        
        if (model.tboxid.intValue == 0)
        {
            return;
            
        }
        
        
        //!< 默认车辆更改后，获取默认车辆位置
        [self getUserDefaultCarLocation];
        
     
        
    }else
    {
        //!< 全部车辆获取成功
        XMLOG(@"全部车辆获取成功");
        
        NSMutableArray *arrM = [NSMutableArray array];
        
        for (XMCar *temCar in object)
        {
            if (temCar.tboxid > 0)
            {
                [arrM addObject:temCar];
            }
        }
        
        
        self.userCarList = [arrM copy];
        
        if(self.userCarList.count < 1)return;//!< 用户没有车辆
        
//        [self.userAllCarsLocationModels removeAllObjects];
        
        [self.userAllCarsAnnotations removeAllObjects];
        
        for (XMCar *car in self.userCarList)
        {
            if (car.tboxid == 0)//!< 如果有没有激活过的车就跳过
            {
                continue;
            }
            
            XMMapCarLocationModel *model = [XMMapCarLocationModel new];
            
            model.carbrandid = [NSString stringWithFormat:@"%ld",(long)car.carbrandid];//!< 品牌编号
            
            model.qicheno = car.chepaino;
            
            model.qicheid = [NSString stringWithFormat:@"%ld",(long)car.qicheid];
            
            model.tboxid = [NSString stringWithFormat:@"%ld",(long)car.tboxid];
            
            model.currentstatus = car.currentstatus;
            
            [self.userAllCarsLocationModels addObject:model];
        }
        
        
        if (isCompany)
        {
            
            [self getUserAllCarsLocation_company];
            
            
        }else
        {
        
            [self getUserAllCarsLocation];
        
        }
        
        
        
        
        
        
//        [self btn_locationDidClick:nil];
    
    }
    
}

#pragma mark -------------- 获取车辆位置信息

//!< 获取用户默认车辆的位置
- (void)getUserDefaultCarLocation
{
    //!< 获取默认车辆成功执行的操作
    /**
        1 如果车牌长度大于0 且 tboxid 长度大于0,有默认车辆
     */
    
    if(self.defaultCar.qicheid.length > 0 && self.defaultCar.tboxid.length > 0)
    {
        //!< 用户有默认车辆，获取当前位置信息
        NSString *urlStr = [mainAddress stringByAppendingFormat:@"q_run_gpsinfo&Qicheid=%@&Tboxid=%@",_defaultCar.qicheid,_defaultCar.tboxid];
        
        [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if ([result isEqualToString:@"0"])
            {
                XMLOG(@"没有获取到位置信息");
            }else if([result isEqualToString:@"-1"])
            {
                XMLOG(@"参数类型或者网络错误");
            
            }else
            {
                 //!< 获取最近10条位置信息成功，只取出第一条来显示位置信息
                
                NSArray *locationArr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                
                NSDictionary *locationDic = [locationArr firstObject];
                
                //!< 获取位置信息成功，设置默认车辆的位置模型
                self.defaultCarLocationModel = [[XMMapCarLocationModel alloc]initWithDictionary:locationDic];
                
                //!< 判断车辆是否在线
                
                [self sendCheckCommand];
                
                
                
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           
            XMLOG(@"网络连接失败");
            
        }];
        
    
    }else
    {
        XMLOG(@"用户没有默认车辆");
    
    }

}


- (void)getUserAllCarsLocation_company
{
    [self.userAllCarsAnnotations removeAllObjects];
     //!< 向全局并行队列添加异步任务
    
    for(int i = 0;i < self.userAllCarsLocationModels.count;i++)
    {
        //!< 添加异步任务
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
             
            XMMapCarLocationModel *model = [self.userAllCarsLocationModels objectAtIndex:i];
            
            //!< 获取位置数据
            NSString *urlStr = [mainAddress stringByAppendingFormat:@"q_run_gpsinfo&Qicheid=%@&Tboxid=%@",model.qicheid,model.tboxid];
            
            [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                
                if ([result isEqualToString:@"0"])
                {
                    XMLOG(@"没有获取到位置信息");
                    
                }else if([result isEqualToString:@"-1"])
                {
                    XMLOG(@"参数类型或者网络错误");
                    
                }else
                {
                    
                    //!< 获取最近10条位置信息成功，只取出第一条来显示位置信息
                    
                    NSArray *locationArr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                    
                    NSDictionary *locationDic = [locationArr firstObject];
                    
                    //!< 获取位置信息成功，设置默认车辆的位置模型
                    
                    XMMapCarLocationModel *newModel =  [[XMMapCarLocationModel alloc]initWithDictionary:locationDic];
                    
                    model.locationx = newModel.locationx;
                    
                    model.locationy = newModel.locationy;
                    
                    model.time = newModel.time;
                    
                    if(model.locationx == 0 || model.locationy == 0)return ;//!< 没有位置信息就忽略
                    
                    XMLOG(@"-------%d-----------------location:%f ,%f,%@",i,model.locationx,model.locationy,model.time);
                    
                    //-----------------------------seperate line---------------------------------------//
                    //!< 判断状态
                    
                    XMMapCustomAnnotation *anno = [[XMMapCustomAnnotation alloc]init];
                    
                    //            anno.subtitle = subtitle;
                    
                    anno.title = model.qicheno;
                    
                    anno.coordinate = CLLocationCoordinate2DMake(model.locationy, model.locationx);
                    
                    anno.carBrandId = model.carbrandid;
                    
                    anno.time = model.time;
                    
                    switch (model.currentstatus)
                    {
                        case 0:
                            
                            anno.subtitle = @"停驶";
                            
                            break;
                            
                        case 1:
                            
                            anno.subtitle = @"行驶中";
                            break;
                            
                        case 2:
                            
                            anno.subtitle = @"失联";
                            
                            break;
                            
                        default:
                            break;
                    }
                    
                    
                    [self.userAllCarsAnnotations addObject:anno];
                    

                    
                    
                }
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                XMLOG(@"获取位置信息失败，网络原因");
                
            }];
            
            
            
            
            
            
            
//        });
        
        
            
        
        
        
    }

    
}

//!< 获取用户所有车辆的位置
- (void)getUserAllCarsLocation
{
    
    XMUser *user = [XMUser user];
    
    for(int i = 0;i < self.userAllCarsLocationModels.count;i++)
    {
        XMMapCarLocationModel *model = [self.userAllCarsLocationModels objectAtIndex:i];
        
        //!< 获取位置数据
        NSString *urlStr = [mainAddress stringByAppendingFormat:@"q_run_gpsinfo&Qicheid=%@&Tboxid=%@",model.qicheid,model.tboxid];
    
         [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
             NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if ([result isEqualToString:@"0"])
            {
                XMLOG(@"没有获取到位置信息");
                
            }else if([result isEqualToString:@"-1"])
            {
                XMLOG(@"参数类型或者网络错误");
                
            }else
            {
                
                //!< 获取最近10条位置信息成功，只取出第一条来显示位置信息
                
                NSArray *locationArr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                
                NSDictionary *locationDic = [locationArr firstObject];
                
                //!< 获取位置信息成功，设置默认车辆的位置模型
                
                XMMapCarLocationModel *newModel =  [[XMMapCarLocationModel alloc]initWithDictionary:locationDic];
                
                model.locationx = newModel.locationx;
                
                model.locationy = newModel.locationy;
                
                 model.time = newModel.time;
                
                XMLOG(@"-------%d-----------------location:%f ,%f,%@",i,model.locationx,model.locationy,model.time);
                
                //!< 判断状态
                
                NSString *urlStr_active = [mainAddress stringByAppendingFormat:@"sendcommand&userid=%lu&qicheid=%@&tboxid=%@&commandtype=50&subtype=0",(long)user.userid,model.qicheid,model.tboxid];
                
                [self.session GET:urlStr_active parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    int result = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
                    
                    NSString *subtitle;
                    
                    if (result == 0 || result == -1)
                    {
                        XMLOG(@"发送检测指令时，终端不在线");
                        
                        subtitle = @"停驶";
                        
                        
                    }else
                    {
                        XMLOG(@"发送检测指令时，终端在线" );
                        subtitle = @"在线";
                        
                    }
                    
                    XMMapCustomAnnotation *anno = [[XMMapCustomAnnotation alloc]init];
                    
                    anno.subtitle = subtitle;
                    
                    anno.title = model.qicheno;
                    
                    anno.coordinate = CLLocationCoordinate2DMake(model.locationy, model.locationx);
                    
                    XMLOG(@"Joyce---------%f %f---------",anno.coordinate.latitude,anno.coordinate.longitude);
                    
                    anno.carBrandId = model.carbrandid;
                    
                    anno.time = model.time;
                    
                    
                    
                    [self.userAllCarsAnnotations addObject:anno];
                    
                    
                    
                    
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    XMLOG(@"网络错误");
                    
                    
                }];
                
               
  
             }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            XMLOG(@"网络连接失败");
            
        }];
        
        
        //-----------------------------seperate line---------------------------------------//
        
       
    
    }
    
  
}



//!< 发送检测指令，判断终端是否在线
- (void)sendCheckCommand
{
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"sendcommand&userid=%@&qicheid=%@&tboxid=%@&commandtype=50&subtype=0",_defaultCar.userid,_defaultCar.qicheid,_defaultCar.tboxid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        int result = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
        
        NSString *subtitle;
        
        if (result == 0 || result == -1)
        {
            XMLOG(@"发送检测指令时，终端不在线");
            
            subtitle = @"停驶";
            
            
        }else
        {
             XMLOG(@"发送检测指令时，终端在线" );
            subtitle = @"在线";
            
         }
        
        XMMapCustomAnnotation *anno = [[XMMapCustomAnnotation alloc]init];
        
        anno.subtitle = subtitle;
        
        anno.title = _defaultCar.chepaino;
        
        anno.coordinate = CLLocationCoordinate2DMake(self.defaultCarLocationModel.locationy, self.defaultCarLocationModel.locationx);
        
        anno.carBrandId = _defaultCar.carbrandid;
        
        anno.time = self.defaultCarLocationModel.time;
        
        self.defaultCarAnnotation = anno;
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"网络错误");
        
        
    }];
    
    
}

 

#pragma mark -- mapViewDelegate  --- 地图代理方法

/**
 *  更新到用户位置时调用
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{

    
    [[NSUserDefaults standardUserDefaults] setFloat:userLocation.location.coordinate.latitude forKey:@"TRACK_LATITUDE"];
    [[NSUserDefaults standardUserDefaults] setFloat:userLocation.location.coordinate.longitude forKey:@"TRACK_LONGITUDE"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        
        _mapView.zoomLevel = 17;
        
        [_mapView showAnnotations:@[_mapView.userLocation] animated:YES];
            //-- 反地理编码来获取用户当前城市
            AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc]init];
        
            request.location = [AMapGeoPoint locationWithLatitude:mapView.userLocation.location.coordinate.latitude longitude:mapView.userLocation.location.coordinate.longitude];
            [_search AMapReGoecodeSearch:request];
        
        
    });

}



/**
 *  添加大头针返回大头针样式回调
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
      if ([annotation isMemberOfClass:[MAPointAnnotation class]])
    {
        
        static NSString * poiIdentifier = @"carIdentifier";
        
        MAAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:poiIdentifier];
        
        if (view == nil)
        {
            view = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:poiIdentifier];
        }
        
        view.image = [UIImage imageNamed:@"annotation_red"];
        
        view.canShowCallout = NO;
        
        view.centerOffset = CGPointMake(0, -18);
        
        UILabel *label = [view viewWithTag:130];
        
        
        NSUInteger index = [self.annotations indexOfObject:annotation] + 1 ;
        
        if (!label)
        {
            UILabel *label = [[UILabel alloc]initWithFrame:view.bounds];
            
            label.text = [NSString stringWithFormat:@"%lu",(unsigned long)index];
            
            label.textColor = [UIColor whiteColor];
            
            label.font = [UIFont systemFontOfSize:14];
            
            label.textAlignment = NSTextAlignmentCenter;
            
            label.tag = 130;
            
            [view addSubview:label];
            
            label.transform = CGAffineTransformMakeTranslation(-1, -5);
            
        }else
        {
            
            label.text = [NSString stringWithFormat:@"%lu",(unsigned long)index];
            
            
        }
        
        return view;
        
    }else if([annotation isMemberOfClass:[XMMapCustomAnnotation class]])
    {
              
     static NSString *identifier = @"annotationView";
    
    XMMapCustomAnnotationView *annotationView = (XMMapCustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (annotationView == nil)
    {
        annotationView = [[XMMapCustomAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        
    }
    
        if ([annotation.subtitle isEqualToString:@"停驶"] || [annotation.subtitle isEqualToString:@"失联"])
        {
            annotationView.image = [UIImage imageNamed:@"map_annotation_offline"];
            
        }else
        {
            annotationView.image = [UIImage imageNamed:@"map_annotation_online"];
        
        }
        
    
    
    annotationView.canShowCallout = NO;
    
    annotationView.centerOffset = CGPointMake(0, -18);
        
    return annotationView;
        
    }else
    {
        return nil;
            
     }
   
}



/**
 *  -- 地图缩放完成--
 */
-(void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction
{
    //-- 同步当前缩放级别
    _zoomLevel = mapView.zoomLevel;
    
 
}

-(void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views.firstObject;
    
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        view.canShowCallout = NO;
    }


}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    
    if ([view.annotation isKindOfClass:[MAUserLocation class]] || [view.annotation isMemberOfClass:[XMMapCustomAnnotation class]])
    {
        return;
    }
    
    view.image = [UIImage imageNamed:@"annotation_blue"];
    
    //!< 获取下标，选中tableView
    NSUInteger index = [self.annotations indexOfObject:view.annotation];
    
    
    [_listView.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];

}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MAUserLocation class]]|| [view.annotation isMemberOfClass:[XMMapCustomAnnotation class]])
    {
        return;
    }

    view.image = [UIImage imageNamed:@"annotation_red"];
}


/**
 *  添加遮盖返回遮盖样式
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    //    if ([overlay isKindOfClass:[SelectableOverlay class]])
    //    {
    //        SelectableOverlay * selectableOverlay = (SelectableOverlay *)overlay;
    //        id<MAOverlay> actualOverlay = selectableOverlay.overlay;
    //
    //        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:actualOverlay];
    //
    //        polylineRenderer.lineWidth = 3.f;
    //        //        polylineRenderer.strokeColor = selectableOverlay.isSelected ? selectableOverlay.selectedColor : selectableOverlay.regularColor;
    //        polylineRenderer.strokeColor = [UIColor redColor];
    //        return polylineRenderer;
    //    }
    //
    //    return nil;
    MAPolylineRenderer *render  =[[MAPolylineRenderer alloc]initWithOverlay:overlay];
    render.lineWidth  = 5;
    render.fillColor = XMBlueColor;
//    render.strokeColor = [UIColor blackColor];
    return render;
    
}


#pragma mark -- AMapSearchDelegate --- 搜索代理方法


/**
 *  搜索失败回调函数
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    
    if ( [request isKindOfClass:[AMapReGeocodeSearchRequest class]])
    {
        //-- 检索当前城市失败，就不设置搜索城市，返回默认列表就行 （逆地理编码搜索失败）
        _currentCity = nil;
    }
     
    [MBProgressHUD hideHUD];
    
    [MBProgressHUD showError:@"请求超时，请检查网络连接"];
    
}


/**
 *  POI搜索成功回调函数
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    
    //!< 搜索成功，如果搜索到结果和没有搜索到结果分别进行处理
    
    if(response.count > 0)
    {
        
        CLLocationCoordinate2D location = _mapView.userLocation.location.coordinate;
        
        //!< 计算距离
        NSArray *convertPois = [XMCalculateDistanceTool calculateDistanceWithArray:response.pois startPoint:location];
        
        //!< 搜索到结果
        [self executeSearchResultWithArray:convertPois];
    
    }else
    {
        //!< 没有搜索到结果
        XMMapSearchResultViewController *vc = [XMMapSearchResultViewController new];
        
        [self.navigationController pushViewController:vc animated:YES];
    
    }
    
     [MBProgressHUD hideHUD];
}

/**
 *  查找离线地图坐标时候使用
 *
 * 地理编码
 */

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if ([request.address isEqualToString:_offlineItemName]) //!< 地理编码是查看离线地图时候的请求
    {
//        [MBProgressHUD hideHUD];
        AMapGeocode *result = [response.geocodes firstObject];
        AMapGeoPoint *location = result.location;
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude) animated:YES];
        [_mapView setZoomLevel:10];
        
        return;
    }

}

/**
 *  逆地理编码，查找当前城市名称 搜索成功回调函数
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
     //-- 当前定位城市
    NSString *cityName = response.regeocode.addressComponent.city;
 
    
    _currentCity = cityName;
        
    
    
}

/**
 *  搜索路径规划回调成功回调函数(不是导航规划路径)
 */
//- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
//{
//
//    //-- 取出路径当中的一条线路
//    AMapRoute *route = response.route;
//    AMapPath *path = [route.paths firstObject];
//
//    NSMutableArray *polys = [NSMutableArray array];
//    //    AMapStep *step = path.steps[0];
//    for (AMapStep *step in path.steps)
//    {
//        //-- 分割每个polyLine的坐标
//        NSArray *array = [step.polyline componentsSeparatedByString:@";"];//有多少坐标
//        CLLocationCoordinate2D *coords = malloc(array.count * sizeof(CLLocationCoordinate2D));
//        for (int i = 0; i < array.count; i++)
//        {
//            NSString *str = array[i];
//            //            XMLOG(@"******%@",str);
//            NSArray *arr = [str componentsSeparatedByString:@","];
//            coords[i].latitude = [arr[1] doubleValue];
//            coords[i].longitude = [arr[0] doubleValue];
//        }
//
//        MAPolyline *poliyline = [MAPolyline polylineWithCoordinates:coords count:array.count];
//
//        [polys addObject:poliyline];
//
//    }
//
//    [_mapView addOverlays:polys];
//
//    [_mapView showAnnotations:@[_mapView.userLocation,_destinationLocation] animated:YES];
//    
//    
//    
//}



#pragma mark -- AMapNaviDriveManagerDelegate --- 导航代理方法



/**
 *  启动导航后回调函数
 *
 *  @param naviMode 导航类型，参考AMapNaviMode
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode
{
    
        XMLOG(@"开始导航");
    
}






/**
 *  发生错误时,会调用代理的此方法
 *
 *  @param error 错误信息
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error{
    
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"路径规划失败，请检查网络连接"];
    
    
}
/**
 *  驾车路径规划失败后的回调函数
 *
 *  @param error 错误信息,error.code参照AMapNaviCalcRouteState
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error
{

    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"路径规划失败，请检查网络连接"];

}




/**
 *  驾车路径规划成功后的回调函数
 */
- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    
    
    XMLOG(@"路径规划成功，准备绘制路径");
    
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:@"路径规划成功"];
    
    
    
//    //-- 删除所有遮盖
//    [_mapView removeOverlays:_mapView.overlays];
//    
//    // -- 移除数组所有内用
//    [_routeInfoArray removeAllObjects];
//    
//    
//    //-- 导航路径
//    AMapNaviRoute *route = _manager.naviRoute;
//    
//    //-- 取出导航路径所有形状点个数
//    int count = (int)route.routeCoordinates.count;
//    
//    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
//    
//    for (int i = 0; i < count; i++)
//    {
//        AMapNaviPoint *coordinate = route.routeCoordinates[i];
//        coords[i].latitude = coordinate.latitude;
//        coords[i].longitude = coordinate.longitude;
//    }
//    
//    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:count];
//    [_mapView addOverlay:polyline];
//    
//    //-- 释放内存
//    free(coords);
//    
//    [_mapView showAnnotations:@[_mapView.userLocation,_destinationLocation] animated:YES];
//    
 
    self.tabBarController.tabBar.hidden = YES;
    [MBProgressHUD hideHUD];
    
 
//    AMapNaviViewController *naviVC = [[AMapNaviViewController alloc]init];
//    naviVC.delegate = self;
//    
//    [_manager presentNaviViewController:naviVC animated:YES];
    
    [self.view addSubview:self.driveView];
    
    [_manager addDataRepresentative:self.driveView];
    
    [_manager startGPSNavi];
    
}


/**
 *  出现偏航需要重新计算路径时的回调函数
 */
- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager
{
 
    //!< 重新计算路径 躲避拥堵
    
    [_manager recalculateDriveRouteWithDrivingStrategy:AMapNaviDrivingStrategySingleAvoidCongestion];
    
}


/**
 *  已经推出导航控制器调用
 */
//- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController
//{
//    
//    [self.view sendSubviewToBack:_backView];
//    
//    [_operateView setMessage:@""];
//    
//    _operateView.hidden = YES;
//    
//    _searchView.hidden = NO;
//    
//    [self.listView removeFromSuperview];
//    
//    [_mapView removeAnnotations:self.annotations];
//    
//    _topView.hidden = YES;
//    
//    _bottomView.hidden = YES;
//    
//    
//    _topView.transform = CGAffineTransformMakeTranslation(0, -64);
//    
//    _bottomView.transform = CGAffineTransformMakeTranslation(0, mainSize.height - 64);
//    
//}
//
//
///**
// *  导航控制器已经销毁时调用
// */
//- (void)naviManager:(AMapNaviManager *)naviManager didDismissNaviViewController:(UIViewController *)naviViewController
//{
//   
//    self.tabBarController.tabBar.hidden = NO;
//
//    [_manager stopNavi];
//    
//    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
//   
//    [_mapView removeOverlays:_mapView.overlays];
//    if (_destinationLocation)
//    {
//        [_mapView removeAnnotation:_destinationLocation];
//    }
//    
//    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
//    
//    
//}


/**
 *  导航播报信息回调函数
 *
 *  @param soundString 播报文字
 *  @param soundStringType 播报类型,参考AMapNaviSoundType
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    
       [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
    
    
    
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



 
#pragma mark -- 搜索代理 相关操作


/**
 *  监听return按键的点击
 */
- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
    
    
    // 如果没有输入文字，就结束编辑状态，不做任何操作
    if (![sender.text isEqualToString:@""])
    {
        
        [self executeSerachActionWithText:sender.text];
        
    }
    
     return YES;
}

- (void)executeSerachActionWithText:(NSString *)text
{
    
    if(text.length == 0)return;
    
    [MBProgressHUD showMessage:@"正在搜索"];
    
    [self.view endEditing:YES];
    
    NSArray *searchHistory = [NSArray arrayWithContentsOfFile:XMSearchHistoryPath];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self = %@",text];
    
    NSArray *result = [searchHistory filteredArrayUsingPredicate:predicate];
    
    if (result.count == 0)
    {
        
        //!< 在搜索历史中不存在，添加到历史搜索数据
        NSMutableArray *newHistory = [NSMutableArray arrayWithObject:text];
        
        [newHistory addObjectsFromArray:searchHistory];
        
        [newHistory writeToFile:XMSearchHistoryPath atomically:YES];
        
        self.tabDataSource = newHistory;
        
    }else
    {
        //!< 在搜索历史中存在，调整顺序
        
        NSPredicate *pre_left = [NSPredicate predicateWithFormat:@"self != %@",text];
        
       NSArray *newListData = [searchHistory filteredArrayUsingPredicate:pre_left];
        
       NSMutableArray *dataArray = [NSMutableArray arrayWithObject:text];
    
        [dataArray addObjectsFromArray:newListData];
        
        [dataArray writeToFile:XMSearchHistoryPath atomically:YES];
        
        self.tabDataSource = dataArray;
        
    }
    
    [_historyTableView reloadData];
    
    self.searchKeyword = text;
    
    //-- 用户输入文字， 构造搜索对象，设置请求参数开始进行搜索
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc]init];
    
    //-- 设置城市的时候应该根据用户当前的位置来设置，反地理编码来获取
    
    if(_currentCity)
    {
        request.city = _currentCity;
 //     request.cityLimit = YES; 不进行城市限制
        
    }
    
    request.keywords = text;
    
    request.offset = 10; //默认20
    
    request.page = 1;//!< 第一页
    
    //-- 开始进行搜索
    [_search AMapPOIKeywordsSearch:request];




}

#pragma mark -------------- XMCommonViewDelegate
/*!
 @brief 点击常用地址视图
 */
- (void)commonViewDidClick:(XMCommonView *)view
{
    XMMapUserCommonAddressModel *model;
    
    switch (view.tag) {
            
        case 0:
            
            model = [XMMapUserCommonAddressModel firstCommonAddress];
            
            break;
            
        case 1:
            
            model = [XMMapUserCommonAddressModel secondCommonAddress];
            
            break;
            
        default:
            break;
    }
    
    if (model == nil)
    {
        //!< 跳转到搜索界面,如果默认地址不存在的话
        XMSetCommonAddressViewController *vc = [XMSetCommonAddressViewController new];
        
        vc.currentCity = _currentCity;
        
        vc.index = view.tag;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else
    {
        //!< 默认地址有值的话直接进行导航
        
        AMapPOI *poi = [AMapPOI new];
        
        poi.location = [AMapGeoPoint locationWithLatitude:model.latitude longitude:model.longitude];
        
        [self mapShowListViewDidSelectDestinationPoi:poi];
        
    }
    


}


/*!
 @brief 点击常用地址的导航按钮
 */
- (void)commonViewNaviBtnDidClick:(XMCommonView *)view
{
    [self commonViewDidClick:view];


}


/*!
 @brief 触发长按手势
 */
- (void)commonViewDidTriggerLongPress:(XMCommonView *)view
{
    if (view.tag == 0)//!< 点击第一个view
    {
             //!< 获取默认数据
            XMMapUserCommonAddressModel *model = [XMMapUserCommonAddressModel firstCommonAddress];
            
            if (model)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确认要清楚常用地址？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                
                alert.tag = 128;
                
                [alert show];
            }
        
    }else
    {
        //!< 获取默认数据
        XMMapUserCommonAddressModel *model = [XMMapUserCommonAddressModel secondCommonAddress];
        
        if (model)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确认要清除常用地址？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            alert.tag = 129;
            
            [alert show];
        }
    
    
    }


}

#pragma mark --- 搜索成功 执行结果

- (void)executeSearchResultWithArray:(NSArray *)pois
{
    
    _backView.transform = CGAffineTransformMakeTranslation(mainSize.width, 0);
    
    [self.view bringSubviewToFront:_backView];
    
    _searchView.hidden = YES;
    
    self.operateView.hidden = NO;
    
    [_operateView setMessage:_searchKeyword];
    
    XMMapShowListView *listView = [XMMapShowListView listView];
    
    listView.frame = CGRectMake(0, mainSize.height - 170, mainSize.width, 170);
    
    listView.dataSource = pois;
    
    listView.delegate = self;
    
    [_backView addSubview:listView];
    
    self.listView = listView;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(listViewPan:)];
    
    [listView addGestureRecognizer:pan];
    
    
    
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:pois.count];
    
    for (AMapPOI * poi in pois)
    {
        
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc]init];
        
        annotation.title = poi.name;
        
        annotation.subtitle = poi.address;
        
        annotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
         
        [annotations addObject:annotation];
        
    }
    
    self.annotations = annotations;
    
    [_mapView addAnnotations:annotations];
    
    [_mapView  showAnnotations: annotations edgePadding:UIEdgeInsetsMake(140, 70, 170, 70) animated:YES];
    
    [self.view bringSubviewToFront:_backView];
    
    [UIView animateWithDuration:0.3 animations:^{
       
        _backView.transform = CGAffineTransformIdentity;
        
        _topView.transform = CGAffineTransformMakeTranslation(-mainSize.width, 0);
        
        _bottomView.transform = CGAffineTransformMakeTranslation(-mainSize.width, 0);
        
    }];
    
    
}

#pragma mark --- 响应按钮点击 || 手势的方法

//!< 点击顶部的搜索栏(新的搜索栏的搜索按钮)
- (void)searchBtnClick:(UIButton *)sender
{
    
    UITextField *textTF = (UITextField *)[_topView viewWithTag:404];
    
    [self executeSerachActionWithText:textTF.text];
    
}


/**
 *  点击地图上搜索返回按钮（旧的搜索栏）
 */
- (void)backBtnDidClick:(UIButton *)sender
{
        _topView.transform = CGAffineTransformMakeTranslation(0, -64);
        
        _bottomView.transform = CGAffineTransformMakeTranslation(0, mainSize.height - 64);
        
        _topView.hidden = YES;
        
        _bottomView.hidden = YES;
        
        UITextField *searchTF = (UITextField *)[_topView viewWithTag:404];
    
        searchTF.text = @"";
    
        [self.view endEditing:YES];
    
        self.tabBarController.tabBar.hidden = NO;
    
     _operateView.hidden = YES;//!< 隐藏新搜索
    
     _searchView.hidden = NO;//!< 展示旧搜索
    
}

//!< 点击清除历史按钮
- (void)clearHistoryRecordBtnClick
{
    
    
    [[NSFileManager defaultManager] removeItemAtPath:XMSearchHistoryPath error:nil];
    
    self.tabDataSource = nil;
    
    [_historyTableView reloadData];
    
    
}

/**
 *  点击路况按钮
 */
- (void)btn_trafficDidClick:(UIButton *)sender
{
//      sender.selected = !sender.selected;
//    
//    _mapView.showTraffic  = sender.selected;
    
    XMBaiduMapViewController *vc = [XMBaiduMapViewController new];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}



/**
 *  点击定位按钮
 */
- (void)btn_locationDidClick:(UIButton *)sender
{
    if(!locationEnable)
    {
       
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请打开系统设置中“隐私-定位服务”，允许“酷锐宝”使用您的位置。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
      
        [alert show];
    
        return;
    }
    
    NSMutableArray *deleteAnnos = [NSMutableArray array];
    
    for (NSObject *obj in _mapView.annotations)
    {
        
        if ([obj isKindOfClass:[MAUserLocation class]])
        {
            continue;
        }
        
        [deleteAnnos addObject:obj];
        
    }
    
    [_mapView removeAnnotations:deleteAnnos];
    
    [_mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
    
    [_mapView setZoomLevel:17 animated:YES];
    
}



/**
 *  点击放大按钮   缩放级别是 3~20
 */
- (void)btn_enlargeDidClick
{
    if (self.zoomLevel < 20)
    {
        
        [_mapView setZoomLevel:++_zoomLevel animated:YES];
        
    }

}



/**
 *  点击缩小按钮
 */
- (void)btn_reduceDidClick:(UIButton *)sender
{
    if (self.zoomLevel > 3)
    {
          [_mapView setZoomLevel:--_zoomLevel animated:YES];
    }
    
}

//!< 点击显示车辆位置按钮
- (void)btn_showCarDidClick:(UIButton *)sender
{
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showError:@"网络未连接"];
        
        return;
        
    }
    
    //!< 判断用户是否有车辆&& 车辆数据已经请求到
    if(_defaultCar.chepaino.length < 6 && _defaultCar)
    {
        //!< 用户没有车辆
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"没有车辆，请到设置界面添加车辆" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    
        [alert show];
        
        return;
    }
    
    
    if (_isDefaultCar.selected == NO)
    {
        //!< 选中的是默认车辆，定位默认车辆
        if (self.defaultCarAnnotation)
        {
            
            [_mapView removeAnnotations:_mapView.annotations];
            
            [_mapView addAnnotation:_defaultCarAnnotation];
 
            [_mapView setZoomLevel:17 animated:YES];
            
            [_mapView showAnnotations:@[_defaultCarAnnotation] edgePadding:UIEdgeInsetsMake(130, 100, 130, 100) animated:YES];
            
         }else
         {
             
             [MBProgressHUD showError:@"正在获取定位信息" toView:self.view];
         
         
         }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
             [self getUserDefaultCarLocation];//!< 更新数据
            
        });
        
       
        
    }else
    {
        
        if (self.userAllCarsAnnotations.count != self.userCarList.count)
        {
            [MBProgressHUD showError:@"正在获取位置信息"];return;
        }
         //!< 选中的是定位全部车辆
        if (self.userAllCarsAnnotations.count > 0)
        {
 
            
            
            [_mapView removeAnnotations:_mapView.annotations];//!< 删除除过用户位置的其他标注
            
            //!< 重新添加所有车辆
            [_mapView addAnnotations:self.userAllCarsAnnotations];
            
            NSLog(@"%@-----------------222",self.userAllCarsAnnotations);
            
            [_mapView showAnnotations:self.userAllCarsAnnotations edgePadding:UIEdgeInsetsMake(130, 100, 130, 100) animated:YES];
            
            XMLOG(@"添加完成后的数组长度%ld",_mapView.annotations.count);
            
            
        }else
        {
         [MBProgressHUD showError:@"正在获取定位信息" toView:self.view];
        }
        
 
    
    
    }
    
    
    
    
    
}




/**
 *  点击选择导航视图中的取消按钮
 */
- (void)btn_cancleDidClick
{
    
    self.tabBarController.tabBar.hidden = NO;
//    self.naviView.hidden = YES;
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotation:_destinationLocation];
    
    
}


/**
 *  搜索栏点击手势
 */
- (void)searchBarDidClick:(UITapGestureRecognizer *)tap
{
    
     //!< 点击地图界面的搜索视图 动画显示新的搜索栏
    _topView.hidden = NO;
    
    _bottomView.hidden = NO;
    
    
    
    [UIView animateWithDuration:0.25 animations:^{
        
        _topView.transform = CGAffineTransformIdentity;
        
        _bottomView.transform = CGAffineTransformIdentity;
        
    }];
    
    UITextField *textField = (UITextField *)[_topView viewWithTag:404];
    
    textField.text = nil;
    
    [textField becomeFirstResponder];
    
    [_historyTableView reloadData];
    
    self.tabBarController.tabBar.hidden = YES;
    
    
}

//!< 返回到最新的搜索界面($$)
- (void)backToSearchList
{
    [UIView animateWithDuration:0.2 animations:^{
       
        _backView.transform = CGAffineTransformMakeTranslation(mainSize.width, 0);
        
        _bottomView.transform = CGAffineTransformIdentity;
        
        _topView.transform = CGAffineTransformIdentity;
        
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.view sendSubviewToBack:_backView];
        
        _backView.transform = CGAffineTransformIdentity;
        
    });
    
    [_operateView setMessage:@""];
    
    [self.listView removeFromSuperview];
    
    
    [_mapView removeAnnotations:self.annotations];
    
    _operateView.hidden = YES;
    
    _searchView.hidden = NO;
   
    
}


//!< 返回到主界面  ($$$)
- (void)exitToMapView
{
    //!< 切换顶部视图
    _operateView.hidden = YES;
    
     [_operateView setMessage:@""];
    
     _searchView.hidden = NO;
    
    [self.view sendSubviewToBack:_backView];//!< 地图回原位置
    
    
    _bottomView.hidden = YES;
    
    _topView.hidden = YES;
    
    _bottomView.transform = CGAffineTransformIdentity;
    
     _topView.transform = CGAffineTransformIdentity;

    
    //!< 清除大头针
    
    [_mapView removeAnnotations:self.annotations];
    
    //!<删除tableView
    
    
    [self.listView removeFromSuperview];
    
     self.tabBarController.tabBar.hidden = NO;
    

}

- (void)listViewPan:(UIPanGestureRecognizer *)sender
{
    
    if (!self.navigationController.navigationBar.hidden)
    {
        self.navigationController.navigationBar.hidden = YES;
    }
    
    CGPoint p = [sender translationInView:sender.view];
    
    CGRect frame = _listView.frame;
    
    frame.origin.y += p.y;
    
    frame.size.height -= p.y;
    
    _listView.frame = frame;
    
    [sender setTranslation:CGPointZero inView:sender.view];
    
   
    
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        if (frame.origin.y > mainSize.height - 173)
        {
            
            frame.origin.y = mainSize.height - 173;
            
            frame.size.height = 173;
            
            [UIView animateWithDuration:0.2 animations:^{
                _listView.frame = frame;
            }];
            
        }else if (frame.origin.y > mainSize.height/2) {
            
            int distance = frame.origin.y - mainSize.height/2;
            
            frame.origin.y = mainSize.height/2;
            
            frame.size.height += distance;
            
            [UIView animateWithDuration:0.2 animations:^{
                _listView.frame = frame;
            }];
            
        
        
        }else
        {
            frame.origin.y = 64;
            
            frame.size.height = mainSize.height - 64;
            
            self.navigationController.navigationBar.hidden = NO;
            
            self.navigationItem.title = self.searchKeyword;
            
            [UIView animateWithDuration:0.1 animations:^{
                
                _listView.frame = frame;
            }];
            
            return;
            
        }

    }
    
   
    
    

}


//!< 选中全部车辆或者当前车辆，决定显示位置的车辆
- (void)selectCarBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
}


#pragma mark ------------ UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tabDataSource.count == 0)
    {
        tableView.tableFooterView.hidden = YES;
    }else
    {
        tableView.tableFooterView.hidden = NO;
    
    }
    
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.tabDataSource.count;

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *identifier = @"equipmentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.textLabel.textColor = XMGrayColor;
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
    }
    
    cell.textLabel.text = self.tabDataSource[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:@"ellipse-3"];
    
    return cell;

}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];

}

#pragma mark --- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *text = self.tabDataSource[indexPath.row];
    
    [self executeSerachActionWithText:text];//!< 执行搜索操作


}



#pragma mark -- listDelegate
/**
 *  tableView点击某个poi返回地图界面规划导航路径
 */
- (void)mapShowListViewDidSelectDestinationPoi:(AMapPOI *)poi
{

    
    
    [MBProgressHUD showMessage:@"正在规划路径"];
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:@"正在规划路径"];
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:_mapView.userLocation.coordinate.latitude longitude:_mapView.userLocation.coordinate.longitude];
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:poi.location.latitude longitude:poi.location.longitude];
    
    MAPointAnnotation *anno = [[MAPointAnnotation alloc]init];
    anno.title = poi.name;
    anno.subtitle = poi.address;
    anno.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    if (_destinationLocation)
    {
        [_mapView removeAnnotation:_destinationLocation];
    }
    
    _destinationLocation = anno;
    
    [_mapView addAnnotation:anno];
    
    //-- 开始规划路径
    [_manager calculateDriveRouteWithStartPoints:@[startPoint] endPoints:@[endPoint] wayPoints:nil drivingStrategy:AMapNaviDrivingStrategySinglePrioritiseDistance];
 

}

//!< tableView 选中一行
- (void)mapShowListViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [_mapView selectAnnotation:[self.annotations objectAtIndex:indexPath.row] animated:YES];

}

#pragma mark -- UIAlertViewDelegate --- 警告代理方法


/**
 *  alertViewDelegate代理方法
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (alertView.tag)
    {
        case 100:
            
            if (buttonIndex == 0)
            {
//                [_manager dismissNaviViewControllerAnimated:YES];
                
                [_manager stopNavi];
                
                [_driveView removeFromSuperview];
                
                _driveView = nil;
                
                [self exitToMapView];
                
                [_mapView showAnnotations:@[_mapView.userLocation] animated:YES];
                
                NSMutableArray *annoM = [NSMutableArray array];
                
                for (id anno in _mapView.annotations)
                {
                    if ([anno isKindOfClass:[MAUserLocation class]])
                    {
                        //!< 如果是系统大头针
                        continue;
                    }
                    
                    [annoM addObject:anno];
                }
                
                [_mapView removeAnnotations:annoM];
                
                [self.view endEditing:YES];
                
            }
            
            break;
            
        case 128:
            
            if (buttonIndex == 1){
            
                [[NSFileManager defaultManager] removeItemAtPath:CommonAddressOne error:nil];
                
                _firstCommoView.address = @"常用地址1";
            }
            
            break;
            
        case 129:
            
            if(buttonIndex == 1)
            {
                [[NSFileManager defaultManager] removeItemAtPath:CommonAddressTwo error:nil];
                
                _secondCommonView.address = @"常用地址2";
 
            }
            
            break;
    
            
        default:
            
            if(buttonIndex == 1)
            {
                 //-- 上一步已经将当前城市保存在变量中，最后写入沙盒
                [[NSUserDefaults standardUserDefaults] setObject:_currentCity forKey:CURRENTCITY];
                
            }else
            {
                 //-- 不进行和切换，当前城市还是设置为上次沙河中的城市
                _currentCity = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENTCITY];
                
            }
            break;
    }
    
    
}









@end

