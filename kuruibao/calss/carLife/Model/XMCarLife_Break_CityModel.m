//
//  XMCarLife_Break_CityModel.m
//  kuruibao
//
//  Created by x on 17/5/13.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLife_Break_CityModel.h"

#import "MJExtension.h"

@implementation XMCarLife_Break_CityModel

+(void)initialize
{

    
    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
       
        return @{@"class1" : @"class"};
        
    }];


}



@end
