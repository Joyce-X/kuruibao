//
//  XMCarLife_showArticleViewController.m
//  kuruibao
//
//  Created by x on 17/5/9.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLife_showArticleViewController.h"

@interface XMCarLife_showArticleViewController ()

@end

@implementation XMCarLife_showArticleViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.hidden = NO;
    
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
//    self.navigationItem.title = @"精选文章";
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 44, mainSize.width, mainSize.height - 44)];
    
    [self.view addSubview:webView];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.address]]];

    //!< add topView
    
    UIView *naviBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 64)];
    
    naviBar.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:naviBar];
    
    
    //!< title
    UILabel *label = [UILabel new];
    
    label.text = @"精选文章";
    
    label.textColor = [UIColor blackColor];
    
    label.frame = CGRectMake((mainSize.width - 100)/2, 20, 100, 44);
    
    label.textAlignment = NSTextAlignmentCenter;
    
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    
    [naviBar addSubview:label];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick)];
    
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

    //!< backBtn
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    backBtn.frame = CGRectMake(6, 20, 50, 44);
    
    [naviBar addSubview:backBtn];
    
    UIView *line = [UIView new];
    
    line.backgroundColor = [UIColor blackColor];
    
    line.alpha = 0.3;
    
    [naviBar addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.equalTo(naviBar);
        
        make.height.equalTo(1);
        
    }];
    
    
}

- (void)backBtnClick
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"详细文章页面");


}


- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    
//    self.navigationController.navigationBar.hidden = YES;

    MobClickEnd(@"详细文章页面");

}



@end
