//
//  XMPriceResultModel.m
//  kuruibao
//
//  Created by X on 2017/4/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMPriceResultModel.h"



@implementation XMPriceResultModel


+ (void)initialize
{
    
    [self mj_setupObjectClassInArray:^NSDictionary *{
        
        return @{@"result":@"XMPriceModel"};
        
    }];

}

@end
