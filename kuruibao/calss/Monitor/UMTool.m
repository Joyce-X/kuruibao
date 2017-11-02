//
//  UMTool.m
//  kuruibao
//
//  Created by x on 17/7/12.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "UMTool.h"

@implementation UMTool

+(void)handleSuccellWithCarnumber:(NSString *)number
{

    //!< 友盟上传信息

    XMLOG(@"youmeng--没有检测到问题项---------");
    
    [MobClick event:@"Vehicle_delction" attributes:@{@"car":number,@"one":@"无",@"two":@"无",@"three":@"无",@"four":@"无"}];

}

+ (void)handleFailedWithArray:(NSArray *)array carNumber:(NSString *)number
{

    //!< 友盟上传信息
    
    NSString *one = @"无",*two = @"无",*three = @"无",*four = @"无";
    
    for (NSDictionary *dic_temp in array)
    {
        if (dic_temp[@"code"] == nil || [dic_temp[@"code"] length] < 4) {
            continue;
        }
        
        NSString *prefix = [dic_temp[@"code"] substringToIndex:1];
        
        if ([prefix isEqualToString:@"P"])
        {
            one = @"有";
            
        }else if ([prefix isEqualToString:@"B"])
        {
            two = @"有";
            
        }else if ([prefix isEqualToString:@"C"])
        {
            three = @"有";
            
        }else if ([prefix isEqualToString:@"U"])
        {
            four = @"有";
            
        }
    }
    
    
    
    [MobClick event:@"Vehicle_delction" attributes:@{@"car":number,
                                                     @"one":one,
                                                     @"two":two,
                                                     @"three":three,
                                                     @"four":four}];
    
    XMLOG(@"youmeng--检测结果-------%@---------",@{@"car":number,
                                               @"one":one,
                                               @"two":two,
                                               @"three":three,
                                               @"four":four});

}
@end
