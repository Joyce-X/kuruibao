//
//  XMTrackScoreModel.m
//  kuruibao
//
//  Created by x on 16/12/5.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMTrackScoreModel.h"

@implementation XMTrackScoreModel


- (instancetype)initWithDic:(NSDictionary *)dic
{

    self = [super init];
    
    
    
    if (self)
    {
        
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        
        for (NSString *key in dic.allKeys)
        {
            id obj = dic[key];
            
            if ([key isEqualToString:@"youhao100"] || [key isEqualToString:@"jizhuanwan100"] || [key isEqualToString:@"jishache100"] || [key isEqualToString:@"daisu100"] || [key isEqualToString:@"jijiayou100"] || [key isEqualToString:@"pinfanbiandao100"] || [key isEqualToString:@"wandaojiasu100"] )
            {
                
                float score_source = [obj floatValue];
                
                if (score_source > 0 && score_source < 100)
                {
                    obj = [NSString stringWithFormat:@"%.1f",score_source];
                }
                
                [dicM setObject:obj forKey:key];
                continue;
                
            }else
            {
                if ([obj isKindOfClass:[NSString class]])
                {
                    int result = 0;
                    float score = [obj floatValue];
                    
                    if (score > 0)
                    {
                        result = score + 0.5;
                    
                     obj = [NSString stringWithFormat:@"%d",result];
                    
                    }
                    
                }
                
                [dicM setObject:obj forKey:key];
                
            
            
            }
            
            
            
        }

         self.qicheid = dicM[@"qicheid"];
    
         self.penyou = dicM[@"penyou"];
        
         self.penyouno = dicM[@"penyouno"];
 
         self.penyouscore = dicM[@"penyouscore"];
        
         self.jishache = dicM[@"jishache"];
        
         self.jishache100 = dicM[@"jishache100"];
        
         self.jishacheno = dicM[@"jishacheno"];
        
         self.jishachescore = dicM[@"jishachescore"];
        
         self.jijiayou = dicM[@"jijiayou"];
        
         self.jijiayou100 = dicM[@"jijiayou100"];
        
         self.jijiayouno = dicM[@"jijiayouno"];
        
         self.jijiayouscore = dicM[@"jijiayouscore"];
        
        
         self.pinfanbiandao = dicM[@"pinfanbiandao"];
        
         self.pinfanbiandao100 = dicM[@"pinfanbiandao100"];
        
         self.pinfanbiandaono = dicM[@"pinfanbiandaono"];
        
         self.pinfanbiandaoscore = dicM[@"pinfanbiandaoscore"];
        
          self.wandaojiasu = dicM[@"wandaojiasu"];
        
         self.wandaojiasu100 = dicM[@"wandaojiasu100"];
        
         self.wandaojiasuno = dicM[@"wandaojiasuno"];
        
         self.wandaojiasuscore = dicM[@"wandaojiasuscore"];
        
         self.youhao100 = dicM[@"youhao100"];
        
         self.youhao100no = dicM[@"youhao100no"];
        
         self.youhao100score = dicM[@"youhao100score"];
        
          self.daisutime = dicM[@"daisutime"];
        
         self.daisu100 = dicM[@"daisu100"];
        
         self.daisuno = dicM[@"daisuno"];
        
        self.daisuscore = dicM[@"daisuscore"];
        
         self.jizhuanwan = dicM[@"jizhuanwan"];
        
         self.jizhuanwan100 = dicM[@"jizhuanwan100"];
        
         self.jizhuanwanno = dicM[@"jizhuanwanno"];
        
        self.jizhuanscore = dicM[@"jizhuanscore"];
        
          self.anquanscore = dicM[@"anquanscore"];
        
         self.speedscore = dicM[@"speedscore"];
        
         self.huanbaoscore = dicM[@"huanbaoscore"];
        
         self.ditanscore = dicM[@"ditanscore"];
        
         self.xiguanscore = dicM[@"xiguanscore"];
    }

    return self;

}















@end
