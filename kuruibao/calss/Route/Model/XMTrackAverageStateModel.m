//
//  XMTrackAverageStateModel.m
//  kuruibao
//
//  Created by x on 16/11/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/**********************************************************
 class description:一天内行程的平均数据
 
 **********************************************************/
#import "XMTrackAverageStateModel.h"


#define oilPrice 5.94

@implementation XMTrackAverageStateModel


- (instancetype)initWithDictionary:(NSDictionary *)dic
{

    self = [super init];
    
    if (self)
    {
        self.totallicheng = dic[@"totallicheng"];
        
        self.totalpenyou = dic[@"totalpenyou"];
        
        if (self.totallicheng.length == 0)
        {
            self.totallicheng = @"0";
        }
        
        if (self.totalpenyou.length == 0)
        {
            self.totalpenyou = @"0";
        }
        
        self.totalMoney = [NSString stringWithFormat:@"%.1fRMB",self.totalpenyou.floatValue * oilPrice];
        
        self.totallicheng = [NSString stringWithFormat:@"%.1fkm",self.totallicheng.floatValue];
        
        self.totalpenyou = [NSString stringWithFormat:@"%.1fL",self.totalpenyou.floatValue];
        
    }

    return self;

}
@end
