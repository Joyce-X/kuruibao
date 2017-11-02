//
//  XMCarInfoCell.h
//  kuruibao
//
//  Created by x on 16/8/26.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMCarInfoSettingModel.h"
#import "XMCar.h"
@interface XMCarInfoCell : UITableViewCell

@property (nonatomic,strong)XMCarInfoSettingModel* carInfo;

/**
 *  款式
 */
//@property (nonatomic,weak)UILabel* style;

/**
 * 子标题
 */
@property (nonatomic,weak)UILabel* subLabel;

/**
 *  是否是第一个数据
 */
@property (nonatomic,assign)BOOL isFirst;


/**
 *  汽车
 */
@property (nonatomic,strong)XMCar* car;

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView;
@end
