//
//  XMNearbyPetrolStationResultModel.m
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMNearbyPetrolStationResultModel.h"

@implementation XMNearbyPetrolStationResultModel

+(void)initialize
{
    
    [self mj_setupObjectClassInArray:^NSDictionary *{
        
        return @{@"data":@"XMNearbyPetrolItemModel"};
        
    }];
    

    
}

@end
