//
//  UIView+alert.m
//  kuruibao
//
//  Created by x on 16/9/30.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


#import "UIView+alert.h"
#import <objc/runtime.h> //利用运行时机制给分类添加属性
 
@implementation UIView (alert)


static BOOL isOpen;


#pragma mark - address

static char CoverViewKey;//类似于一个中转站,参考

- (void)setCoverView:(UIView *)coverView {
    
    objc_setAssociatedObject(self, &CoverViewKey, coverView, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (UIView*)coverView {
    
    return objc_getAssociatedObject(self, &CoverViewKey);
    
}

- (void)showAlertWithMessage:(NSString *)message btnTitle:(NSString *)btnTitle;
{
    if (isOpen)
    {
        return;
    }
    
    [self endEditing:YES];
    
    //-- 添加蒙版
    UIView *translucentView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //        translucentView.backgroundColor = XMColor(150, 150, 150);
    translucentView.tag = 14;
    
    //!< 添加到主窗口上
    [[UIApplication sharedApplication].keyWindow addSubview:translucentView];
    self.coverView = translucentView;
    
    
    //-- 添加容器
    UIView *alertView = [UIView new];
    [translucentView addSubview:alertView];
    [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(translucentView);
        make.size.equalTo(CGSizeMake((269), (163)));
        
        
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
    messageLabel.adjustsFontSizeToFitWidth = YES;
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        translucentView.transform = CGAffineTransformIdentity;
    });
    
    
    isOpen = YES;
    
    
    
}

- (void)btnClick
{
    
    [self.coverView removeFromSuperview];
    isOpen = NO;
}

-(BOOL)isShowing
{
    return isOpen;
    
}


@end
