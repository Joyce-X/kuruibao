//
//  XMProvince.m
//  kuruibao
//
//  Created by x on 16/9/8.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 省 模型
 
 
 ************************************************************************************************/
#import "XMProvince_x.h"
#import "XMCity.h"

@implementation XMProvince_x


+ (NSArray *)loadData
{
    
    NSError *error = nil;
    NSData *originData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"address.json" ofType:nil]];
    NSArray *allProvinces = [NSJSONSerialization JSONObjectWithData:originData options:NSJSONReadingAllowFragments error:&error];
    if (error)
    {
        XMLOG(@"地址数据解析失败");
        return nil;
    }
    
    NSMutableArray *provinces = [NSMutableArray array];
    for (NSDictionary * dic in allProvinces)
    {
        
        XMProvince_x *province = [[XMProvince_x alloc]initWithDictionary:dic];
        [provinces addObject:province];
    }
    
    
    return [provinces copy];
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init])
    {
        self.provinceName = dic[@"name"];
        NSMutableArray *citysM = [NSMutableArray array];
        NSArray *citys = dic[@"city"];
        for (NSDictionary *dictionary in citys)
        {
            XMCity *city = [[XMCity alloc]initWithDictionary:dictionary];
            [citysM addObject:city];
        }
        self.citys = citysM;
    }
    return self;
    
}

@end
