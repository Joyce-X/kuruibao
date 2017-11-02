//
//  XMMonitorTroubleCell.h
//  kuruibao
//
//  Created by x on 16/12/10.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMTroubleItemModel.h"
@interface XMMonitorTroubleCell : UITableViewCell

@property (strong, nonatomic) XMTroubleItemModel *model;

+(instancetype)dequeueReuseableCellWithTableView:(UITableView *)tableView;

@end
