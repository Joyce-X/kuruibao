//
//  XMDVRLocalFileViewController.m
//  GKDVR
//
//  Created by x on 16/10/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:
 
    管理本地文件的控制器，三个子控制器
 
 **********************************************************/
#import "XMDVRLocalFileViewController.h"
#import "XMDVRLocalFileImageVC.h"
#import "XMDVRLocalFileVideoVC.h"
#import "XMDVRLocalFileLockVideoVC.h"


#define chooseBarHeight 39

#define btn_W (mainSize.width/3)

#define arrowHeight 22

@interface XMDVRLocalFileViewController ()

@property (nonatomic,weak)UIImageView* line;

@property (nonatomic,weak)UIButton* lastBtn;

@property (nonatomic,weak)UIScrollView* scrollView;


@end

@implementation XMDVRLocalFileViewController


-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self createChildVC];
        
    }

    return self;
 
}

- (void)createChildVC
{
    XMDVRLocalFileImageVC *imageVC = [XMDVRLocalFileImageVC new];
    
    XMDVRLocalFileVideoVC *videoVC = [XMDVRLocalFileVideoVC new];
    
    XMDVRLocalFileLockVideoVC *lockVideoVC = [XMDVRLocalFileLockVideoVC new];
    
    [self addChildViewController:imageVC];
    
    [self addChildViewController:videoVC];
    
    [self addChildViewController:lockVideoVC];
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
  
    
}

- (void)setupInit
{
    
    self.imageVIew.image = [UIImage imageNamed:@"DVR_mainBackground"];
    
    self.message = @"本地图片";
    
    UIView *chooseView = [[UIView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width,chooseBarHeight)];
    
    chooseView.backgroundColor = XMWhiteColor;
    
    [self.view addSubview:chooseView];
    
    self.chooseBar = chooseView;
    
    UIButton *imageBtn = [self createButtonWithTitle:@"图片" tag:0];
    
    UIButton *videoBtn = [self createButtonWithTitle:@"视频" tag:1];
    
    UIButton *lockBtn = [self createButtonWithTitle:@"锁定视频" tag:2];
    
    
    [chooseView addSubview:imageBtn];
    
    [chooseView addSubview:videoBtn];
    
    [chooseView addSubview:lockBtn];
    
    self.lastBtn = imageBtn;
    
    UIView *line_01 = [UIView new];
    
    line_01.backgroundColor = XMGrayColor;
    
    line_01.alpha = 0.3;
    
    [chooseView addSubview:line_01];
    
    [line_01 mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(imageBtn);
        
        make.height.equalTo(20);
        
        make.top.equalTo(chooseView).offset(9);
        
        make.width.equalTo(1);
        
    }];
    
    
    UIView *line_02 = [UIView new];
    
    line_02.backgroundColor = XMGrayColor;
    
    line_02.alpha = 0.3;
    
    [chooseView addSubview:line_02];
    
     [line_02 mas_makeConstraints:^(MASConstraintMaker *make) {
        
         make.right.equalTo(videoBtn);
        
         make.height.equalTo(20);
        
         make.top.equalTo(chooseView).offset(9);
        
         make.width.equalTo(1);
        
    }];
    
    UIImageView *line = [UIImageView new];
    
    line.image = [UIImage imageNamed:@"DVR_slider"];
    
    [chooseView addSubview:line];
    
    self.line = line;
    
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.equalTo(40);
        
         make.centerX.equalTo(imageBtn);
        
        make.bottom.equalTo(chooseView).offset(-3);
        
        make.height.equalTo(2);
        
    }];
    
    
    UIView *arrowView = [[UIView alloc]init];
    
    arrowView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:arrowView];
    
    [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.equalTo(arrowHeight);
        
        make.top.equalTo(chooseView.mas_bottom);
        
        make.left.equalTo(chooseView);
        
        make.right.equalTo(chooseView);
        
    }];
    
    UIImageView *arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"DVR_pullRefresh"]];
    
    arrow.contentMode = UIViewContentModeScaleAspectFit;
    
    [arrowView addSubview:arrow];
    
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.equalTo(arrowView);
        
        make.height.equalTo(10);
        
        make.width.equalTo(10);
        
        
    }];
    
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, backImageH + chooseBarHeight +arrowHeight, mainSize.width, mainSize.height - chooseBarHeight - backImageH - arrowHeight)];
    
    
    scrollView.scrollEnabled = NO;
    
    scrollView.showsHorizontalScrollIndicator = NO;
     
    scrollView.contentSize = CGSizeMake(mainSize.width * self.childViewControllers.count, mainSize.height - backImageH - chooseBarHeight);
    
    [self.view addSubview:scrollView];
    
    self.scrollView = scrollView;

 
    for (int i = 0;i <self.childViewControllers.count ;i++)
    {
        UIViewController *vc = self.childViewControllers[i];
        
        
        vc.view.frame = CGRectMake(mainSize.width * i, 0, mainSize.width, mainSize.height - backImageH - chooseBarHeight - arrowHeight);
        
        [scrollView addSubview:vc.view];
    }
    
    
    
}
 
- (UIButton *)createButtonWithTitle:(NSString *)title tag:(NSInteger)tag
{
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.tag = tag;
    
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:XMGrayColor forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(chooseBarBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    button.frame = CGRectMake(btn_W * tag, 0, btn_W, chooseBarHeight);
    
    return button;
    
    
    
}


#pragma mark --- btn click

- (void)chooseBarBtnDidClick:(UIButton *)sender
{
    if (self.lastBtn.tag == sender.tag)
    {
        return;
    }
    
     NSInteger translateNum = sender.tag - self.lastBtn.tag;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        self.line.transform = CGAffineTransformTranslate(self.line.transform, translateNum * btn_W, 0);
        
    }];
    
    [self.scrollView setContentOffset:CGPointMake(mainSize.width * sender.tag, 0)];
    
    self.lastBtn = sender;
    
    
}

@end
