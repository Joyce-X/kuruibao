//
//  XMGastpriceModel.m
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMGastpriceModel.h"

#import "MJExtension.h"

@implementation XMGastpriceModel


+ (void)initialize
{
    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{
                  @"nine2":@"92#",
                 
                  @"nine5":@"95#",
                 
                  @"zero":@"0#车柴",
                 
                 
                 };
        
    }];
    

}

@end
