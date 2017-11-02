//
//  XMDVR_LocalImageCell.m
//  kuruibao
//
//  Created by x on 16/11/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:
 
        本地图片展示界面，自定义collectionView cell
 
 **********************************************************/

#import "XMDVR_LocalImageCell.h"


@interface XMDVR_LocalImageCell()


 @end
@implementation XMDVR_LocalImageCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc]init];
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *label = [UILabel new];
        
        label.textAlignment = NSTextAlignmentCenter;
        
        label.font = [UIFont systemFontOfSize:11 weight:10];
        
        label.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:label];
        
        [self.contentView addSubview:imageView];
        
        self.imageView = imageView;
        
        self.timeLabel = label;
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self);
        
        make.right.equalTo(self);
        
        make.left.equalTo(self);
        
        make.bottom.equalTo(self).offset(-25);
        
        
    }];


    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self);
        
        make.right.equalTo(self);
        
        make.left.equalTo(self);
        
        make.height.equalTo(25);
        
        
    }];



}


@end
