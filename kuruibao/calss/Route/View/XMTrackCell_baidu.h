//
//  XMTrackCell_baidu.h
//  kuruibao
//
//  Created by x on 17/6/5.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
 
#import "XMTrackSegmentStateModel.h"


typedef void (^enlargeBlock) (UIButton *btn,UIEvent *event); //!< 点击地图的block

@interface XMTrackCell_baidu : UITableViewCell

@property (strong, nonatomic) XMTrackSegmentStateModel *segmentData;//!< 每段数据

@property (copy, nonatomic) enlargeBlock clickEnlarge;//!< 点击地图回调方法

+ (instancetype)dequeueReuseableCellWith:(UITableView*)tableView;

@property (copy, nonatomic) NSString *qicheid;//!< 汽车编号

- (void)willDisappare;

@end
