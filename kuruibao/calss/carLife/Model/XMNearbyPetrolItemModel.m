//
//  XMNearbyPetrolItemModel.m
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMNearbyPetrolItemModel.h"

#import "MJExtension.h"

@implementation XMNearbyPetrolItemModel

+ (void)initialize
{

    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{@"ID":@"id"};
        
    }];

}

@end
