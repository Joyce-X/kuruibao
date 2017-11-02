//
//  XMBaiduLocationModel.m
//  kuruibao
//
//  Created by X on 2017/6/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMBaiduLocationModel.h"

#import "AFNetworking.h"

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

#import "XMUser.h"

@interface XMBaiduLocationModel()

@property (nonatomic,strong)AFHTTPSessionManager* session;


@end

@implementation XMBaiduLocationModel


+ (instancetype)defaultWithDictionary:(NSDictionary *)dic
{
    
    
    return [[self alloc] initWithDictionary:dic];
    
    
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
        //!< 间隔3分钟左右 更新位置信息
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [NSTimer scheduledTimerWithTimeInterval:arc4random_uniform(20) + 180 repeats:YES block:^(NSTimer * _Nonnull timer) {
                
                [self setTboxid:self.tboxid];
                
                XMLOG(@"---------%@已经更新位置信息---------",self.chepaino);
                
            }];
            
        });
        
    }

    return self;

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


#pragma mark --setter


- (void)setTboxid:(NSString *)tboxid
{
    _tboxid = tboxid;
    
    if (tboxid.integerValue == 0)
    {
        [self requestLocation_current];
        
    }else
    {
    
        [self requestLocation];

    }
}




#pragma mark --lazy

-(AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        _session.requestSerializer.timeoutInterval = 10;
    }
    return _session;
    
}

- (void)requestLocation_current
{
    
    //!< 获取车辆当前位置
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"q_location&Qicheid=%@",self.qicheid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([result isEqualToString:@"0"])
        {
            
//            XMLOG(@"Joyce---------%@---------%@",urlStr,self.chepaino);
            self.noLocation = YES;
            
        }else if([result isEqualToString:@"-1"])
        {
            XMLOG(@"XMBaiduLocationModel--参数类型或者网络错误");
            
        }else
        {
            //!< 获取最近10条位置信息成功，只取出第一条来显示位置信息
            
            NSDictionary *locationDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            if ([locationDic[@"locationy"] isEqualToString:@"36.7"] && [locationDic[@"locationx"] isEqualToString:@"-119.7"] ) {
                
                XMLOG(@"Joyce---------%@，%@---------",locationDic[@"locationx"],locationDic[@"locationy"]);
                //!< 过滤掉美国的坐标
                return;
            }
            
            
           
            //!< gps坐标转换百度坐标
            CLLocationCoordinate2D gpsCoordinate = CLLocationCoordinate2DMake([locationDic[@"locationy"] doubleValue], [locationDic[@"locationx"] doubleValue]);
            
            NSDictionary *encryptDic = BMKConvertBaiduCoorFrom(gpsCoordinate, BMK_COORDTYPE_GPS);
            
            CLLocationCoordinate2D baiduCoordinate = BMKCoorDictionaryDecode(encryptDic);
            
            self.annotation = [[XMBaiduAnnotation alloc]init];
            
            //!< 设置坐标
            self.annotation.coordinate = baiduCoordinate;
            
            //!< 设置显示的时间
            self.annotation.deadLine = locationDic[@"dthappen"];
            
            //!< 设置汽车的品牌编号
            self.annotation.brindId = self.carbrandid.integerValue;
            
            //!< 设置车牌号
            self.annotation.carNumber = self.chepaino;
            
            //-- 如果是个人用户，就判断是否在线
            if(!isCompany)
            {
                [self sendCheckCommand];
                
            }else
            {
                //!< 企业用户，设置行驶状态，0停驶 1行驶 2失联
                self.annotation.showName = self.showName;
                
            }
            XMLOG(@"XMBaiduLocationModel--获取位置信息成功");
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"XMBaiduLocationModel--网络连接失败");
        
    }];


}

- (void)requestLocation
{
    
        //!< 获取最近十条位置信息
        NSString *urlStr = [mainAddress stringByAppendingFormat:@"q_run_gpsinfo&Qicheid=%@&Tboxid=%@",self.qicheid,self.tboxid];
    
        [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if ([result isEqualToString:@"0"])
            {
                XMLOG(@"XMBaiduLocationModel---没有获取到位置信息");
                
            }else if([result isEqualToString:@"-1"])
            {
                XMLOG(@"XMBaiduLocationModel--参数类型或者网络错误");
                
            }else
            {
                //!< 获取最近10条位置信息成功，只取出第一条来显示位置信息
                
                NSArray *locationArr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                
                NSDictionary *locationDic = [locationArr firstObject];
                
              
                
                //!< gps坐标转换百度坐标
                CLLocationCoordinate2D gpsCoordinate = CLLocationCoordinate2DMake([locationDic[@"locationy"] doubleValue], [locationDic[@"locationx"] doubleValue]);
                
                NSDictionary *encryptDic = BMKConvertBaiduCoorFrom(gpsCoordinate, BMK_COORDTYPE_GPS);
                
                CLLocationCoordinate2D baiduCoordinate = BMKCoorDictionaryDecode(encryptDic);
                
                self.annotation = [[XMBaiduAnnotation alloc]init];
                
                //!< 设置坐标
                self.annotation.coordinate = baiduCoordinate;
                
                //!< 设置显示的时间
                self.annotation.deadLine = locationDic[@"dthappen"];
              
                //!< 设置汽车的品牌编号
                self.annotation.brindId = self.carbrandid.integerValue;
                
                //!< 设置车牌号
                self.annotation.carNumber = self.chepaino;
                
                //-- 如果是个人用户，就判断是否在线
                if(!isCompany)
                {
                    [self sendCheckCommand];
                    
                }else
                {
                    //!< 企业用户，设置行驶状态，0停驶 1行驶 2失联
                    self.annotation.showName = self.showName;
                
                }
                 XMLOG(@"XMBaiduLocationModel--获取位置信息成功");
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            XMLOG(@"XMBaiduLocationModel--网络连接失败");
            
        }];
        
        
    

    
    
}

//!< 发送检测指令，判断终端是否在线
- (void)sendCheckCommand
{
    
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"sendcommand&userid=%ld&qicheid=%@&tboxid=%@&commandtype=50&subtype=0",[XMUser user].userid,_qicheid,_tboxid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        int result = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
        
       
        
        if (result == 0 || result == -1)
        {
            XMLOG(@"发送检测指令时，终端不在线");
            
            self.showName = @"停驶";
            
            
        }else
        {
            XMLOG(@"发送检测指令时，终端在线" );
             self.showName = @"行驶";
            
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"网络错误");
        
        
    }];
    
    
}

- (void)setShowName:(NSString *)showName
{
    _showName = showName;
    
    self.annotation.showName = showName;

}


@end
