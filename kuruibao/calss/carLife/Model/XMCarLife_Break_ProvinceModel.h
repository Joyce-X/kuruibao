//
//  XMCarLife_Break_ProvinceModel.h
//  kuruibao
//
//  Created by x on 17/5/13.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMCarLife_Break_CityModel.h"

#import "MJExtension.h"

@interface XMCarLife_Break_ProvinceModel : NSObject

@property (copy, nonatomic) NSString *province;

@property (strong, nonatomic) NSArray <XMCarLife_Break_CityModel *> *citys;
@end
