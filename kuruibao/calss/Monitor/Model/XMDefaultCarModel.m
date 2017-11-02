//
//  XMDefaultCarModel.m
//  kuruibao
//
//  Created by x on 16/11/17.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMDefaultCarModel.h"

@implementation XMDefaultCarModel

+ (instancetype)defaultWithDictionary:(NSDictionary *)dic
{

    
    return [[self alloc] initWithDictionary:dic];

 
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    
    if (self) {
       
        self.currentstatus = dic[@"currentstatus"];
        
        self.qichetype = dic[@"qichetype"];
        
        self.stylename = dic[@"stylename"];
        
        self.seriesname = dic[@"seriesname"];
        
        self.brandname = dic[@"brandname"];
        
        self.carstyleid = dic[@"carstyleid"];
        
        self.carseriesid = dic[@"carseriesid"];
        
        self.carbrandid = dic[@"carbrandid"];
        
        self.imei = dic[@"imei"];
        
        self.secretflag = dic[@"secretflag"];
        
        self.tboxid = dic[@"tboxid"];
        
        self.chepaino = dic[@"chepaino"];
        
        self.qicheid = dic[@"qicheid"];
        
        self.companyid = dic[@"companyid"];
        
        self.role_id = dic[@"role_id"];
        
        self.typeID = dic[@"typeid"];
        
        self.registrationid = dic[@"registrationid"];
        
        self.userid = dic[@"userid"];
        
        self.mobil = dic[@"mobil"];
        
    }
    
    return self;
}

@end
