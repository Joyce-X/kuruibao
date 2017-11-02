//
//  XMScrollView.m
//  kuruibao
//
//  Created by x on 17/5/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 
 用于体检主界面底部，轮播自定义视图
 
 ************************************************************************************************/
#import "XMScrollView.h"


#define kScrollMinSpeed 1 //最小间隔

#define kScrollMaxSpeed 10 //最大间隔

#define kScrollTimeinterval 0.05 //定时器时间间隔

#define margin 5

#define bottomMargin (-8)

@interface XMScrollView ()<UIScrollViewDelegate>
{
    
    NSDate *firstDate;

}

/**
 定时器
 */
@property (strong, nonatomic) CADisplayLink *disPlay;

/**
 滚动视图
 */
@property (weak, nonatomic) UIScrollView *scroll;

/**
 轮播速度
 */
@property (assign, nonatomic) CGFloat speed;

/**
 总里程
 */
@property (weak, nonatomic) UILabel *icon_totalDistance;

/**
 总油耗
 */
@property (weak, nonatomic) UILabel *icon_totalCons;

/**
 最大速度
 */
@property (weak, nonatomic) UILabel *icon_maxSpeed;

/**
 平均油耗
 */
@property (weak, nonatomic) UILabel *icon_average;

/**
 开始时间
 */
@property (weak, nonatomic) UILabel *icon_start;

/**
 结束时间
 */
@property (weak, nonatomic) UILabel *icon_end;

@property (weak, nonatomic) UILabel *icon_percentage;

/**
 电压
 */
@property (weak, nonatomic) UILabel *icon_voltage;

/**
 水温
 */
@property (weak, nonatomic) UILabel *icon_water;

/**
 是否正在动画
 */
@property (assign, readwrite,nonatomic) BOOL isAnimating;

@end


