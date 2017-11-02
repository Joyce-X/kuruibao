//
//  XMSettingCell.m
//  kuruibao
//
//  Created by x on 16/8/3.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/***********************************************************************************************
 设置主界面的自定义cell
 
 
 ************************************************************************************************/

#import "XMSettingCell.h"

@interface XMSettingCell()
@property (nonatomic,weak)UIImageView* iv;
@property (nonatomic,weak)UILabel* label;
@property (nonatomic,weak)UIButton* button;
@property (nonatomic,weak)UIView* line;
@end

@implementation XMSettingCell


/**
 *  cell的复用
 */
+ (instancetype)dequeueReusableCellWithTableview:(UITableView *)tableview
{
    static NSString *identifier = @"settingCell";
    XMSettingCell *cell = [tableview dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[XMSettingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
    
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //-- 创建子控件
        UIImageView *imageView = [UIImageView new];
        
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:10.5];
        label.textColor = XMColorFromRGB(0x7F7F7F);
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:imageView];
        [self.contentView addSubview:label];
//        [self.viewForLastBaselineLayout addSubview:button];
        
        self.iv = imageView;
        self.label = label;
//        self.button = button;
//        self.selectedImage = self.imageView.image;
        
        UIView *view = [UIView new];
        view.alpha = 0.3;
        self.line = view;
        [self.contentView addSubview:view];
        self.line.backgroundColor = XMColorFromRGB(0x7F7F7F);
        self.backgroundColor = XMColorFromRGB(0xF8F8F8);
        
    }
    
    return self;
    



}


- (void)setCellModel:(XMSettingCellModel *)cellModel
{
    _cellModel = cellModel;
    self.iv.image = [UIImage imageNamed:cellModel.imageName];
    self.label.text = cellModel.text;
 
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    __weak typeof(self) weakSelf = self;
    //-- 布局子控件
    [self.iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.contentView);
        make.size.equalTo(CGSizeMake(21, 21));
        make.left.equalTo(18);
    }];
    
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.contentView);
        make.left.equalTo(weakSelf.iv.mas_right).offset(13);
        make.size.equalTo(CGSizeMake(100, 16));
        
    }];

    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(mainSize.width, 1));
        make.bottom.equalTo(weakSelf.contentView).offset(-1);
        make.centerX.equalTo(weakSelf.contentView);
        
        
    }];

}

- (void)setHighlighted:(BOOL)highlighted
{}

@end
