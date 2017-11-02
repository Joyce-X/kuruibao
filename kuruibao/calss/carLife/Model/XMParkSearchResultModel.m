//
//  XMParkSearchResultModel.m
//  kuruibao
//
//  Created by X on 2017/4/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMParkSearchResultModel.h"

@implementation XMParkSearchResultModel

+(void)initialize
{
    
    [self mj_setupObjectClassInArray:^NSDictionary *{
        
        return @{@"result" : @"XMParkStationModel"};
        
    }];



}

@end