@implementation XMScrollView


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self setupSubviews];
    }
    
    return self;
    
}
- (void)setupSubviews
{
    
    
    
    //!< 设置默认速度
    self.speed = kScrollMinSpeed;
    
    self.isAnimating = NO;
    
    //!< scroll
    CGFloat width = FITWIDTH(72) * 2 + FITWIDTH(120) * 8 + mainSize.width * 2 + 20;
    
    UIScrollView *scroll = [UIScrollView new];
    
    scroll.delegate = self;
    
    scroll.contentSize = CGSizeMake(width, 0);
    
    scroll.showsHorizontalScrollIndicator = NO;

    scroll.scrollEnabled = NO;
    
    scroll.bounces = NO;
    
    scroll.clipsToBounds = NO;
    
    [self addSubview:scroll];
    
    self.scroll = scroll;
    
    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.right.bottom.equalTo(self);
        
    }];
    
    
    
    UIView *centerView0 = [UIView new];
    
    [scroll addSubview:centerView0];
    
    [centerView0 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.equalTo(scroll);
        
        make.height.equalTo(scroll).multipliedBy(0.333333333);
        
        make.width.equalTo(width);
        
    }];
    
    UIView *centerView = [UIView new];
    
    [scroll addSubview:centerView];
    
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(scroll);
        
        make.height.equalTo(scroll).multipliedBy(0.333333);
        
        make.top.equalTo(centerView0.mas_bottom);
        
        make.width.equalTo(width);
        
    }];
    
    UIView *centerView2 = [UIView new];
    
    [scroll addSubview:centerView2];
    
    [centerView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(scroll);
        
        make.height.equalTo(scroll).multipliedBy(0.3333333);
        
        make.width.equalTo(width);
        
        make.top.equalTo(centerView.mas_bottom);
        
    }];
    
    
    //!< 添加线条
    UIView *line1 = [UIView new];
    
    line1.backgroundColor = XMGrayColor;
    
    line1.alpha = 0.3;
    
    [centerView0 addSubview:line1];
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.equalTo(centerView0);
        
        
        make.size.equalTo(CGSizeMake(width, 1));
        
    }];
    
    
    
   
    
    UIView *line4 = [UIView new];
    
     line4.alpha = 0.3;
    
    line4.backgroundColor = XMGrayColor;
    
    [centerView2 addSubview:line4];
    
    [line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.bottom.equalTo(centerView2);
        
        make.size.equalTo(CGSizeMake(width, 1));
        
        
        
    }];
    
    
   
    
    UIView *line2 = [UIView new];
    
     line2.alpha = 0.3;
    
    line2.backgroundColor = XMGrayColor;
    
    [centerView addSubview:line2];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.equalTo(centerView);
        
        make.size.equalTo(CGSizeMake(width, 1));
        
        
    }];
    
    UIView *line3 = [UIView new];
    
     line3.alpha = 0.3;
    
    line3.backgroundColor = XMGrayColor;
    
    [centerView addSubview:line3];
    
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.left.right.equalTo(centerView);
        
        make.size.equalTo(CGSizeMake(width, 1));
        
    }];
    
    
    //!< 添加线条
    UIView *columnLine1 = [UIView new];
    
    columnLine1.backgroundColor = XMGreenColor;
    
    [scroll addSubview:columnLine1];
    
    [columnLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line1).offset(-margin);
        
        make.bottom.equalTo(line4).offset(margin);
        
        make.left.equalTo(scroll).offset(FITWIDTH(72) + mainSize.width);
        
        make.width.equalTo(1);
        
    }];
    
    UIView *columnLine2 = [UIView new];
    
    columnLine2.backgroundColor = XMGreenColor;
    
    [scroll addSubview:columnLine2];
    
    [columnLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line2).offset(-margin);
        
        make.bottom.equalTo(line4).offset(margin);
        
        make.left.equalTo(scroll).offset(FITWIDTH(72) + FITWIDTH(120) * 1 + mainSize.width);
        
        make.width.equalTo(1);
        
    }];
    
    
    UIView *columnLine3 = [UIView new];
    
    columnLine3.backgroundColor = XMGreenColor;
    
    [scroll addSubview:columnLine3];
    
    [columnLine3 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line3).offset(-margin);
        
        make.bottom.equalTo(line4).offset(margin);
        
        make.left.equalTo(scroll).offset(FITWIDTH(72) + FITWIDTH(120) * 2 + mainSize.width);
        
        make.width.equalTo(1);
        
    }];
    
    
    UIView *columnLine4 = [UIView new];
    
    columnLine4.backgroundColor = XMGreenColor;
    
    [scroll addSubview:columnLine4];
    
    [columnLine4 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line1).offset(-margin);
        
        make.bottom.equalTo(line4).offset(margin);
        
        make.left.equalTo(scroll).offset(FITWIDTH(72)  + FITWIDTH(120) * 3 + mainSize.width);
        
        make.width.equalTo(1);
        
    }];
    
    
    UIView *columnLine5 = [UIView new];
    
    columnLine5.backgroundColor = XMGreenColor;
    
    [scroll addSubview:columnLine5];
    
    [columnLine5 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line2).offset(-margin);
        
        make.bottom.equalTo(line4).offset(margin);
        
        make.left.equalTo(scroll).offset(FITWIDTH(72)  + FITWIDTH(120) * 4 + mainSize.width);
        
        make.width.equalTo(1);
        
    }];
    
    
    UIView *columnLine6 = [UIView new];
    
    columnLine6.backgroundColor = XMGreenColor;
    
    [scroll addSubview:columnLine6];
    
    [columnLine6 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line3).offset(-margin);
        
        make.bottom.equalTo(line4).offset(margin);
        
        make.left.equalTo(scroll).offset(FITWIDTH(72) + FITWIDTH(120) * 5 + mainSize.width);
        
        make.width.equalTo(1);
        
    }];
    
    
    UIView *columnLine7 = [UIView new];
    
    columnLine7.backgroundColor = XMGreenColor;
    
    [scroll addSubview:columnLine7];
    
    [columnLine7 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line1).offset(-margin);
        
        make.bottom.equalTo(line4).offset(margin);
        
        make.left.equalTo(scroll).offset(FITWIDTH(72)  + FITWIDTH(120) * 6 + mainSize.width);
        
        make.width.equalTo(1);
        
    }];
    
    
    
    UIView *columnLine8 = [UIView new];
    
    columnLine8.backgroundColor = XMGreenColor;
    
    [scroll addSubview:columnLine8];
    
    [columnLine8 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line2).offset(-margin);
        
        make.bottom.equalTo(line4).offset(margin);
        
        make.left.equalTo(scroll).offset(FITWIDTH(72) + FITWIDTH(120) * 7 + mainSize.width);
        
        make.width.equalTo(1);
        
    }];
    
    
    UIView *columnLine9 = [UIView new];
    
    columnLine9.backgroundColor = XMGreenColor;
    
    [scroll addSubview:columnLine9];
    
    [columnLine9 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line3).offset(-margin);
        
        make.bottom.equalTo(line4).offset(margin);
        
        make.left.equalTo(scroll).offset(FITWIDTH(72) + FITWIDTH(120) * 8 + mainSize.width);
        
        make.width.equalTo(1);
        
    }];
    
    //!< 1 添加总里程
    UIImageView *iv1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_totalDistance"]];
    
    [centerView0 addSubview:iv1];
    
    [iv1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(23, 23));
        
        make.right.equalTo(columnLine4.mas_left).offset(-5);
        
        make.centerY.equalTo(centerView0);
        
    }];
    
    UILabel *label1 = [UILabel new];
    
    label1.text = @"总里程";
    
    label1.font = [UIFont systemFontOfSize:12];
    
    label1.textColor = XMWhiteColor;
    
    [centerView0 addSubview:label1];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine4).offset(5);
        
        make.top.equalTo(line1).offset(4);
        
        
        
    }];
    
    UILabel *totalDistance = [UILabel new];
    
    totalDistance.font = [UIFont systemFontOfSize:12];
    
    totalDistance.text = @"0Km";
    
    totalDistance.textColor = XMWhiteColor;
    
    [centerView0 addSubview:totalDistance];
    
    self.icon_totalDistance = totalDistance;
    
    [totalDistance mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine4).offset(5);
        
        make.bottom.equalTo(line2).offset(bottomMargin);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 2 添加总油耗
    UIImageView *iv2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_totalCons"]];
    
    [centerView addSubview:iv2];
    
    [iv2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(23, 23));
        
        make.right.equalTo(columnLine5.mas_left).offset(-5);
        
        make.centerY.equalTo(centerView);
        
    }];
    
    UILabel *label2 = [UILabel new];
    
    label2.text = @"总油耗";
    
    label2.font = [UIFont systemFontOfSize:12];
    
    label2.textColor = XMWhiteColor;
    
    [centerView addSubview:label2];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine5).offset(5);
        
        make.top.equalTo(line2).offset(4);
        
        
        
    }];
    
    UILabel *icon_totalCons = [UILabel new];
    
    icon_totalCons.font = [UIFont systemFontOfSize:12];
    
    icon_totalCons.textColor = XMWhiteColor;
    
    icon_totalCons.text = @"0L";
    
    [centerView addSubview:icon_totalCons];
    
    self.icon_totalCons = icon_totalCons;
    
    [icon_totalCons mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine5).offset(5);
        
        make.bottom.equalTo(line3).offset(bottomMargin);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 3 添加最高速度
    UIImageView *iv3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_maxSpeed"]];
    
    [centerView2 addSubview:iv3];
    
    [iv3 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(24, 22));
        
        make.right.equalTo(columnLine6.mas_left).offset(-5);
        
        make.centerY.equalTo(centerView2);
        
    }];
    
    UILabel *label3 = [UILabel new];
    
    label3.text = @"最高时速";
    
    label3.font = [UIFont systemFontOfSize:12];
    
    label3.textColor = XMWhiteColor;
    
    [centerView2 addSubview:label3];
    
    [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine6).offset(5);
        
        make.top.equalTo(line3).offset(4);
        
        
        
    }];
    
    UILabel *icon_maxSpeed = [UILabel new];
    
    icon_maxSpeed.font = [UIFont systemFontOfSize:12];
    
    icon_maxSpeed.textColor = XMWhiteColor;
    
    icon_maxSpeed.text = @"0Km/h";
    
    [centerView2 addSubview:icon_maxSpeed];
    
    self.icon_maxSpeed = icon_maxSpeed;
    
    [icon_maxSpeed mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine6).offset(5);
        
        make.bottom.equalTo(line4).offset(bottomMargin);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 4 添加平均时速
    UIImageView *iv4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_average"]];
    
    [centerView0 addSubview:iv4];
    
    [iv4 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(23, 23));
        
        make.right.equalTo(columnLine7.mas_left).offset(-5);
        
        make.centerY.equalTo(centerView0);
        
    }];
    
    UILabel *label4 = [UILabel new];
    
    label4.text = @"平均时速";
    
    label4.font = [UIFont systemFontOfSize:12];
    
    label4.textColor = XMWhiteColor;
    
    [centerView0 addSubview:label4];
    
    [label4 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine7).offset(5);
        
        make.top.equalTo(line1).offset(4);
        
        
        
    }];
    
    UILabel *icon_average = [UILabel new];
    
    icon_average.font = [UIFont systemFontOfSize:12];
    
    icon_average.textColor = XMWhiteColor;
    
    icon_average.text = @"0Km/h";
    
    [centerView0 addSubview:icon_average];
    
    self.icon_average = icon_average;
    
    [icon_average mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine7).offset(5);
        
        make.bottom.equalTo(line2).offset(bottomMargin);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 5 开始时间
    UIImageView *iv5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_start"]];
    
    [centerView addSubview:iv5];
    
    [iv5 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(23, 23));
        
        make.right.equalTo(columnLine8.mas_left).offset(-5);
        
        make.centerY.equalTo(centerView);
        
    }];
    
    UILabel *label5 = [UILabel new];
    
    label5.text = @"行程开始时间";
    
    label5.font = [UIFont systemFontOfSize:12];
    
    label5.textColor = XMWhiteColor;
    
    [centerView addSubview:label5];
    
    [label5 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine8).offset(5);
        
        make.top.equalTo(line2).offset(4);
        
        
        
    }];
    
    UILabel *icon_start = [UILabel new];
    
    icon_start.font = [UIFont systemFontOfSize:12];
    
    icon_start.textColor = XMWhiteColor;
    
    icon_start.text = @"---";
    
    [centerView addSubview:icon_start];
    
    self.icon_start = icon_start;
    
    [icon_start mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine8).offset(5);
        
        make.bottom.equalTo(line3).offset(bottomMargin);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 6 结束时间
    UIImageView *iv6 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_end"]];
    
    [centerView2 addSubview:iv6];
    
    [iv6 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(23, 23));
        
        make.right.equalTo(columnLine9.mas_left).offset(-5);
        
        make.centerY.equalTo(centerView2);
        
    }];
    
    UILabel *label6 = [UILabel new];
    
    label6.text = @"行程结束时间";
    
    label6.font = [UIFont systemFontOfSize:12];
    
    label6.textColor = XMWhiteColor;
    
    [centerView2 addSubview:label6];
    
    [label6 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine9).offset(5);
        
        make.top.equalTo(line3).offset(4);
        
        
        
    }];
    
    UILabel *icon_end = [UILabel new];
    
    icon_end.font = [UIFont systemFontOfSize:12];
    
    icon_end.textColor = XMWhiteColor;
    
    [centerView2 addSubview:icon_end];
    
    icon_end.text = @"---";
    
    self.icon_end = icon_end;
    
    [icon_end mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine9).offset(5);
        
        make.bottom.equalTo(line4).offset(bottomMargin);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< -2 百公里油耗
    UIImageView *iv_02 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_percentage"]];
    
