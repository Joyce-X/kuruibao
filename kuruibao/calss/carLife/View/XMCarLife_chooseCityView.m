//
//  XMCarLife_chooseCityView.m
//  kuruibao
//
//  Created by x on 17/5/12.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLife_chooseCityView.h"

#import "NSString+extention.h"

#import "XMCarLife_limit_cityModel.h"

@interface XMCarLife_chooseCityView ()

@property (weak, nonatomic,readwrite) UILabel *cityLabel;//!< show location city

@property (weak, nonatomic) UIScrollView *scrollView;

@end

@implementation XMCarLife_chooseCityView



- (instancetype)init
{

    self = [super init];
    
    if (self)
    {
        [self setSubviews];
    }

    return self;

}


- (void)setSubviews
{
    
    self.transform = CGAffineTransformMakeScale(0, 0);
    
    //!< corner and back color
    self.layer.cornerRadius = 3;
    
    self.clipsToBounds = YES;
    
    self.backgroundColor = XMColorFromRGB(0x3a3940);
    
    //!< city label
    UILabel *label = [UILabel new];
    
    label.textColor = [UIColor whiteColor];
    
    label.text = @"当前城市:";
    
    label.font = [UIFont systemFontOfSize:18];
    
    [self addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self).offset(15);
        
        make.top.equalTo(self).offset(22);
        
        make.size.equalTo(CGSizeMake(150, 17));
        
        
    }];
    
    //!< refresh button
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [refreshBtn setImage:[UIImage imageNamed:@"carLife_limit_refresh"] forState:UIControlStateNormal];
    
    [refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:refreshBtn];
    
    [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self).offset(15);
        
        make.right.equalTo(self).offset(-11);
        
        make.size.equalTo(CGSizeMake(30, 30));
        
    }];
    
    //!< location city label
    UILabel *cityLabel = [UILabel new];
    
    cityLabel.layer.borderColor = XMColorFromRGB(0x7470e9).CGColor;
    
    cityLabel.layer.borderWidth = 1;
    
    cityLabel.backgroundColor = XMColorFromRGB(0x56555b);
    
    cityLabel.font = [UIFont systemFontOfSize:15];
    
    cityLabel.textAlignment = NSTextAlignmentCenter;
    
    cityLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:cityLabel];
    
    self.cityLabel = cityLabel;
    
    [cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self).offset(15);
        
        make.top.equalTo(label.mas_bottom).offset(20);
        
        make.size.equalTo(CGSizeMake(67, 34));
        
        
    }];
    
    //!< image
    UIImageView *locationIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_limit_location"]];
    
    [self addSubview:locationIV];
    
    [locationIV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(cityLabel.mas_right).offset(10);
        
        make.centerY.equalTo(cityLabel);
        
        make.size.equalTo(CGSizeMake(18, 23));
        
    }];
    
    //!< line
    UIView *line = [UIView new];
    
    line.backgroundColor = XMColorFromRGB(0x535353);
    
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(cityLabel.mas_bottom).offset(20);
        
        make.left.equalTo(self).offset(15);
        
        make.right.equalTo(self).offset(-15);
        
        make.height.equalTo(0.5);
        
    }];
    
    
    //!< other city
    UILabel *otherCity = [UILabel new];
    
    otherCity.textColor = [UIColor whiteColor];
    
    otherCity.font = [UIFont systemFontOfSize:18];
    
    otherCity.text = @"支持城市";
    
    [self addSubview:otherCity];
    
    [otherCity mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(cityLabel);
        
        make.top.equalTo(line).offset(25);
        
        make.size.equalTo(CGSizeMake(150, 17));
        
        
    }];
    
    //!< scroll
    UIScrollView *scrollView = [UIScrollView new];
    
    scrollView.showsHorizontalScrollIndicator = NO;
    
    scrollView.showsVerticalScrollIndicator = NO;
    
//    scrollView.bounces = NO;
    
    [self addSubview:scrollView];
    
    self.scrollView = scrollView;
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self).offset(15);
        
        make.right.equalTo(self).offset(-15);
        
        make.top.equalTo(otherCity.mas_bottom).offset(20);
        
        make.bottom.equalTo(self).offset(-22);
        
        
    }];
    
    
}


#pragma mark ------- setter

- (void)setCitys:(NSArray *)citys
{
    _citys = citys;
    
    CGFloat height;
    
    NSInteger rows = citys.count / 3;
    
    CGFloat width = mainSize.width - 90 - 30 - 40;
    
    width/=3.0;
    
    
    //!< 计算总高度
    int left = citys.count % 3;
    
    if (left == 0)
    {
        height = 34 * rows + 20 *(rows - 1);
    }else
    {
        height = 34 * (rows + 1) + 20 *(rows);

    
    }

    _scrollView.contentSize = CGSizeMake(0, height);
    
    for (int i = 0; i<citys.count; i++)
    {
        XMCarLife_limit_cityModel *model = citys[i];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn.layer.borderColor = XMColorFromRGB(0x7f7f7f).CGColor;
        
        btn.layer.borderWidth = 1;
        
        btn.clipsToBounds = YES;
        
        btn.layer.cornerRadius = 3;
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [btn setTitle:model.cityname forState:UIControlStateNormal];
        
        btn.tag = i;
        
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [_scrollView addSubview:btn];
        
        int row = i/3;//!< 行
        
        int column = i % 3;//!< 列
        
//         FITWIDTH(67)
        btn.frame = CGRectMake((width + 20) * column, 54 * row, width, 34);
        
//        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//           
//            make.left.equalTo()
//            
//            make.height.equalTo(34);
//            
//            make.width.equalTo(self).multipliedBy(0.333);
//            
//            make.top.equalTo
//            
//        }];
        
        [btn addTarget:self action:@selector(cityBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    

}

- (void)setLocationCity:(NSString *)city
{

    self.cityLabel.text = city;
    
   float width = [city getWidthWith:15];

    if (width > 67)
    {
        [_cityLabel updateConstraints:^(MASConstraintMaker *make) {
           
            make.width.equalTo(width);
            
        }];
    }


}

#pragma mark ------- btn click

- (void)refreshBtnClick
{
    XMLOG(@" click refresh");
    
    if (self.delegate  && [self.delegate respondsToSelector:@selector(XMCarLife_chooseCityViewRefreshLocationDidClick:)])
    {
    
        [self.delegate XMCarLife_chooseCityViewRefreshLocationDidClick:self];
    
    }
    
    
  
    
}

- (void)cityBtnClick:(UIButton *)sender
{
    
    XMCarLife_limit_cityModel *model = self.citys[sender.tag];
    
    if (self.delegate  && [self.delegate respondsToSelector:@selector(XMCarLife_chooseCityViewDidSelectedCity:)])
    {
        
        [self.delegate XMCarLife_chooseCityViewDidSelectedCity:model];
        
    }
      [self removeFromSuperview];
    
}



@end
