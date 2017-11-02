//
//  XMMapCarLocationModel.h
//  kuruibao
//
//  Created by x on 16/11/27.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMMapCarLocationModel : NSObject

/**
 *  在初始化的时候都已经对百度经纬度和GPS经纬度进行过转化，都已经转化为高德坐标系，2组坐标随便用
 */

@property (copy, nonatomic) NSString *qicheid;//!< 汽车编号

@property (assign, nonatomic) double bailng;//!< 百度地图经度

@property (assign, nonatomic) double bailat;//!< 百度地图纬度

@property (assign, nonatomic) double locationx;//!< GPS经度

@property (assign, nonatomic) double locationy;//!< GPS纬度

@property (copy, nonatomic) NSString *time;

@property (copy, nonatomic) NSString *qicheno;//!< 汽车牌照

@property (copy, nonatomic) NSString *tboxid;

@property (copy, nonatomic) NSString *carbrandid;

@property (nonatomic,assign)NSInteger currentstatus;//-- 最近状态

- (instancetype)initWithDictionary:(NSDictionary *)dic;



@end
