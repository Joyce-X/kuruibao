//
//  XMAnnouncer.m
//  喜马拉雅测试
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMAnnouncerModel.h"
#import "MJExtension.h"
@implementation XMAnnouncerModel


+(void)initialize
{
    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{@"ID":@"id"};
        
    }];


}

@end
