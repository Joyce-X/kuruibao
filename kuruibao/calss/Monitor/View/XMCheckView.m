//
//  XMCheckView.m
//  kuruibao
//
//  Created by x on 16/11/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:这个类专门在用户检测信息的时候，执行动画效果
 
 **********************************************************/
#import "XMCheckView.h"

@implementation XMCheckView


- (instancetype)initWithDelegate:(id<XMCheckViewDelegate>)delegate
{

    self = [super init];
    
    if (self)
    {
        self.delegate = delegate;
        
         [self setupSubviews];
        
    }

    return self;

}

- (void)setupSubviews
{
    //-- 添加蒙版
    self.frame = [UIScreen mainScreen].bounds;
    
    self.tag = 14;
    
     //-- 添加容器
    UIView *alertView = [UIView new];
    
    [self addSubview:alertView];
    
    [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self);
        
        make.size.equalTo(CGSizeMake(FITWIDTH(269), (163)));
        
    }];
    
    //-- 添加底色
    UIImageView *iv_bottom = [[UIImageView alloc]init];
    
    iv_bottom.image = [UIImage imageNamed:@"alert_background"];
    
    [alertView addSubview:iv_bottom];
    
    [iv_bottom mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(alertView);
        make.size.equalTo(alertView);
        
    }];
    
    //-- 添加按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setTitleColor:XMColorFromRGB(0x5DD672) forState:UIControlStateNormal];
    
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [alertView addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(alertView);
        
        make.left.equalTo(alertView);
        
        make.right.equalTo(alertView);
        
        make.height.equalTo(44);
        
    }];
    
    
    //-- 添加line
    UIView *line = [UIView new];
    
    line.backgroundColor = [UIColor lightGrayColor];
    
    [alertView addSubview:line];
    
    [line makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(alertView);
        make.right.equalTo(alertView);
        make.bottom.equalTo(btn.mas_top);
        make.height.equalTo(1);
        
    }];
    
    
    //-- 添加信息
    UILabel *messageLabel = [UILabel new];
    
    messageLabel.text = @"";
    
    messageLabel.font = [UIFont systemFontOfSize:16];
    
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    messageLabel.textColor = XMColorFromRGB(0x7F7F7F);
    
    [alertView addSubview:messageLabel];
    
    self.messageLabel = messageLabel;
    
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(alertView);
        
        make.right.equalTo(alertView);
        
        make.bottom.equalTo(line.mas_top).offset(-15);
        
        make.height.equalTo(20);
        
    }];
    
    UIView *translateView = [UIView new];
    
    [alertView addSubview:translateView];
    
    [translateView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        make.left.equalTo(alertView);
        
        make.right.equalTo(alertView);
        
        make.top.equalTo(alertView);
        
        make.bottom.equalTo(messageLabel.mas_top);
        
    }];
    
    //-- 添加imageView
    UIImageView *iv_front = [UIImageView new];
    
    iv_front.image = [UIImage imageNamed:@"monitor_indicator"];
    
    [translateView addSubview:iv_front];
    
    [iv_front mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(translateView);
        
        make.size.equalTo(CGSizeMake(34, 34));
    }];
    
    
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    anima.duration = 3.0f;
    
    anima.removedOnCompletion = NO;
    
    anima.repeatCount = MAXFLOAT;
    
    anima.toValue = @(M_PI *2);
    
    [iv_front.layer addAnimation:anima forKey:nil];
    
    
    self.transform = CGAffineTransformScale(self.transform, 1.04, 1.04);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.transform = CGAffineTransformIdentity;
    });
    
    
  

}

- (void)btnClick
{
    
    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(checkViewDidEndCheck)])
    {
        [self.delegate checkViewDidEndCheck];
    }
    
}

@end
