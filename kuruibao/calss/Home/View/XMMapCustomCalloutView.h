//
//  XMMapCustomCalloutView.h
//  kuruibao
//
//  Created by x on 16/11/27.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMMapCustomCalloutView : UIView

@property (strong, nonatomic) UIImage *image;//!< 车辆图标

@property (copy, nonatomic) NSString *title;//!< 车辆型号

@property (copy, nonatomic) NSString *subtitle;//!< 是否在线

@property (copy, nonatomic) NSString *time;//!< 定位时间


@end
