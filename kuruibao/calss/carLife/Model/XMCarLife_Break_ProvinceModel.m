//
//  XMCarLife_Break_ProvinceModel.m
//  kuruibao
//
//  Created by x on 17/5/13.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLife_Break_ProvinceModel.h"

@implementation XMCarLife_Break_ProvinceModel

+(void)initialize
{

    [self mj_setupObjectClassInArray:^NSDictionary *{
        
        return @{@"citys":@"XMCarLife_Break_CityModel"};
        
    }];


}

@end
