//
//  XMDVRAboutViewController.m
//  GKDVR
//
//  Created by x on 16/10/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMDVRAboutViewController.h"

@interface XMDVRAboutViewController ()

@end

@implementation XMDVRAboutViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    [self setupInit];
}

- (void)setupInit
{
    
//    self.message = @"关于";
    [self.imageVIew removeFromSuperview];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    
    imageView.image = [UIImage imageNamed:@"DVR_setting_version_background"];
    
    [self.view insertSubview:imageView atIndex:0];
    
    
    UILabel *label = [UILabel new];
    
    label.text = @"酷锐宝 V1.0";
    
    label.textColor = [UIColor whiteColor];
    
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:28];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.centerY.equalTo(self.view);
        
//        make.width.equalTo(mainSize.width);
        
        make.height.equalTo(24);
        
        make.left.equalTo(self.view).offset(FITWIDTH(101));
        
        make.right.equalTo(self.view).offset(-FITWIDTH(102));
        
        
    }];
    
    
    
    
//    //->>返回按钮
//    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    leftItem.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
//    
//    [leftItem setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    
//    [leftItem addTarget:self action:@selector(backToLast) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:leftItem];
//    
//    [leftItem mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        make.left.equalTo(self.view).offset(20);
//        
//        make.top.equalTo(self.view).offset(FITHEIGHT(48));
//        
//        make.size.equalTo(CGSizeMake(31, 31));
//        
//        
//    }];
    
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"记录仪关于页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"记录仪关于页面");
    
}


@end
