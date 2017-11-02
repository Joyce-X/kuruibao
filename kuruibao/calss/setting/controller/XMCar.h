//
//  XMCar.h
//  kuruibao
//
//  Created by x on 16/10/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMCar : NSObject

//-- 个人客户属性列表
@property (nonatomic, assign) NSInteger isfirst;//!< 是否为默认车辆

@property (nonatomic, assign) NSInteger carstyleid;//!<款式编号

@property (nonatomic, assign) NSInteger tboxid;//!<绑定的设备号----

@property (nonatomic, assign) NSInteger userid;//!< 用户编号----

@property (nonatomic, copy) NSString *brandname;//!< 品牌---

@property (nonatomic, assign) NSInteger carseriesid;//!< 车系编号

@property (nonatomic, copy) NSString *chepaino;//!< 车牌号码----

@property (nonatomic, copy) NSString *stylename;//!< 款号----

@property (nonatomic, copy) NSString *imei;//!< 车辆绑定的imei----

@property (nonatomic, copy) NSString *seriesname;//!< 车系名称---

@property (nonatomic, assign) NSInteger uqid;//!< 未知

@property (nonatomic, assign) NSInteger qicheid;//!< 汽车编号---

@property (nonatomic, assign) NSInteger carbrandid;//!< 品牌编号

@property (assign, nonatomic) NSInteger qichetype;

//----------------------------------------------------------------------

//-- 企业客户属性列表

@property (nonatomic,assign)NSInteger brandid;//-- 品牌id

@property (nonatomic,assign)NSInteger seriesid;//-- 系列id

@property (nonatomic,assign)NSInteger styleid;//-- 款式id

@property (nonatomic,assign)NSInteger companyid;//-- 企业id

@property (nonatomic,copy)NSString* companyname;//-- 企业名称

@property (nonatomic,assign)NSInteger currentstatus;//-- 最近状态

@property (nonatomic,copy)NSString* mobil;//-- 用户手机号

@property (nonatomic,copy)NSString* ROWSTAT;//-- 未知





- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (instancetype)initWithDictionaryForCompany:(NSDictionary *)dic;

@end

