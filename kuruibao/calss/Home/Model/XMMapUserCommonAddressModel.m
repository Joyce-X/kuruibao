//
//  XMMapUserCommonAddressModel.m
//  kuruibao
//
//  Created by x on 16/11/26.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMMapUserCommonAddressModel.h"

@implementation XMMapUserCommonAddressModel


//!< 序列化
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.subTitle forKey:@"subTitle"];

}

//!< 反序列化
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super init];
    
    if (self)
    {
        self.latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        self.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.subTitle = [aDecoder decodeObjectForKey:@"subTitle"];
    }
    
    return self;
    
}

//!< 保存常用地址一
+ (void)saveFirstCommonAddress:(XMMapUserCommonAddressModel *)addressModel
{
    [NSKeyedArchiver archiveRootObject:addressModel toFile:CommonAddressOne];

}

//!< 保存常用地址二
+ (void)saveSecondCommonAddress:(XMMapUserCommonAddressModel *)addressModel
{
    [NSKeyedArchiver archiveRootObject:addressModel toFile:CommonAddressTwo];
}

//!< 获取常用地址一
+(XMMapUserCommonAddressModel *)firstCommonAddress
{
    
    XMMapUserCommonAddressModel * model = [NSKeyedUnarchiver unarchiveObjectWithFile:CommonAddressOne];
    
    return model;
}


//!< 获取常用地址二
+(XMMapUserCommonAddressModel *)secondCommonAddress
{

    XMMapUserCommonAddressModel * model = [NSKeyedUnarchiver unarchiveObjectWithFile:CommonAddressTwo];

    return model;
}




















@end
