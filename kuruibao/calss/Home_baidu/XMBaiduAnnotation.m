//
//  XMBaiduAnnotation.m
//  kuruibao
//
//  Created by x on 17/6/19.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMBaiduAnnotation.h"

@implementation XMBaiduAnnotation




- (void)setDeadLine:(NSString *)deadLine
{

    if ([deadLine containsString:@"T"])
    {
        deadLine = [deadLine stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
    
    if (deadLine.length < 2)
    {
        deadLine = @"暂无数据";
    }
    
    _deadLine = deadLine;


}

- (void)setBrindId:(NSUInteger)brindId
{
   
    
    _brindId = brindId;

}




@end
