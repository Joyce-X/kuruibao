//
//  XMCarInfoCell.m
//  kuruibao
//
//  Created by x on 16/8/26.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 添加车辆内容显示cell
 
 
 ************************************************************************************************/
#import "XMShowCarCell.h"
#import "NSString+extention.h"

@interface XMShowCarCell()

@property (nonatomic,weak)UILabel* brand;//->>品牌
@property (nonatomic,weak)UILabel* serial;//->>系列
@property (nonatomic,weak)UILabel* style;//->>款号
@property (nonatomic,weak)UIImageView* header;//->>汽车图片
@property (nonatomic,weak)UIImageView* indicator;//->>指示图标
//@property (nonatomic,weak)UIView* line;


@end
@implementation XMShowCarCell

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"showCar";
    
    XMShowCarCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        
        cell = [[XMShowCarCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
    
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = XMColor(254, 255, 255);
        
        //->>车型
        UILabel *brand = [UILabel new];
        brand.font = [UIFont systemFontOfSize:15];
        brand.textColor = XMColorFromRGB(0x000000);
        brand.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:brand];
        self.brand = brand;
        
        //->>车系
        UILabel *serial = [UILabel new];
        serial.font = [UIFont systemFontOfSize:12];
        //        subLabel.adjustsFontSizeToFitWidth = YES;
        serial.lineBreakMode = NSLineBreakByTruncatingTail;
        serial.textColor = XMColorFromRGB(0x7F7F7F);
        [self.contentView addSubview:serial];
        self.serial = serial;
        
        //->>款号
//        UILabel *style = [UILabel new];
//        style.font = [UIFont systemFontOfSize:12];
//        style.textColor = XMColorFromRGB(0x7F7F7F);
//        style.lineBreakMode = NSLineBreakByTruncatingTail;
//        [self.contentView addSubview:style];
//        self.style = style;
       
        //->>创建显示图片
        UIImageView *header = [UIImageView new];
        [self.contentView addSubview:header];
        self.header = header;
        
        //->>指示箭头
        UIImageView *indicator = [UIImageView new];
        indicator.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:indicator];
        self.indicator = indicator;
        
//        //->>分割线
//        UIView *line = [UIView new];
//        line.backgroundColor = XMColorFromRGB(0x7F7F7F);
//        [self.contentView addSubview:line];
//        self.line = line;
        
        
        
    }
    return self;
}



#pragma mark 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    __weak typeof(self) wSelf = self;
    
        
        [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wSelf.contentView).offset(25);
            make.top.equalTo(wSelf.contentView).offset(27);
            make.width.equalTo(65);
            make.height.equalTo(65);
        }];
        
        [self.brand mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wSelf.header.mas_right).offset(15);
            make.bottom.equalTo(wSelf.contentView).offset(-55);
            
            make.width.equalTo(200);
            make.height.equalTo(10);
        }];
        
        [self.serial mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wSelf.brand);
            make.bottom.equalTo(wSelf.contentView).offset(-35);
            
            make.width.equalTo(mainSize.width - 105 - 30);
            make.height.equalTo(10);
        }];
        //
//        CGFloat styleW = mainSize.width - 105 - [wSelf.subLabel.text getWidthWith:14] - 50;
//        [self.style mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(wSelf.subLabel.mas_right).offset(2);
//            make.top.equalTo(wSelf.subLabel);
//            
//            make.width.equalTo(styleW);
//            make.height.equalTo(13);
//        }];
        //        self.carImage.frame = CGRectMake(25, (109 - 55)* 0.5, 55, 55);
        //        self.mainLabel.frame = CGRectMake(105, 36, 200, 15);
        //        self.subLabel.frame = CGRectMake(105, 36 + 23, [self.subLabel.text getWidthWith:14], 13);
        //        self.style.frame = CGRectMake(105 + [self.subLabel.text getWidthWith:14] + 2, 59, styleW, 13);

    [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wSelf.contentView).offset(-15);
        make.bottom.equalTo(wSelf.contentView).offset(-43);
        make.width.equalTo(7);
        make.height.equalTo(16.5);
        
    }];
    
    
    
}

- (void)setCar:(XMCar *)car
{
    _car = car;
    self.header.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",(long)car.carbrandid]];
    self.brand.text = car.brandname;
    self.serial.text = [NSString stringWithFormat:@"%@ %@",car.seriesname,car.stylename];
    


}

@end
