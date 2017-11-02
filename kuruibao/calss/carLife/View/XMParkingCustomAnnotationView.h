//
//  XMParkingCustomAnnotationView.h
//  kuruibao
//
//  Created by x on 17/4/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

#import "XMParkingCustomCalloutView.h"

@interface XMParkingCustomAnnotationView : MAAnnotationView

@property (readonly, nonatomic) XMParkingCustomCalloutView *calloutView;

@end
