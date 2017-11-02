//
//  XMParkDetailSearchResultModel.m
//  kuruibao
//
//  Created by x on 17/4/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMParkDetailSearchResultModel.h"

@implementation XMParkDetailSearchResultModel

+ (void)initialize
{

    [self mj_setupObjectClassInArray:^NSDictionary *{
        
        return @{@"result" : @"XMParkDetailModel"};
        
    }];


}

@end
