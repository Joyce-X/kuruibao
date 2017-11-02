//
//  XMCarLife_SaveCarAnnotation.h
//  kuruibao
//
//  Created by x on 17/5/11.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

#import "XMParkStationModel.h"

@interface XMCarLife_SaveCarAnnotation : MAPointAnnotation

@property (strong, nonatomic) XMParkStationModel *model;//!< data model

@end
