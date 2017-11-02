//
//  XMBaiduLocationModel.h
//  kuruibao
//
//  Created by X on 2017/6/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

#import "XMBaiduAnnotation.h"

@interface XMBaiduLocationModel : NSObject


@property (copy, nonatomic) NSString *mobil;//!< 电话

@property (copy, nonatomic) NSString *userid;//!< 用户编号

@property (copy, nonatomic) NSString *registrationid;//!< 推送编号

@property (copy, nonatomic) NSString *typeID;//!< 用户类别，app所有用户默认为1

@property (copy, nonatomic) NSString *role_id;//!< 待扩展

@property (copy, nonatomic) NSString *companyid;//!< 公司编号

@property (copy, nonatomic) NSString *qicheid;//!< 汽车编号----------------------------------

@property (copy, nonatomic) NSString *chepaino;//!< 车牌号码

@property (copy, nonatomic) NSString *tboxid;//!< 终端编号----------------------------------

@property (copy, nonatomic) NSString *secretflag;//!< 隐私设置

@property (copy, nonatomic) NSString *imei;//!< imei号码

@property (strong, nonatomic) NSString* carbrandid;//!< 品牌编号

@property (copy, nonatomic) NSString *carseriesid;//!< 车系编号

@property (copy, nonatomic) NSString *carstyleid;//!< 款式编号

@property (copy, nonatomic) NSString *brandname;//!< 品牌名称

@property (copy, nonatomic) NSString *seriesname;//!< 系列名称

@property (copy, nonatomic) NSString *stylename;//!< 款式名称

@property (copy, nonatomic) NSString *qichetype;//!< 汽车类型

@property (copy, nonatomic) NSString *currentstatus;//!< 当前状态


//-- 添加需要用到的属性
@property (nonatomic,copy)NSString* showName;//-- 显示在线不在线  或者显示行驶中/停驶/失联状态

@property (nonatomic,strong)XMBaiduAnnotation* annotation;//-- 显示位置标注

@property (nonatomic,copy)NSString* time;//-- 最后一次定位的时间

@property (assign, nonatomic) BOOL noLocation;//!< 是否是错误的数据

+ (instancetype)defaultWithDictionary:(NSDictionary *)dic;


@end