//    iv_02.backgroundColor = XMRandomColor;
    
    [centerView0 addSubview:iv_02];
    
    [iv_02 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(19, 23));
        
        make.right.equalTo(columnLine1.mas_left).offset(-5);
        
        make.centerY.equalTo(centerView0);
        
    }];
    
    UILabel *label_02 = [UILabel new];
    
    label_02.text = @"百公里油耗";
    
    label_02.font = [UIFont systemFontOfSize:12];
    
    label_02.textColor = XMWhiteColor;
    
    [centerView0 addSubview:label_02];
    
    [label_02 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine1).offset(5);
        
        make.top.equalTo(line1).offset(4);
        
        
        
    }];
    
    UILabel *icon_percentage = [UILabel new];
    
    icon_percentage.font = [UIFont systemFontOfSize:12];
    
    icon_percentage.textColor = XMWhiteColor;
    
    [centerView0 addSubview:icon_percentage];
    
    icon_percentage.text = @"0L";
    
    self.icon_percentage = icon_percentage;
    
    [icon_percentage mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine1).offset(5);
        
        make.bottom.equalTo(line2).offset(bottomMargin);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< -1 电瓶电压
    UIImageView *iv_01 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_voltage"]];
    
    [centerView addSubview:iv_01];
    
    [iv_01 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(20, 22.5));
        
        make.right.equalTo(columnLine2.mas_left).offset(-5);
        
        make.centerY.equalTo(centerView);
        
    }];
    
    UILabel *label_01 = [UILabel new];
    
    label_01.text = @"电瓶电压";
    
    label_01.font = [UIFont systemFontOfSize:12];
    
    label_01.textColor = XMWhiteColor;
    
    [centerView addSubview:label_01];
    
    [label_01 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine2).offset(5);
        
        make.top.equalTo(line2).offset(4);
        
        
        
    }];
    
    UILabel *icon_voltage = [UILabel new];
    
    icon_voltage.font = [UIFont systemFontOfSize:12];
    
    icon_voltage.textColor = XMWhiteColor;
    
    [centerView addSubview:icon_voltage];
    
    icon_voltage.text = @"0V";
    
    self.icon_voltage = icon_voltage;
    
    [icon_voltage mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine2).offset(5);
        
        make.bottom.equalTo(line3).offset(bottomMargin);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 0 添加水温
    UIImageView *iv_0 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_water"]];
    
    [centerView2 addSubview:iv_0];
    
    [iv_0 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(34, 23));
        
        make.right.equalTo(columnLine3.mas_left).offset(-5);
        
        make.centerY.equalTo(centerView2);
        
    }];
    
    UILabel *label_0 = [UILabel new];
    
    label_0.text = @"水箱水温";
    
    label_0.font = [UIFont systemFontOfSize:12];
    
    label_0.textColor = XMWhiteColor;
    
    [centerView2 addSubview:label_0];
    
    [label_0 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine3).offset(5);
        
        make.top.equalTo(line3).offset(4);
        
        
        
    }];
    
    UILabel *icon_water = [UILabel new];
    
    icon_water.font = [UIFont systemFontOfSize:12];
    
    icon_water.textColor = XMWhiteColor;
    
    [centerView2 addSubview:icon_water];
    
    icon_water.text = @"0°C";
    
    self.icon_water = icon_water;
    
    [icon_water mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(120), 9));
        
        make.left.equalTo(columnLine3).offset(5);
        
        make.bottom.equalTo(line4).offset(bottomMargin);
        
    }];
    
    [scroll setContentOffset:CGPointMake(mainSize.width, 0)];
    
