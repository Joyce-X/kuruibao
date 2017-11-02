//
//  XMParkingCustomCalloutView.h
//  kuruibao
//
//  Created by x on 17/4/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMParkStationModel.h"

@interface XMParkingCustomCalloutView : UIView

//@property (copy, nonatomic) NSString *CCID;

@property (nonatomic,weak)UIButton* naviBtn;//-- navi

@property (strong, nonatomic) XMParkStationModel *model;

@end
