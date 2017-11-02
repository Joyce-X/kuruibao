//
//  XMMapListCell.m
//  kuruibao
//
//  Created by x on 16/11/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMMapListCell.h"

 
@interface XMMapListCell()

@property (nonatomic,weak)UILabel* nameLabel;//!< 名称

@property (nonatomic,weak)UILabel* addressLabel;//!< 地址

@property (nonatomic,weak)UILabel *distanceLabel;//!< 距离

@property (nonatomic,weak)UIButton* naviBtn;//!< 导航按钮

@end

@implementation XMMapListCell



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (instancetype)dequeueReuseableCellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"resuableCell";
    
    XMMapListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[XMMapListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UIView *view = [UIView new];
        
        view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.6 alpha:0.2];
        
         cell.selectedBackgroundView = view;
    }
    
    return cell;
    
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        //->>
        UILabel *nameLabel = [UILabel new];
        
        nameLabel.font = [UIFont systemFontOfSize:16];
        
        nameLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:nameLabel];
        
        self.nameLabel = nameLabel;
        
        //-----------------------------seperate line---------------------------------------//
        
        UILabel *addressLabel = [UILabel new];
        
        addressLabel.font = [UIFont systemFontOfSize:13];
        
        addressLabel.textColor = XMGrayColor;
        
        [self.contentView addSubview:addressLabel];
        
        self.addressLabel = addressLabel;
        
        //-----------------------------seperate line---------------------------------------//
        
        UIButton *naviBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [naviBtn setTitle:@"导航" forState:UIControlStateNormal];
        
        naviBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [naviBtn addTarget:self action:@selector(naviBtnDidClick:event:)   forControlEvents:UIControlEventTouchUpInside];
        
        [naviBtn setTitleColor:XMBlueColor forState:UIControlStateNormal];
        
        [self.contentView addSubview:naviBtn];
        
        self.naviBtn = naviBtn;
        
        //-----------------------------seperate line---------------------------------------//
        
        UILabel *distanceLabel = [UILabel new];
        
        distanceLabel.font = [UIFont systemFontOfSize:13];
        
        distanceLabel.textColor = XMGrayColor;
        
        [self.contentView addSubview:distanceLabel];
        
        self.distanceLabel = distanceLabel;

        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self).offset(14);
        
        make.top.equalTo(self).offset(18);
        
        make.right.equalTo(self).offset(-70);
        
        make.height.equalTo(15);
        
    }];
    
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_nameLabel);
        
        make.top.equalTo(_nameLabel.mas_bottom).offset(8);
        
        make.height.equalTo(13);
        
        make.width.equalTo(FITWIDTH(170));
        
    }];
    
    [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(_addressLabel.mas_right).offset(25);
        
        make.top.equalTo(_addressLabel);
        
        make.width.equalTo(80);
        
        make.height.equalTo(13);

        
    }];
    
    
    
    [_naviBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(70, 70));
        
        make.right.equalTo(self);
        
        make.top.equalTo(self);
        
    }];
    
    
}

- (void)setPoi:(AMapPOI *)poi
{
    _nameLabel.text = poi.name;
    
    _addressLabel.text = poi.address;
    
    _distanceLabel.text = [NSString stringWithFormat:@"%.1f公里",poi.distance/1000.0];
  

}

- (void)naviBtnDidClick:(UIButton *)sender event:(UIEvent *)event
{
    
    NSDictionary *dic = @{@"sender":sender,@"event":event};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMCellNaviBtnDidClickNotification object:nil userInfo:dic];
 


}


@end
