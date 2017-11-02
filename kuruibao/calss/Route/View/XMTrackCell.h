//
//  XMTrackCell.h
//  kuruibao
//
//  Created by x on 16/11/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "XMTrackSegmentStateModel.h"


typedef void (^enlargeBlock) (UIButton *btn,UIEvent *event); //!< 点击地图的block

@interface XMTrackCell : UITableViewCell

@property (strong, nonatomic) XMTrackSegmentStateModel *segmentData;//!< 每段数据

@property (copy, nonatomic) enlargeBlock clickEnlarge;//!< 点击地图回调方法

+ (instancetype)dequeueReuseableCellWith:(UITableView*)tableView;

@property (copy, nonatomic) NSString *qicheid;//!< 汽车编号

@end
