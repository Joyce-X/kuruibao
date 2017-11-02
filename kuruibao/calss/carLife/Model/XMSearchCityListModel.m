//
//  XMSearchCityListModel.m
//  kuruibao
//
//  Created by X on 2017/4/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMSearchCityListModel.h"

@implementation XMSearchCityListModel


+ (void)initialize
{

    [self mj_setupObjectClassInArray:^NSDictionary *{
        
        return @{@"result":@"XMParkSupportCityModel"};
        
    }];

}

@end
