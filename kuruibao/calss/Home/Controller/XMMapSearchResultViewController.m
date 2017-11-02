//
//  XMMapSearchResultViewController.m
//  kuruibao
//
//  Created by x on 16/11/23.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMMapSearchResultViewController.h"

@interface XMMapSearchResultViewController ()

@end

@implementation XMMapSearchResultViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    [self setupInit];
    


}

- (void)setupInit
{
    
    UIView *naviBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 64)];
    
    naviBar.backgroundColor = XMWhiteColor;
    
    [self.view addSubview:naviBar];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 返回按钮
    
    //!<确认按钮
    
    //!< back button
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"Map_searchBack"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 10);
    
    [naviBar addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(naviBar);
        
        make.width.equalTo(46);
        
        make.height.equalTo(40);
        
        make.bottom.equalTo(naviBar).offset(-5);
        
    }];
    
    
    UIImageView *resultImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"notFind"]];
    
    resultImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:resultImageView];
    
    [resultImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view);
        
        make.right.equalTo(self.view);
        
        make.top.equalTo(self.view).offset(84);
        
        make.height.equalTo(160);
            
            
    }
     
    ];
    
    UILabel *messageLabel = [UILabel new];
    
    messageLabel.text = @"没有搜索到结果";
    
    messageLabel.textColor = XMGrayColor;
    
    messageLabel.font = [UIFont systemFontOfSize:15];
    
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    [naviBar addSubview:messageLabel];
    
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.equalTo(30);
        
        make.centerY.equalTo(backBtn);
        
        make.width.equalTo(110);
        
        make.centerX.equalTo(naviBar);
        
    }];
    
    
    
}

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

@end
