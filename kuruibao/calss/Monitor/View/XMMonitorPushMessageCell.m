//
//  XMMontorPushMessageCell.m
//  kuruibao
//
//  Created by x on 16/12/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMMonitorPushMessageCell.h"

@interface XMMonitorPushMessageCell()

@property (nonatomic,weak)UILabel* messageLabel;//!< 显示推送消息

@property (nonatomic,weak)UIView* line;

@end

@implementation XMMonitorPushMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)dequeueReuseableCellWithTableView:(UITableView *)tableView
{
    static NSString * identifier = @"identifier_pushMessage";
    
    XMMonitorPushMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[XMMonitorPushMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;



}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        //!< 添加显示推送消息的Label
        
        UILabel *messageLabel = [UILabel new];
        
        messageLabel.textColor = [UIColor whiteColor];
        
        messageLabel.numberOfLines = 0;
        
        messageLabel.font = [UIFont systemFontOfSize:14];
        
        messageLabel.textAlignment = NSTextAlignmentLeft;
        
        messageLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:messageLabel];
        
        self.messageLabel = messageLabel;
        
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        
        UIView *line = [UIView new];
        
        line.backgroundColor = XMColorFromRGB(0x7F7F7F);
        
        line.alpha = 0.4;
        
        [self.contentView addSubview:line];
        
        self.line = line;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }

    return self;

}

- (void)layoutSubviews
{

    [super layoutSubviews];
    
    self.messageLabel.frame = CGRectMake(10, 15, self.bounds.size.width - 20, self.bounds.size.height - 30);

    self.line.frame = CGRectMake(10, self.bounds.size.height-1, self.bounds.size.width - 20, 1);

}

- (void)setPushMessage:(NSString *)pushMessage
{
    _pushMessage = pushMessage;
    
    _messageLabel.text = pushMessage;



}









@end
