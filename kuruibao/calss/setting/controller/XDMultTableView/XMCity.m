//
//  XMCity.m
//  kuruibao
//
//  Created by x on 16/9/8.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 市 模型
 
 
 ************************************************************************************************/
#import "XMCity.h"
#import "XMArea.h"

@implementation XMCity

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init])
    {
        
        NSArray * areas = dic[@"area"];
        NSMutableArray *areasArray = [NSMutableArray array];
        for (NSString *areaName in areas)
        {
            XMArea *area = [[XMArea alloc]initWithName:areaName];
            [areasArray addObject:area];
        }
        
        self.cityName = dic[@"name"];
        self.areas = areasArray;
        
        
    }
    
    return self;
    

}
@end
