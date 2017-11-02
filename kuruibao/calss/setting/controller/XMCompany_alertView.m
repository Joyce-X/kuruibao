//
//  XMCompany_alertView.m
//  kuruibao
//
//  Created by x on 17/5/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
 企业账号登录的时候，在车辆列表下的搜索界面点击清空历史记录展示的自定义视图
 
 ************************************************************************************************/
#import "XMCompany_alertView.h"


@interface XMCompany_alertView ()



@end

@implementation XMCompany_alertView


+(instancetype)alertView
{

    return [[self alloc] init];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        //!< 创建子视图
        [self setupSubviews];
    }

    return self;

}

- (void)setupSubviews
{
    self.frame = CGRectMake(0, 0, mainSize.width, mainSize.height);
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake((mainSize.width - FITWIDTH(269))/2, (mainSize.height - FITHEIGHT(163))/2, 269, 163)];
    
    [self addSubview:contentView];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"company_back"]];
    
    [contentView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.edges.equalTo(contentView);
        
    }];
    
    
    //!< 添加文字
    UILabel *label = [UILabel new];
    
    label.font = [UIFont systemFontOfSize:18];
    
    label.textColor = XMWhiteColor;
    
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = @"确定清空历史搜索?";
    
    [contentView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.top.right.equalTo(contentView);
        
        make.bottom.equalTo(contentView).offset(-FITHEIGHT(40));
        
    }];
    
    UIView *line = [UIView new];
    
    line.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
    [label addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.equalTo(label);
        
        make.height.equalTo(1);
        
    }];
    
    UIView *line2 = [UIView new];
    
    line2.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
    [contentView addSubview:line2];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        
        make.bottom.equalTo(contentView);
        
        make.top.equalTo(line);
        
        make.width.equalTo(1);
        
        make.centerX.equalTo(line);
        
        
    }];
    
    
    //!< 添加按钮
    UIButton *certainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [certainBtn setTitle:@"是" forState:UIControlStateNormal];
    
    certainBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    [certainBtn setTitleColor:XMWhiteColor forState:UIControlStateNormal];
    
    [certainBtn setBackgroundImage:[self imageWithColor:XMColorFromRGB(0x6f6f6f)] forState:UIControlStateHighlighted];
    
    [certainBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    certainBtn.tag = 1;
    
    [certainBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:certainBtn];
    
    [certainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.bottom.equalTo(contentView);
        
        make.right.equalTo(contentView.mas_centerX).offset(-0.5);
        
        make.height.equalTo(FITHEIGHT(40));
        
    }];
    
    //!< 添加按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cancelBtn setTitle:@"否" forState:UIControlStateNormal];
    
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    [cancelBtn setTitleColor:XMWhiteColor forState:UIControlStateNormal];
    
    [cancelBtn setBackgroundImage:[self imageWithColor:XMColorFromRGB(0x6f6f6f)] forState:UIControlStateHighlighted];
    
    [cancelBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    cancelBtn.tag = 2;
    
    [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:cancelBtn];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.bottom.equalTo(contentView);
        
        make.left.equalTo(contentView.mas_centerX).offset(0.5);
        
        make.height.equalTo(FITHEIGHT(40));
        
    }];
    
}

- (void)btnClick:(UIButton *)sender
{
    
        //!< 点击否按钮，移除当前视图
        [self removeFromSuperview];
        
         //!< 点击是，执行block，清空历史记录
        
    if (sender.tag == 1)
    {
        if (self.clearBlock)
        {
            self.clearBlock();
        }
    }
    
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

        XMLOG(@"---------点击按钮以外的区域---------");
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f); //宽高 1.0只要有值就够了
    UIGraphicsBeginImageContext(rect.size); //在这个范围内开启一段上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);//在这段上下文中获取到颜色UIColor
    CGContextFillRect(context, rect);//用这个颜色填充这个上下文
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
    UIGraphicsEndImageContext();
    
    return image;
}

@end
