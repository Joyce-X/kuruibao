//
//  XMMainNaviController.m
//  KuRuiBao
//
//  Created by x on 16/6/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMMainNaviController.h"
 @interface XMMainNaviController ()

@end

@implementation XMMainNaviController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.hidden = YES;
    
    //-- 设置初始化信息
    [self setupInitInfo];
    
     
    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    
    UIViewController *vc = self.topViewController;
    
    return [vc preferredStatusBarStyle];
}

#pragma mark -- init

- (void)setupInitInfo
{
    //-- 在初始化的时候先将导航栏显示为透明色
//    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationBar setShadowImage:[[UIImage alloc]init]];
//    self.navigationBar.translucent = YES;
//    self.navigationBar.barStyle = UIBarStyleBlack;
    
   
    
}


 

@end
