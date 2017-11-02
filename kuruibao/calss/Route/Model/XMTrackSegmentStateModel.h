//
//  XMTrackSegmentStateModel.h
//  kuruibao
//
//  Created by x on 16/11/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMTrackSegmentStateModel : NSObject

@property (copy, nonatomic) NSString *starttime;//!< 行程开始时间

@property (copy, nonatomic) NSString *endtime;//!< 行程结束时间

@property (assign, nonatomic) BOOL xingchengstatus;//!< 行程状态 1 一结束 0 未结束

@property (copy, nonatomic) NSString *penyou;//!< 行程油耗

@property (copy, nonatomic) NSString *licheng;//!< 行驶里程

@property (copy, nonatomic) NSString *xingshiTime;//!< 行驶时长

@property (copy, nonatomic) NSString *daisuTime;//!< 怠速时长

@property (copy, nonatomic) NSString *jishache;//!< 急刹车次数

@property (copy, nonatomic) NSString *jijiayou;//!< 急加油次数

@property (copy, nonatomic) NSString *comfortscore;//!< 舒适度得分

@property (copy, nonatomic) NSString *xingchengid;//!< 行程id

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
