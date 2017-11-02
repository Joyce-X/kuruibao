//
//  XMDVR_LocalImage_collectionRuseView.m
//  kuruibao
//
//  Created by x on 16/11/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:
 
        本地图片展示时候，collectionView 的分区头不是图自定义且重用
 
 **********************************************************/

#import "XMDVR_LocalImage_collectionRuseView.h"


@interface XMDVR_LocalImage_collectionRuseView()

@property (nonatomic,weak)UILabel* time_titleLabel;

@end

@implementation XMDVR_LocalImage_collectionRuseView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *label = [UILabel new ];
        
        label.textColor = [UIColor grayColor];
        
        label.font = [UIFont systemFontOfSize:13 weight:90];
        
        [self addSubview:label];
        
        self.time_titleLabel = label;
        
        self.backgroundColor = XMWhiteColor;
        
    }
    return self;
}


- (void)setTime_title:(NSString *)time_title
{
    _time_title = time_title;
    
    self.time_titleLabel.text = time_title;



}

- (void)layoutSubviews
{

    [super layoutSubviews];
    
    [self.time_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(self);
        
        make.height.equalTo(self);
        
        make.left.equalTo(self).offset(20);
        
        make.width.equalTo(120);
        
    }];



}
@end
