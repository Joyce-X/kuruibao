//
//  XMColumnList.m
//  喜马拉雅测试
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMColumnList_x.h"
#import "MJExtension.h"

@implementation XMColumnList_x

+(void)initialize
{
    [XMColumnList_x mj_setupObjectClassInArray:^NSDictionary *{
        
        return @{@"columns":@"XMColumn_x"};
    }];

}

@end
