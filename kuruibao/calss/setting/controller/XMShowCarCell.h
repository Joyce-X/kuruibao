//
//  XMShowCarCell.h
//  kuruibao
//
//  Created by x on 16/9/1.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMCar.h"
@interface XMShowCarCell : UITableViewCell

/**
 *  汽车
 */
@property (nonatomic,strong)XMCar* car;

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView;
@end
