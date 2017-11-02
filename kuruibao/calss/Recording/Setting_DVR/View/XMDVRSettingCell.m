//
//  XMDVRSettingCell.m
//  kuruibao
//
//  Created by x on 16/11/8.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMDVRSettingCell.h"

@interface XMDVRSettingCell()

@property (nonatomic,weak)UIView * line;

@end

@implementation XMDVRSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        UIView *line = [UIView new];
        
        line.backgroundColor = XMColorFromRGB(0x7F7F7F);
        
        line.alpha = 0.1;
        
        [self.contentView addSubview:line];
        
        self.line = line;
        
        self.textLabel.textColor = XMColorFromRGB(0x7F7F7F);
        
        self.textLabel.font = [UIFont systemFontOfSize:14];
        
        self.detailTextLabel.textColor = XMGrayColor;
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:13];
    }

    return self;

}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.imageView.bounds = CGRectMake(0,0,44,44);
    self.imageView.frame =CGRectMake(22,12,20,20);
    
    self.imageView.contentMode =UIViewContentModeScaleAspectFit;
    
//    CGRect tmpFrame = self.textLabel.frame;
//    tmpFrame.origin.x = 46;
    self.textLabel.frame = CGRectMake(52, 12, 100, 20);
    
    
    CGFloat height = CGRectGetHeight(self.bounds);
    
    self.line.frame = CGRectMake(0,  height - 1, mainSize.width, 1);
    

}


@end
