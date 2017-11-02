
//
//  XMChooseCell.m
//  kuruibao
//
//  Created by x on 16/8/30.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMChooseCell.h"

@implementation XMChooseCell


+ (instancetype)dequeueResuableCellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"chooseCell";
    XMChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[XMChooseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    return cell;

}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *imageView = [UIImageView new];
        UILabel *label = [UILabel new];
        label.textColor = XMColorFromRGB(0x7F7F7F);
        label.font = [UIFont systemFontOfSize:16];
        label.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:label];
        [self.contentView addSubview:imageView];
        self.picture = imageView;
        self.brand = label;
    }
    
    return self;



}

- (void)layoutSubviews
{

    [super layoutSubviews];
    __weak typeof(self) wSelf = self;
    [self.picture mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(wSelf.contentView).offset(25);
        make.centerY.equalTo(wSelf.contentView);
        make.size.equalTo(CGSizeMake(30, 30));
        
    }];
    [self.brand mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(wSelf.picture.mas_right).offset(25);
        make.centerY.equalTo(wSelf.picture);
        make.height.equalTo(15);
        make.width.equalTo(200);
        
    }];






}
@end
