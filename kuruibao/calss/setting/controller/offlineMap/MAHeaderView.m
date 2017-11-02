//
//  MAHeaderView.m
//  MAMapKit_static_demo
//
//  Created by songjian on 14-4-28.
//  Copyright (c) 2014年 songjian. All rights reserved.
//

#import "MAHeaderView.h"

/* 间距. */
#define MAHeaderViewMargin 5.f

#define rightMargin 15.0f

@interface MAHeaderView ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign, readwrite) BOOL expanded;


@property (nonatomic, strong) UILabel *label;//!< 地区名称显示Label


@property (nonatomic,weak)UIImageView* imageView;//!< 指示箭头

@end

@implementation MAHeaderView


#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame expanded:(BOOL)expanded
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizesSubviews=  YES;
        self.expanded = expanded;
        
        [self setupBackgroundMaskView];
        
        [self creatArrow];//!< 创建箭头
        
        [self setupLabel];
        
        [self setupTapGestureRecognizer];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame expanded:NO];
}


#pragma mark - Interface

- (NSString *)text
{
    return self.label.text;
}

- (void)setText:(NSString *)text
{
    self.label.text = text;
}

#pragma mark - Handle Gesture


/* 响应单击手势. */
- (void)singleTapGesture:(UITapGestureRecognizer *)tap
{
    /* 更新数据. */
    self.expanded = !self.expanded;
    UIImageView *iv = [tap.view viewWithTag:101];
    if (self.expanded)
    {
        XMLOG(@"打开");
        iv.highlighted = YES;
        //!< 将要展开
        [UIView animateWithDuration:0.3 animations:^{
            iv.transform = CGAffineTransformMakeRotation(M_PI / 2);
        }];
        
    }else
    {
        [UIView animateWithDuration:0.3 animations:^{
            iv.transform = CGAffineTransformIdentity;
        }];
        
    }
    
    //!< 通知代理
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(headerView:section:expanded:)])
    {
        [self.delegate headerView:self section:self.section expanded:self.expanded];
    }
}




/* 初始化文本. */
- (void)setupLabel
{
    
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.bounds) - 15, CGRectGetHeight(self.bounds))];
    self.label.backgroundColor  = [UIColor clearColor];
    self.label.textColor        = [UIColor lightGrayColor];
    self.label.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.label];
}

//!< 设置分割线
- (void)setupBackgroundMaskView
{
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(self.bounds) - 0.5f, CGRectGetWidth(self.bounds),0.5f)];
    
    maskView.backgroundColor = XMColorFromRGB(0x7F7F7F);
    maskView.alpha = 0.3;
    [self addSubview:maskView];
}

- (void)setupTapGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
    //    self.singleTapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tap];
}

//!< 创建箭头
- (void)creatArrow
{
    UIImageView *view = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow"]];
    
    view.tag  =101;
    
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(5.5);
        make.height.equalTo(12);
        make.right.equalTo(self).offset(-rightMargin - 10);
        make.centerY.equalTo(self);
    }];
    
}


@end

/*
 
 
 **/
