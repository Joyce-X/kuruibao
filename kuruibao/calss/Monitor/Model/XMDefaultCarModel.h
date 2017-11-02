//
//  XMDefaultCarModel.h
//  kuruibao
//
//  Created by x on 16/11/17.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMDefaultCarModel : NSObject

@property (copy, nonatomic) NSString *mobil;//!< 电话

@property (copy, nonatomic) NSString *userid;//!< 用户编号

@property (copy, nonatomic) NSString *registrationid;//!< 推送编号

@property (copy, nonatomic) NSString *typeID;//!< 用户类别，app所有用户默认为1

@property (copy, nonatomic) NSString *role_id;//!< 待扩展

@property (copy, nonatomic) NSString *companyid;//!< 公司编号

@property (copy, nonatomic) NSString *qicheid;//!< 汽车编号

@property (copy, nonatomic) NSString *chepaino;//!< 车牌号码

@property (copy, nonatomic) NSString *tboxid;//!< 终端编号

@property (copy, nonatomic) NSString *secretflag;//!< 隐私设置

@property (copy, nonatomic) NSString *imei;//!< imei号码

@property (copy, nonatomic) NSString *carbrandid;//!< 品牌编号

@property (copy, nonatomic) NSString *carseriesid;//!< 车系编号

@property (copy, nonatomic) NSString *carstyleid;//!< 款式编号

@property (copy, nonatomic) NSString *brandname;//!< 品牌名称

@property (copy, nonatomic) NSString *seriesname;//!< 系列名称

@property (copy, nonatomic) NSString *stylename;//!< 款式名称

@property (copy, nonatomic) NSString *qichetype;//!< 汽车类型

@property (copy, nonatomic) NSString *currentstatus;//!< 当前状态

 

+ (instancetype)defaultWithDictionary:(NSDictionary *)dic;



@end
