//
//  XMTrackLocationModel.h
//  kuruibao
//
//  Created by x on 16/11/30.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMTrackLocationModel : NSObject

@property (assign, nonatomic) double locationx;//!< 经度

@property (assign, nonatomic) double locationy;//!< 纬度

@property (copy, nonatomic) NSString *eventType;

@end
