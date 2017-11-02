//
//  XMCompany_section0_view.h
//  kuruibao
//
//  Created by x on 17/5/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMCar.h"

@interface XMCompany_section0_view : UIView


/**
 显示车辆图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/**
 显示车牌号码
 */
@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;

/**
 显示行驶状态
 */
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

/**
 显示总名称
 */
@property (weak, nonatomic) IBOutlet UILabel *allNameLabel;

/**
 数据模型
 */
@property (strong, nonatomic) XMCar *carModel;

@end
