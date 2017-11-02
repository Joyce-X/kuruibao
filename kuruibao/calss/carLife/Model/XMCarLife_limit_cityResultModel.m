//
//  XMCarLife_limit_cityResultModel.m
//  kuruibao
//
//  Created by x on 17/5/12.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLife_limit_cityResultModel.h"

@implementation XMCarLife_limit_cityResultModel


+(void)initialize
{

    [self mj_setupObjectClassInArray:^NSDictionary *{
        
        return @{@"data":@"XMCarLife_limit_cityModel"};
    }];


}


@end
