//
//  XMCarInfoSettingModel.h
//  kuruibao
//
//  Created by x on 16/8/26.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XMCar.h"
typedef  NS_ENUM(NSInteger,XMCarCount){
    
    XMCarCountNone, //->>用户没有选择车辆
    XMCarCountExist  //->>车辆信息存在

};

@interface XMCarInfoSettingModel : NSObject
/**
 *  车标的图片名称
 */
@property (nonatomic,copy)NSString* imageName;

/**
 *  车辆信息需要设置的标题
 */
@property (nonatomic,copy)NSString* title;

/**
 *  设置项的具体内容信息
 */
@property (nonatomic,copy)NSString* content;


/**
 *  需要跳转的控制器
 */
@property (nonatomic,assign)Class destinationClass;

/**
 *  款式
 */
@property (nonatomic,copy)NSString* style;

/**
 *  创建数组（选择车辆/没有选择车辆的情况）
 */
+ (NSArray *)buildModelDataWithCarCount:(XMCar *)car;

/**
 *  创建分区一的数据源
 *
 *  @return 用户所有车辆详细信息
 */
//+ (NSArray *)buildModeDataForFirstSection;

@end
