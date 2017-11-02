//
//  XMColumn_itemModel.m
//  喜马拉雅测试
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMColumn_itemModel.h"
#import "MJExtension.h"
@implementation XMColumn_itemModel
+(void)initialize
{
    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{@"ID":@"id"};
        
    }];
    
    
}
@end
