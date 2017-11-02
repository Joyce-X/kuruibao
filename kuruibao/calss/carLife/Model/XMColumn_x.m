//
//  XMColumn.m
//  喜马拉雅测试
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMColumn_x.h"
#import "MJExtension.h"

@implementation XMColumn_x


+(void)initialize
{

    //!< 替换转模型的时候id的值
    [XMColumn_x mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{@"ID":@"id"};
        
        
    }];

}

@end
