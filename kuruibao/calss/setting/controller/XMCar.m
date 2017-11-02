//
//  XMCar.m
//  kuruibao
//
//  Created by x on 16/10/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMCar.h"

@implementation XMCar

- (instancetype)initWithDictionary:(NSDictionary *)dic
{

    self = [super init];
    
    if(self)
    {
    
        NSMutableDictionary *dic_M = [NSMutableDictionary dictionaryWithCapacity:dic.allKeys.count];
        
        for (NSString *key in dic.allKeys)
        {
            id obj = dic[key];
            
            if ([obj isKindOfClass:[NSNull class]])
            {
                obj = @"";
            }
            
            [dic_M setObject:obj forKey:key];
            
        }

        self.qicheid = [dic_M[@"qicheid"] integerValue];
        
        self.tboxid = [dic_M[@"tboxid"] integerValue];
        
        self.chepaino = dic_M[@"chepaino"];
        
        self.carbrandid = [dic_M[@"carbrandid"] integerValue];
        
        self.brandname = dic_M[@"brandname"];
        
        self.carseriesid = [dic_M[@"carseriesid"] integerValue];
        
        self.seriesname = dic_M[@"seriesname"];
        
        self.carstyleid = [dic_M[@"carstyleid"] integerValue];
        
        self.stylename = dic_M[@"stylename"];//
        
        self.uqid = [dic_M[@"uqid"] integerValue];
        
        self.userid = [dic_M[@"userid"] integerValue];
        
        self.imei = dic_M[@"imei"];
        
        self.qichetype = [dic_M[@"qichetype"] integerValue];
        
        self.isfirst = [dic_M[@"isfirst"] integerValue];
       

        
    
    }
    
    return self;
}

- (instancetype)initWithDictionaryForCompany:(NSDictionary *)dic
{

    
    self = [super init];
    
    if (self)
    {
        
        NSMutableDictionary *dic_M = [NSMutableDictionary dictionaryWithCapacity:dic.allKeys.count];
        
        for (NSString *key in dic.allKeys)
        {
            id obj = dic[key];
            
            if ([obj isKindOfClass:[NSNull class]])
            {
                obj = @"";
            }
            
            [dic_M setObject:obj forKey:key];
            
        }

        self.qicheid = [dic_M[@"qicheid"] integerValue];
        
        self.tboxid = [dic_M[@"tboxid"] integerValue];
        
        self.chepaino = dic_M[@"chepaino"];
        
        self.brandid = [dic_M[@"brandid"] integerValue];
        
        
        self.brandname = dic_M[@"brandname"];
        
        self.seriesid = [dic_M[@"seriesid"] integerValue];
        
        self.seriesname = dic_M[@"seriesname"];
        
        self.styleid = [dic_M[@"styleid"] integerValue];
        
        self.stylename = dic_M[@"stylename"];
        
        self.companyid = [dic_M[@"companyid"] integerValue];
        
        self.companyname = dic_M[@"companyname"];
        
        self.currentstatus = [dic_M[@"currentstatus"] integerValue];
        
        self.userid = [dic_M[@"userid"] integerValue];
        
        self.imei = dic_M[@"imei"];
        
        self.mobil = dic_M[@"mobil"];
        
        self.ROWSTAT = dic_M[@"ROWSTAT"];
        
        
    }

    return self;

}

@end


