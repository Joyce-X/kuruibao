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
#import "XMCarInfoCell.h"
#import "NSString+extention.h"

@interface XMCarInfoCell()


/**
 *  箭头
 */
@property (nonatomic,weak)UIImageView* arrow;
/**
 *  汽车图片
 */
@property (nonatomic,weak)UIImageView* carImage;

/**
 *  标题
 */
@property (nonatomic,weak)UILabel* mainLabel;
@end
@implementation XMCarInfoCell

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"carInfo";
    
    XMCarInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        
        cell = [[XMCarInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;

}



//->>设置相关数据
- (void)setCarInfo:(XMCarInfoSettingModel *)carInfo
{
    _carInfo =  carInfo;
    self.mainLabel.text = carInfo.title;
    if(carInfo.content == nil)
    {
        carInfo.content = @"";
    
    }
    self.subLabel.text = carInfo.content;
    

}


//->>初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = XMColor(254, 255, 255);
        
        //->>车型
        UILabel *mainLabel = [UILabel new];
        mainLabel.font = [UIFont systemFontOfSize:14];
        mainLabel.textColor = XMColorFromRGB(0x000000);
        mainLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:mainLabel];
        self.mainLabel = mainLabel;
        
        //->>车系（cell内容）
        UILabel *subLabel = [UILabel new];
        subLabel.font = [UIFont systemFontOfSize:12];
        subLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        subLabel.textColor = XMColorFromRGB(0x7F7F7F);
        [self.contentView addSubview:subLabel];
        self.subLabel = subLabel;
        
        //->>指示箭头
        UIImageView *arrow = [UIImageView new];
        arrow.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:arrow];
        self.arrow = arrow;
        
      

    }
    return self;
}


//->>在set方法中添加子控件
- (void)setIsFirst:(BOOL)isFirst
{
    _isFirst = isFirst;
     //->>款号
//    UILabel *style = [UILabel new];
//    style.font = [UIFont systemFontOfSize:12];
//    style.textColor = XMColorFromRGB(0x7F7F7F);
// 
//    style.lineBreakMode = NSLineBreakByTruncatingTail;
//    [self.contentView addSubview:style];
//    self.style = style;
    
    //->>如果是第一行，修改cell字体
    self.mainLabel.font = [UIFont systemFontOfSize:15];
    
    //->>创建显示图片
    UIImageView *carHeader = [UIImageView new];
    [self.contentView addSubview:carHeader];
    self.carImage = carHeader;

}


#pragma mark 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    __weak typeof(self) wSelf = self;
    if (_isFirst)
    {
        
        [self.carImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wSelf.contentView).offset(25);
            make.top.equalTo(wSelf.contentView).offset(27);
            make.width.equalTo(65);
            make.height.equalTo(65);
        }];
        
        [self.mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wSelf.carImage.mas_right).offset(15);
            make.bottom.equalTo(wSelf.contentView).offset(-55);
            
            make.width.equalTo(200);
            make.height.equalTo(10);
        }];
        
        [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wSelf.mainLabel);
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
        
    }else
    {
    
        [self.mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wSelf.contentView).offset(25);
            make.centerY.equalTo(wSelf.contentView);
            
            make.width.equalTo(80);
            make.height.equalTo(14);
        }];
        
        [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wSelf.contentView).offset(105);
            make.centerY.equalTo(wSelf.contentView);
            make.width.equalTo(200);
            make.height.equalTo(9);
        }];

    
    
    
    
    }
    
    [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wSelf.contentView).offset(-18);
        make.centerY.equalTo(wSelf.contentView);
        make.width.equalTo(6);
        make.height.equalTo(12);

    }];


}

- (void)setCar:(XMCar *)car
{
    _car = car;
    self.carImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",(long)car.carbrandid]];
    self.mainLabel.text = car.brandname;
    self.subLabel.text = [NSString stringWithFormat:@"%@ %@",car.seriesname,car.stylename];


}

@end
