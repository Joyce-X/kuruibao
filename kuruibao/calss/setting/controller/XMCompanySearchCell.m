//
//  XMCompanySearchCell.m
//  kuruibao
//
//  Created by x on 17/5/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCompanySearchCell.h"

@implementation XMCompanySearchCell

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"searchCell";
    
    XMCompanySearchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        
        cell = [[XMCompanySearchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
        
        self.backgroundColor = XMClearColor;
        
        self.textLabel.textColor = XMWhiteColor;
        
        self.textLabel.font = [UIFont systemFontOfSize:14];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_line"]];
        
        imageIV.frame = CGRectMake(0, 43, mainSize.width, 1);
        
        [self.contentView addSubview:imageIV];

    }

    return self;

}


- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    CGRect frame = self.textLabel.frame;
    
    frame.origin.x = 12;
    
    self.textLabel.frame = frame;


}


@end
