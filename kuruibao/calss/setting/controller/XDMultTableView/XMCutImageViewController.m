//
//  XMCutImageViewController.m
//  kuruibao
//
//  Created by x on 16/9/9.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMCutImageViewController.h"

@interface XMCutImageViewController ()

@end

@implementation XMCutImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatSubViews];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //->>隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;

    MobClickBegain(@"裁剪头像页面");

}

- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    
    MobClickEnd(@"裁剪头像页面");

}

- (void)creatSubViews
{
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scroll.maximumZoomScale = 0.5;
    [self.view addSubview:scroll];
    
    //->>创建IV
    UIImageView *imageView = [[UIImageView alloc]init];
//    imageView.userInteractionEnabled = YES;
    imageView.image = _originImage;
    imageView.width = mainSize.width;
    imageView.height = mainSize.width * _originImage.size.height / _originImage.size.width;
    imageView.center = scroll.center;
    [scroll addSubview:imageView];
    
    //->>添加pan收拾
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [scroll addGestureRecognizer:pan];
    
    //->>添加缩放收拾
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    [scroll addGestureRecognizer:pinch];
    
    //->>创建顶部的按钮
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 64)];
    topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self.view addSubview:topView];
    
    //->>文字
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.text = @"移动和缩放";
    [topView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(topView);
        make.width.equalTo(100);
        make.height.equalTo(30);
        make.bottom.equalTo(topView.mas_bottom).offset(-7);
        
    }];
    
    
    //->>按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.equalTo(30);
        make.height.equalTo(20);
        make.bottom.equalTo(label);
        make.left.equalTo(topView).offset(20);
        
    }];

    
    //->>底部确定按钮
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, mainSize.height - 40, mainSize.width, 40)];
    bottomView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    [self.view addSubview:bottomView];
    
    UIButton *commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:@"确定" forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    commitBtn.backgroundColor = [UIColor blueColor];
    commitBtn.titleLabel.textColor = [UIColor whiteColor];
    [bottomView addSubview:commitBtn];
    [commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView);
        make.width.equalTo(40);
        make.height.equalTo(25);
        make.right.equalTo(bottomView).offset(-20);
    }];
}

#pragma mark --- 监听手势的方法


- (void)pan:(UIPanGestureRecognizer *)sender
{
   CGPoint p = [sender translationInView:sender.view];
    sender.view.x += p.x;
    sender.view.y += p.y;
    [sender setTranslation:CGPointZero inView:sender.view];
    
}

- (void)pinch:(UIPinchGestureRecognizer *)sender
{
    UIImageView *iv = (UIImageView *)sender.view;
    iv.transform = CGAffineTransformScale(iv.transform, sender.scale, sender.scale);
    [sender setScale:1];
    
}


#pragma mark --- 监听按钮的点击

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)commitBtnClick
{
    
}


@end