//    [self move];
    
    
    
}

/**
 开始动画
 */
- (void)move
{
    
    //!< 销毁定时器
    if (self.disPlay)
    {
        [self.disPlay invalidate];
        
        self.disPlay = nil;
    }
      self.scroll.scrollEnabled = YES;
    
    //!< 复位
    [self.scroll setContentOffset:CGPointZero animated:NO];
    
    self.disPlay = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeOffset)];
    
    [_disPlay addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void)changeOffset
{
    CGFloat offset = self.scroll.contentOffset.x;
    
    offset += self.speed;
    
    [self.scroll setContentOffset:CGPointMake(offset, 0) animated:NO];
    
    if (self.scroll.contentOffset.x > (FITWIDTH(72) * 2 + FITWIDTH(120) * 8  + mainSize.width + 10))
    {
        [self.scroll setContentOffset:CGPointMake(0, 0)];
    }
    
    self.isAnimating = YES;
    
}


/**
 停止动画
 */
- (void)stop
{
    
    self.isAnimating = NO;
    
    [self.disPlay invalidate];
    
    self.disPlay = nil;
    
    [self.scroll setContentOffset:CGPointMake(mainSize.width, 0) animated:NO];
    
    self.icon_percentage.text = @"0L";
    
    self.icon_voltage.text = @"0V";
    
    self.icon_water.text = @"0°C";
    
    self.icon_totalDistance.text = @"0Km";
    
    self.icon_totalCons.text = @"0L";
    
    self.icon_maxSpeed.text = @"0Km/h";
    
    self.icon_average.text = @"0Km/h";
    
    self.icon_start.text = @"---";
    
    self.icon_end.text = @"---";
    
    self.scroll.scrollEnabled = NO;
    
    
    
}


