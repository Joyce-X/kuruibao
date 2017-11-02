//
//  UIViewController+alert.m
//  kuruibao
//
//  Created by x on 16/8/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "UIViewController+alert.h"


static BOOL isOpen;



@implementation UIViewController (alert)

- (void)showAlertWithMessage:(NSString *)message btnTitle:(NSString *)btnTitle;
{
    if (isOpen)
    {
        return;
    }
        //-- 添加蒙版
        UIView *translucentView = [[UIView alloc]initWithFrame:self.view.bounds];
//        translucentView.backgroundColor = XMColor(150, 150, 150);
        translucentView.tag = 14;
    
        [self.view addSubview:translucentView];
        
    
        //-- 添加容器
        UIView *alertView = [UIView new];
        [translucentView addSubview:alertView];
        [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.center.equalTo(translucentView);
            make.size.equalTo(CGSizeMake(269, 163));
            
            
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
        [btn setTitle:btnTitle forState:UIControlStateNormal];
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
        messageLabel.text = message;
        messageLabel.font = [UIFont systemFontOfSize:16];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = XMColorFromRGB(0x7F7F7F);
        [alertView addSubview:messageLabel];
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
        iv_front.image = [UIImage imageNamed:@"alert_icon"];
        [translateView addSubview:iv_front];
        [iv_front mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.center.equalTo(translateView);
            make.size.equalTo(CGSizeMake(34, 34));
        }];
        
     
        translucentView.transform = CGAffineTransformScale(translucentView.transform, 1.03, 1.03);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            translucentView.transform = CGAffineTransformIdentity;
        });
      
    
    isOpen = YES;
    
    
    
}

- (void)btnClick
{
    UIView *deleteView = nil;
    for (UIView *view in self.view.subviews)
    {
        if (view.tag == 14)
        {
            deleteView = view;
            break;
        }
    }
    
    [deleteView removeFromSuperview];
    isOpen = NO;
}

-(BOOL)isShowing
{
    return isOpen;

}

- (void)showAlertAnimateWithMessage:(NSString *)message btnTitle:(NSString *)btnTitle
{
    
    //-- 添加蒙版
    UIView *translucentView = [[UIView alloc]initWithFrame:self.view.bounds];
    //        translucentView.backgroundColor = XMColor(150, 150, 150);
    translucentView.tag = 14;
    
    [self.view addSubview:translucentView];
    
    
    //-- 添加容器
    UIView *alertView = [UIView new];
    [translucentView addSubview:alertView];
    [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(translucentView);
//        make.size.equalTo(CGSizeMake(269, 163));
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
    [btn setTitle:btnTitle forState:UIControlStateNormal];
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
    messageLabel.text = message;
    messageLabel.font = [UIFont systemFontOfSize:16];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = XMColorFromRGB(0x7F7F7F);
    [alertView addSubview:messageLabel];
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
    
    
    translucentView.transform = CGAffineTransformScale(translucentView.transform, 1.03, 1.03);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        translucentView.transform = CGAffineTransformIdentity;
    });
    
    
    isOpen = YES;
    
    
    
}


- (void)hideHUD
{
    UIView *deleteView = nil;
    for (UIView *view in self.view.subviews)
    {
        if (view.tag == 14)
        {
            deleteView = view;
            break;
        }
    }
    
    [deleteView removeFromSuperview];

}
@end
