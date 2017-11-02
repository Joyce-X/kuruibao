//
//  XMNearbyPetrolItemModel.h
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPetrolPriceModel.h"

#import "XMGastpriceModel.h"

@interface XMNearbyPetrolItemModel : NSObject

@property (copy, nonatomic) NSString *ID;

@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *area;

@property (copy, nonatomic) NSString *areaname;

@property (copy, nonatomic) NSString *address;

@property (copy, nonatomic) NSString *brandname;

@property (copy, nonatomic) NSString *type;

@property (copy, nonatomic) NSString *discount;

@property (copy, nonatomic) NSString *exhaust;

@property (copy, nonatomic) NSString *position;

@property (copy, nonatomic) NSString *lon;

@property (copy, nonatomic) NSString *lat;

@property (copy, nonatomic) NSString *fwlsmc;

@property (assign, nonatomic) int distance;

@property (strong, nonatomic) XMPetrolPriceModel *price;

@property (strong, nonatomic) XMGastpriceModel *gastprice;

@end