- (void)clearData
{
    self.icon_percentage.text =  @"--L";
    
    self.icon_voltage.text =@"--V";
    
    self.icon_water.text = @"--°C";
    
    self.icon_totalDistance.text = @"--Km";
    
    self.icon_totalCons.text = @"--L";
    
    self.icon_maxSpeed.text = @"--Km/h";
    
    self.icon_average.text =@"--Km/h";
    
    self.icon_start.text = @"---";
    
    self.icon_end.text = @"---";
    

}



/**
 设置各项参数
 */
- (void)setParas:(NSDictionary *)dic
{
    
    
    NSString *percentageOil = dic[@"oXC"][@"avgyouhao"];
    
    NSString *voltage = dic[@"oCK"][@"parm1101"];
    
    NSString *water = dic[@"oCK"][@"parm0004"];
    
    NSString *totalDistance = dic[@"oXC"][@"licheng"];
    
     NSString *totalOil = dic[@"oXC"][@"penyou"];
    
     NSString *maxSpeed = dic[@"oXC"][@"maxspeed"];
    
     NSString *aveSpeed = dic[@"oXC"][@"avgspeed"];
    
     NSString *startTime = dic[@"oXC"][@"startHHmmSS"];
    
     NSString *endTime = @"未结束";
    
    self.icon_percentage.text = [percentageOil stringByAppendingString:@"L"];
    
    self.icon_voltage.text = [voltage stringByAppendingString:@"V"];
    
    self.icon_water.text = [water stringByAppendingString:@"°C"];;
    
    self.icon_totalDistance.text = [totalDistance stringByAppendingString:@"Km"];
    
    self.icon_totalCons.text = [totalOil stringByAppendingString:@"L"];
    
    self.icon_maxSpeed.text = [maxSpeed stringByAppendingString:@"Km/h"];
    
    self.icon_average.text = [aveSpeed stringByAppendingString:@"Km/h"];
    
    self.icon_start.text = startTime;
    
    self.icon_end.text = endTime;
    
    
    
}


/**
 设置滚动速率
 
 @param rate 速度
 */
- (void)setAnimatRate:(CGFloat)rate
{
    
    //!< 设置默认最小速度和最大速度
    if(rate < kScrollMinSpeed)
    {
        self.speed = kScrollMinSpeed;
        
    }else if(rate > kScrollMaxSpeed)
    {
        
        self.speed = kScrollMaxSpeed;
        
    }else
    {
        
        self.speed = rate;
        
    }
    
}

- (void)setCanScrool:(BOOL)canScrool
{
    
    _canScrool = canScrool;
    
    self.scroll.scrollEnabled = canScrool;


}

#pragma mark ------- scrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

    firstDate = [NSDate date];
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{

    double timeInterval = [[NSDate date] timeIntervalSinceDate:firstDate];
    
    NSString *value = [NSString stringWithFormat:@"%fs",timeInterval];
    
    [MobClick event:@"Slide_RealtimeData" attributes:@{@"time":value}];
    
    XMLOG(@"---------youmeng 时间 %@---------",value);
    

}

@end
