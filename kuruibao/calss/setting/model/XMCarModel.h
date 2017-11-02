//
//  XMCarDataModel.h
//  kuruibao
//
//  Created by x on 16/8/26.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMCarModel : NSObject
/**
 *  硬件ID(obd编号)
 */
@property (nonatomic,copy)NSString* ID;

/**
 *  车辆品牌
 */
@property (nonatomic,copy)NSString* brand;

/**
 *  车辆系列
 */
@property (nonatomic,copy)NSString* serial;

/**
 *  车辆款式
 */
@property (nonatomic,copy)NSString* style;

/**
 *  行驶里程
 */
@property (nonatomic,copy)NSString* totalDistance;

/**
 *  购车时间
 */
@property (nonatomic,copy)NSString* buyTime;

/**
 *  车辆图标图片名称
 */
@property (nonatomic,copy)NSString* carImageName;

/**
 *  车牌号
 */
@property (nonatomic,copy)NSString* carNumber;


/**
 *  款号编号
 */
@property (nonatomic,copy)NSString* styleNumber;

/**
 *  系列编号
 */
@property (nonatomic,copy)NSString* serialNumber;

/**
 *  品牌编号
 */
@property (nonatomic,copy)NSString* brandNumber;
@end
