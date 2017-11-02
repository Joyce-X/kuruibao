//
//  XMTrackAverageStateModel.h
//  kuruibao
//
//  Created by x on 16/11/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMTrackAverageStateModel : NSObject

@property (copy, nonatomic) NSString *totallicheng;//!< 里程

@property (copy, nonatomic) NSString *totalpenyou;//!< 油耗

@property (copy, nonatomic) NSString *totalMoney;//!< 消费RMB

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
