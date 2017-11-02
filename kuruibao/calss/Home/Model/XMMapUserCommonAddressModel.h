//
//  XMMapUserCommonAddressModel.h
//  kuruibao
//
//  Created by x on 16/11/26.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMMapUserCommonAddressModel : NSObject<NSCoding>

@property (assign, nonatomic) double latitude;//!< 纬度

@property (assign, nonatomic) double longitude;//!< 经度

@property (copy, nonatomic) NSString *name;//!< 名称

@property (copy, nonatomic) NSString *subTitle;//!< 详细地址


//!< 保存常用地址一
+ (void)saveFirstCommonAddress:(XMMapUserCommonAddressModel *)addressModel;



//!< 保存常用地址二
+ (void)saveSecondCommonAddress:(XMMapUserCommonAddressModel *)addressModel;


//!< 获取常用地址一
+(XMMapUserCommonAddressModel *)firstCommonAddress;



//!< 获取常用地址二
+(XMMapUserCommonAddressModel *)secondCommonAddress;

@end
