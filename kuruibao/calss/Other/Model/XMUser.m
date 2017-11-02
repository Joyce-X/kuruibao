//
//  XMAccount.m
//  KuRuiBao
//
//  Created by x on 16/6/22.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMUser.h"


static XMUser *userInstance = nil;

@implementation XMUser



- (void)encodeWithCoder:(NSCoder *)encoder
{
    //-- 序列化
    
    [encoder encodeInteger:self.companyid forKey:@"companyid"];
    [encoder encodeInteger:self.typeId forKey:@"typeId"];
    [encoder encodeInteger:self.role_id forKey:@"role_id"];
    [encoder encodeInteger:self.secretflag forKey:@"secretflag"];
    [encoder encodeInteger:self.userid forKey:@"userid"];

    
    [encoder encodeObject:self.tboxid forKey:@"tboxid"];
    [encoder encodeObject:self.carstyleid forKey:@"carstyleid"];
    [encoder encodeObject:self.brandname forKey:@"brandname"];
    [encoder encodeObject:self.carbrandid forKey:@"carbrandid"];
    [encoder encodeObject:self.mobil forKey:@"mobil"];
    [encoder encodeObject:self.stylename forKey:@"stylename"];
    [encoder encodeObject:self.seriesname forKey:@"seriesname"];
    [encoder encodeObject:self.qicheid forKey:@"qicheid"];
    [encoder encodeObject:self.registrationid forKey:@"registrationid"];
    [encoder encodeObject:self.imei forKey:@"imei"];
    [encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.chepaino forKey:@"chepaino"];
    [encoder encodeObject:self.vin forKey:@"vin"];
    [encoder encodeObject:self.carseriesid forKey:@"carseriesid"];
    

}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    //-- 反序列化
    self = [super init];
    if (self)
    {
        
         self.companyid = [aDecoder decodeIntegerForKey:@"companyid"];
         self.typeId = [aDecoder decodeIntegerForKey:@"typeId"];
         self.role_id = [aDecoder decodeIntegerForKey:@"role_id"];
         self.secretflag = [aDecoder decodeIntegerForKey:@"secretflag"];
         self.userid = [aDecoder decodeIntegerForKey:@"userid"];
        
        
        self.tboxid = [aDecoder decodeObjectForKey:@"tboxid"];
        self.brandname = [aDecoder decodeObjectForKey:@"brandname"];
        self.carbrandid = [aDecoder decodeObjectForKey:@"carbrandid"];
        self.mobil = [aDecoder decodeObjectForKey:@"mobil"];
        self.stylename = [aDecoder decodeObjectForKey:@"stylename"];
        
        
        self.seriesname = [aDecoder decodeObjectForKey:@"seriesname"];
        self.qicheid = [aDecoder decodeObjectForKey:@"qicheid"];
        self.registrationid = [aDecoder decodeObjectForKey:@"registrationid"];
        self.imei = [aDecoder decodeObjectForKey:@"imei"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        
        
        
        self.chepaino = [aDecoder decodeObjectForKey:@"chepaino"];
        self.vin = [aDecoder decodeObjectForKey:@"vin"];
        self.carseriesid = [aDecoder decodeObjectForKey:@"carseriesid"];
        self.carstyleid = [aDecoder decodeObjectForKey:@"carstyleid"];
        
    }
    
    return self;
}

+ (XMUser *)user
{
    
    return [self shareInstance];//!< 返回单例
    
    /*
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:ACCOUNTPATH];
    
    XMUser *account = nil;
    
    if (isExist)
    {
        account = [NSKeyedUnarchiver unarchiveObjectWithFile:ACCOUNTPATH];
    }
    
    
    return account;
    */
}

+ (instancetype)shareInstance{
    
    //!< 如果单例不存在，
    if (userInstance == nil)
    {
        
        userInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:ACCOUNTPATH];
        
    }

    return userInstance;

}

+(void)save:(XMUser *)user
{
    
//    [[NSFileManager defaultManager] removeItemAtPath:ACCOUNTPATH error:nil];
    
    [NSKeyedArchiver archiveRootObject:user toFile:ACCOUNTPATH];
    
    //-- 保存用户类型
    [[NSUserDefaults standardUserDefaults] setInteger:user.typeId forKey:@"typeId"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    userInstance = user;//修改单例的值

    
}



+ (instancetype)userWithDictionary:(NSDictionary *)dic
{
    
    //-- 消除字典中的NSNull
    NSMutableDictionary *dic_M = [NSMutableDictionary dictionaryWithCapacity:dic.allKeys.count];
    
    for (NSString *key in dic.allKeys)
    {
        id obj = [dic objectForKey:key];
        
        if ([obj isKindOfClass:[NSNull class]])
        {
            obj = @"";
        }
        
        [dic_M setObject:obj forKey:key];
    }
    
    
    
    return [[self alloc]initWithDictionary:dic_M];


}

- (instancetype)initWithDictionary:(NSDictionary *)dic

{
    self = [super init];
    if (self)
    {
        self.userid = [dic[@"userid"] integerValue];
        self.mobil = dic[@"mobil"];
        self.registrationid = dic[@"registrationid"];
        self.password = dic[@"password"];
        self.typeId = [dic[@"typeid"] integerValue];
        self.role_id = [dic[@"role_id"] integerValue];
        self.companyid = [dic[@"companyid"] integerValue];
        self.qicheid = dic[@"qicheid"];
        self.tboxid = dic[@"tboxid"];
        self.chepaino = dic[@"chepaino"];
        self.imei = dic[@"imei"];
        self.vin = dic[@"vin"];
        self.carbrandid = dic[@"carbrandid"];
        self.carseriesid = dic[@"carseriesid"];
        self.carstyleid = dic[@"carstyleid"];
        self.secretflag = [dic[@"secretflag"] integerValue];
        self.brandname = dic[@"brandname"];
        self.seriesname = dic[@"seriesname"];
        self.stylename = dic[@"stylename"];
        
       
        
        
    }
    
    return self;

}


/**
 退出登录时候，删除用户信息使用
 */
+ (void)deleteUserData{

    [[NSFileManager defaultManager] removeItemAtPath:ACCOUNTPATH error:nil];
    
    userInstance = nil;//销毁单例

}


- (void)dealloc
{

    XMLOG(@"---------用户已销毁---------");
    
}

@end


