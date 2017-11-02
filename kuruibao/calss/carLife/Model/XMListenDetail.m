//
//  XMListenDetail.m
//  喜马拉雅测试
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMListenDetail.h"
#import "MJExtension.h"
@implementation XMListenDetail


+(void)initialize
{
    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{@"ID":@"id"};
        
    }];
    
    [self mj_setupObjectClassInArray:^NSDictionary *{
        
        return @{@"column_items":@"XMColumn_itemModel"};
        
    }];
}

@end
