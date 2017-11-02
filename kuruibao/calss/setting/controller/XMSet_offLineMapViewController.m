//
//  XMSet_offLineMapViewController.m
//  kuruibao
//
//  Created by x on 16/9/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/***********************************************************************************************
 展现离线地图的tabbar控制器 管理下载管理控制器和城市展示控制器
 
 
 ************************************************************************************************/

#import "XMSet_offLineMapViewController.h"
#import "XMMapDownloadViewController.h"
#import "XMDownLoadViewController.h"
#import "XMTabBarButton.h"

#define  btnWidth 100 //顶部按钮的宽度

@interface XMSet_offLineMapViewController ()
@property (nonatomic,weak)XMTabBarButton* downloadBtn;
@property (nonatomic,weak)XMTabBarButton* cityBtn;
@property (nonatomic,weak)UIView* line;


@end

@implementation XMSet_offLineMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    //->>创建子视图
    [self createSubViews];
    
    
 }



- (void)setupInitInfo
{
    XMDownLoadViewController *allCityVC = [XMDownLoadViewController sharedInstance];
    XMMapDownloadViewController *downloadVC = [[XMMapDownloadViewController alloc]init];
    allCityVC.delegate = downloadVC;
    self.viewControllers = @[downloadVC,allCityVC];
 
    
}


- (instancetype)init
{
    if (self = [super init])
    {
        self.tabBar.hidden = YES;
        [self setupInitInfo];//!< 创建子控制器
        
    }

    return self;

}



//->>创建子视图
- (void)createSubViews
{
   //->>创建顶部视图
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 64)];
    
    topView.backgroundColor =  XMGrayColor;
    
    [self.view addSubview:topView];
    
    //->>创建返回按钮
    XMTabBarButton *backBtn = [XMTabBarButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
    
    [backBtn addTarget:self action:@selector(backBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 0);
    
    [topView addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(30);
        
        make.height.equalTo(30);
        
        make.left.equalTo(topView).offset(20);
        
        make.bottom.equalTo(topView).offset(-7);
        
    }];
    
    
    XMTabBarButton *downloadBtn = [XMTabBarButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn setTitle:@"下载管理" forState:UIControlStateNormal];
    downloadBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [downloadBtn setTitleColor:XMColorFromRGB(0x5DD672) forState:UIControlStateSelected];
 
    [downloadBtn addTarget:self action:@selector(downloadBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    downloadBtn.selected = YES;
    [topView addSubview:downloadBtn];
    _downloadBtn = downloadBtn;
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.equalTo(80);
        make.height.equalTo(30);
        make.centerX.equalTo(topView).offset(-50);
        make.bottom.equalTo(topView).offset(-10);
    }];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = XMGreenColor;
    [topView addSubview:line];
    _line = line;
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.equalTo(downloadBtn);
        make.centerX.equalTo(downloadBtn);
        make.bottom.equalTo(topView);
        make.height.equalTo(2);
        
    }];
   
    XMTabBarButton *cityBtn = [XMTabBarButton buttonWithType:UIButtonTypeCustom];
    cityBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cityBtn setTitle:@"全部城市" forState:UIControlStateNormal];
    [cityBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cityBtn setTitleColor:XMColorFromRGB(0x5DD672) forState:UIControlStateSelected];
     [cityBtn addTarget:self action:@selector(cityBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cityBtn];
    _cityBtn = cityBtn;
    [cityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(80);
        make.height.equalTo(30);
        make.left.equalTo(downloadBtn.mas_right).offset(20);
        make.bottom.equalTo(topView).offset(-10);
    }];
    
}

#pragma mark --- 监听按钮的点击事件

//->>点击返回按钮
- (void)backBtnDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

//->>点击下载按钮
- (void)downloadBtnDidClick:(XMTabBarButton *)sender
{
    [UIView animateWithDuration:.2f animations:^{
        _line.transform = CGAffineTransformIdentity;
        
    }];
    sender.selected = YES;
    _cityBtn.selected = NO;
    self.selectedIndex = 0;
}

//->>点击所有城市列表
- (void)cityBtnDidClick:(XMTabBarButton *)sender
{
    [UIView animateWithDuration:.2f animations:^{
       
        _line.transform = CGAffineTransformMakeTranslation(btnWidth, 0);
        
    }];
     sender.selected = YES;
    _downloadBtn.selected = NO;
    self.selectedIndex = 1;
}

- (void)jumpToCityList
{
    [self cityBtnDidClick:_cityBtn];

}

- (void)jumpToDownloadViewController
{
    [self downloadBtnDidClick:self.downloadBtn];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;

}

@end
