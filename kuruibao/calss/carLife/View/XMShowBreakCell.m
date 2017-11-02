//
//  XMShowBreakCell.m
//  kuruibao
//
//  Created by x on 17/5/13.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMShowBreakCell.h"

@interface XMShowBreakCell ()

@property (weak, nonatomic) UIButton *timeL;//!< 显示时间文字

@property (weak, nonatomic) UIButton *timeContent;//!< 显示时间内容

@property (weak, nonatomic) UIButton *areaL;//!< 显示地点文字

@property (weak, nonatomic) UIButton *areaContent;//!< 显示地点内容

@property (weak, nonatomic) UIButton *actionL;//!< 显示违章条例文字

@property (weak, nonatomic) UIButton *actionContent;//!< 显示违章条例内容

@end

@implementation XMShowBreakCell



- (void)setModel:(XMCarLife_BreakModel *)model
{

    _model = model;
    
    [self.timeContent setTitle: model.date forState:UIControlStateNormal];
    
    [self.areaContent setTitle: model.area forState:UIControlStateNormal];
    
    [self.actionContent setTitle: model.act forState:UIControlStateNormal];
    

}



+ (instancetype)dequeueReuseableCellWith:(UITableView *)tableView
{
    static NSString *identifier = @"XMShowBreakCell";
    
    XMShowBreakCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        
    cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
   
    }
    
    
    return cell;
    
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubviews];
        
        
    }
    
    return self;
    
}

- (void)addSubviews
{
    
    
    //!< 显示违章时间文字
    UIButton *timeL = [self labelWithFont:15 textColor:0xffffff textAlignment:NSTextAlignmentLeft];
    
    [timeL setTitle:@"违章时间" forState:UIControlStateNormal];
 
    
    
    [self.contentView addSubview:timeL];
    
    self.timeL = timeL;
    
    //-----------------------------seperate line---------------------------------------//
   
    
    //!< 显示时间内容
    UIButton *timeContent = [self labelWithFont:15 textColor:0xc5c5c5 textAlignment:NSTextAlignmentLeft];
    
    
    [self.contentView addSubview:timeContent];
    
    self.timeContent = timeContent;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 地点文字
    UIButton *areaL = [self labelWithFont:15 textColor:0xffffff textAlignment:NSTextAlignmentLeft];
    
    
    [areaL setTitle:@"违章地点" forState:UIControlStateNormal];
    
   
    
    [self.contentView addSubview:areaL];
    
    self.areaL = areaL;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 地点内容
    UIButton *areaContent = [self labelWithFont:15 textColor:0xc5c5c5 textAlignment:NSTextAlignmentLeft];
    
    [self.contentView addSubview:areaContent];
    
    self.areaContent = areaContent;
    
    //-----------------------------seperate line---------------------------------------//
    
    
    
    //!< 条例文字
    UIButton *actionL = [self labelWithFont:15 textColor:0xffffff textAlignment:NSTextAlignmentLeft];
    
     [actionL setTitle:@"违章条例" forState:UIControlStateNormal];
    
    
    
    [self.contentView addSubview:actionL];
    
    self.actionL = actionL;
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 条例内容
    UIButton *actionContent = [self labelWithFont:15 textColor:0xc5c5c5 textAlignment:NSTextAlignmentCenter];
    
    [self.contentView addSubview:actionContent];
    
    self.actionContent = actionContent;
    
    //-----------------------------seperate line---------------------------------------//
    
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height1 = [self heightForText:self.model.area];
    
    CGFloat height2 = [self heightForText:self.model.act];
    
    float width = mainSize.width - 49 - 120;
    
    self.timeL.frame = CGRectMake(15, 17, 82.5, 24);
    
    self.timeContent.frame = CGRectMake(98, 17, width, 24);
    
    
    self.areaL.frame = CGRectMake(15, 17 + 24 + 20 , 82.5, 24);
    
    
    self.areaContent.frame = CGRectMake(98, 17+ 24 + 20, width, height1);
    
    
    
    self.actionL.frame = CGRectMake(15, 17 + 24 + 20 + height1 + 20, 82.5, 24);
    
    
    
    self.actionContent.frame = CGRectMake(98, 17 + 24 + 20 + height1 + 20, width, height2);
    
  
    
}


- (float)heightForText:(NSString *)text
{
    
    float width = mainSize.width - 49 - 120;
    
    CGSize titleSize = [text boundingRectWithSize:CGSizeMake(width-16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    
    return titleSize.height + 16;
}

#pragma mark -------------- tool method

//!< 创建label

- (UIButton *)labelWithFont:(float)font textColor:(int )textColor textAlignment:(NSTextAlignment)textAlignment
{
    
    UIButton *btn = [UIButton new];
    
    
    btn.titleLabel.font = [UIFont systemFontOfSize:font];
    
    btn.titleLabel.numberOfLines = 0;
    
    [btn setTitleColor:XMColorFromRGB(textColor) forState:UIControlStateNormal];
    
    btn.userInteractionEnabled = NO;
    
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
     btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    return btn;
    
    
//    UILabel *label = [UILabel new];
//    
////    label.backgroundColor = XMColorFromRGB(textColor);
//    
//    label.textAlignment = textAlignment;
//    
//    label.textColor = XMColorFromRGB(textColor);
//    
////    label.lineBreakMode = NSLineBreakByTruncatingTail;
//    label.numberOfLines = 0;
//    
//    label.font = [UIFont systemFontOfSize:font];
//    
//    return label;
}

- (UIButton *)createLabel:(int)font color:(int)color text:(NSString *)text
{
    UIButton *btn = [UIButton new];
    
    [btn setTitle:text forState:UIControlStateNormal];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:font];
    
    //    label.textColor = XMColorFromRGB(color);
    
    [btn setTitleColor:XMColorFromRGB(color) forState:UIControlStateNormal];
    
    btn.userInteractionEnabled = NO;
    
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    //    btn.backgroundColor = XMRandomColor;
    
    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    //    [label setContentMode:UIViewContentModeTop];
    
    return btn;
    
}

@end
