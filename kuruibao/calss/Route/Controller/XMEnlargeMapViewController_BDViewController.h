//
//  XMEnlargeMapViewController_BDViewController.h
//  kuruibao
//
//  Created by X on 2017/6/3.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMTrackSegmentStateModel.h"

#import "AFNetworking.h"

@interface XMEnlargeMapViewController_BDViewController : UIViewController

@property (strong, nonatomic) XMTrackSegmentStateModel *segmentData;//!< 每段数据

@property (copy, nonatomic) NSString *qicheid;

@end
