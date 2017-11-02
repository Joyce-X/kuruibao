//
//  XMMapCarLocationModel.m
//  kuruibao
//
//  Created by x on 16/11/27.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMMapCarLocationModel.h"
 #import <AMapFoundationKit/AMapFoundationKit.h>


@implementation XMMapCarLocationModel


- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    
    if (self)
    {
 
        
        self.locationx = [dic[@"locationx"] doubleValue];
        
        self.locationy = [dic[@"locationy"] doubleValue];
        
        NSString *time = dic[@"dthappen"];
        
        
        self.time = [time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        
        //!< 在内部进行坐标转换
        [self convertCoordinate];
        
    }

    return self;
}

- (void)convertCoordinate
{
    
    
    CLLocationCoordinate2D location = AMapCoordinateConvert(CLLocationCoordinate2DMake(self.locationy, self.locationx), AMapCoordinateTypeGPS);
    
    self.locationx = location.longitude;
    
    self.locationy = location.latitude;
    
 
    
//    static int i = 0;
//    i++;
//    
//    if (i%2)
//    {
//        self.locationy += 0.09;
//    }
//    
    
    
    

    
    
}

@end
