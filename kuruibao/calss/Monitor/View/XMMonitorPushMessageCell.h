//
//  XMMontorPushMessageCell.h
//  kuruibao
//
//  Created by x on 16/12/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMMonitorPushMessageCell : UITableViewCell

@property (copy, nonatomic) NSString *pushMessage;//!< 推送消息


+(instancetype)dequeueReuseableCellWithTableView:(UITableView *)tableView;


@end
