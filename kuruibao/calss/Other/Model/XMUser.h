//
//  XMAccount.h
//  KuRuiBao
//
//  Created by x on 16/6/22.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
// 面向模型开发

/***********************************************************************************************
 专门用来描述账户信息的模型
 
 
 ************************************************************************************************/
#import <Foundation/Foundation.h>


@interface XMUser : NSObject<NSCoding>


@property (nonatomic, assign) NSInteger companyid;

@property (nonatomic, copy) NSString *carbrandid;

@property (nonatomic, copy) NSString *brandname;

@property (nonatomic, copy) NSString *carstyleid;

@property (nonatomic, copy) NSString *tboxid;

@property (nonatomic, assign) NSInteger userid;//!< 用户编号

@property (nonatomic, copy) NSString *vin;

@property (nonatomic, copy) NSString *carseriesid;

@property (nonatomic, copy) NSString *chepaino;

@property (nonatomic, copy) NSString *password;//!< 密码

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, copy) NSString *registrationid;//!< 推送标示

@property (nonatomic, copy) NSString *qicheid;

@property (nonatomic, assign) NSInteger secretflag;

@property (nonatomic, copy) NSString *seriesname;

@property (nonatomic, copy) NSString *stylename;

@property (nonatomic, assign) NSInteger role_id;

@property (nonatomic, copy) NSString *mobil;//!< 登录名

@property (nonatomic, assign) NSInteger typeId;//!< 用户类别

/**
 *  获取用户模型数据
 *
 *
 */
+ (XMUser *)user;

/**
 *  保存用户模型数据
 *
 *
 */
+(void)save:(XMUser *)user;


+ (instancetype)userWithDictionary:(NSDictionary *)dic;



/**
 退出登录时候，删除用户信息使用
 */
+ (void)deleteUserData;





























































































@end

