//
//  XMMonitorTroubleCell.m
//  kuruibao
//
//  Created by x on 16/12/10.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/**********************************************************
 class description:自定义显示问题项的cell
 
 **********************************************************/



#import "XMMonitorTroubleCell.h"
#import "XMTroubleItemModel.h"

#define codeWidth 40

@interface XMMonitorTroubleCell()

@property (nonatomic,weak)UILabel* dLabel;

@end
@implementation XMMonitorTroubleCell



+(instancetype)dequeueReuseableCellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"XMTroubleItemIdentifier";
    
    XMMonitorTroubleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil)
    {
        cell = [[XMMonitorTroubleCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
        UILabel *label = [UILabel new];
        
        [self.contentView addSubview:label];
        
        self.dLabel = label;
        
        self.textLabel.textColor = [UIColor whiteColor];
        
        self.textLabel.font = [UIFont systemFontOfSize:12];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.dLabel.textColor = [UIColor whiteColor];
        
        self.dLabel.font = [UIFont systemFontOfSize:12];
        
        self.dLabel.numberOfLines = 0;
        
    }
    return self;

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dLabel.frame = CGRectMake(17 + 6 + codeWidth, 5, self.bounds.size.width - 23 - codeWidth - 20, self.bounds.size.height - 10);
    
    self.textLabel.frame = CGRectMake(17, (self.bounds.size.height - 10)/2, codeWidth, 10);
    
    
 

}

- (void)setModel:(XMTroubleItemModel *)model
{
    _model = model;
    
    self.textLabel.text = model.code;
    
    self.dLabel.text = model.codedesc;

}

@end
