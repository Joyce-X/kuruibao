//
//  XMShowBreakCell.h
//  kuruibao
//
//  Created by x on 17/5/13.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMCarLife_BreakModel.h"

@interface XMShowBreakCell : UITableViewCell

@property (strong, nonatomic) XMCarLife_BreakModel *model;

+ (instancetype)dequeueReuseableCellWith:(UITableView*)tableView;

@end
