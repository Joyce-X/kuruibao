              //
//  XMEnlargeMapViewController.h
//  kuruibao
//
//  Created by x on 17/3/20.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AMapNaviKit/AMapNaviKit.h>

#import "XMTrackSegmentStateModel.h"

#import "AFNetworking.h"

@interface XMEnlargeMapViewController : UIViewController

@property (strong, nonatomic) XMTrackSegmentStateModel *segmentData;//!< 每段数据

@property (copy, nonatomic) NSString *qicheid;

@end
