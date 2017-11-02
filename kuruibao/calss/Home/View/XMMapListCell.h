//
//  XMMapListCell.h
//  kuruibao
//
//  Created by x on 16/11/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>


@interface XMMapListCell : UITableViewCell

+ (instancetype)dequeueReuseableCellWithTableView:(UITableView *)tableView;


@property (strong, nonatomic) AMapPOI *poi;

@end
