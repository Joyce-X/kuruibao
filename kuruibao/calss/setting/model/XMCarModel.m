//
//  XMCarDataModel.m
//  kuruibao
//
//  Created by x on 16/8/26.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 用户添加的每一辆车对应的数据模型，车辆的详细信息
 
 
 ************************************************************************************************/
#import "XMCarModel.h"
@interface XMCarModel()<NSCoding>
@end
@implementation XMCarModel

 

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.brand forKey:@"brand"];
    [aCoder encodeObject:self.style forKey:@"style"];
    [aCoder encodeObject:self.totalDistance forKey:@"totalDistance"];
    [aCoder encodeObject:self.buyTime forKey:@"buyTime"];
    [aCoder encodeObject:self.carImageName forKey:@"carImageName"];
    [aCoder encodeObject:self.carNumber forKey:@"carNumber"];
    [aCoder encodeObject:self.styleNumber forKey:@"styleNumber"];
    [aCoder encodeObject:self.serial forKey:@"serial"];

    

}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.brand = [aDecoder decodeObjectForKey:@"brand"];
        self.style = [aDecoder decodeObjectForKey:@"style"];
        self.totalDistance = [aDecoder decodeObjectForKey:@"totalDistance"];
        self.buyTime = [aDecoder decodeObjectForKey:@"buyTime"];
        self.carImageName = [aDecoder decodeObjectForKey:@"carImageName"];
        self.carNumber = [aDecoder decodeObjectForKey:@"carNumber"];
        self.styleNumber = [aDecoder decodeObjectForKey:@"styleNumber"];
        self.serial = [aDecoder decodeObjectForKey:@"serial"];

    }
    
    return self;

}
@end
