//
//  XMCompany_section1_cellTableViewCell.h
//  kuruibao
//
//  Created by x on 17/5/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMCar.h"

@interface XMCompany_section1_cellTableViewCell : UITableViewCell

/**
 数据模型
 */
@property (strong, nonatomic) XMCar *carModel;

+ (instancetype)dequeueWithTableView:(UITableView *)tableView;

@end
