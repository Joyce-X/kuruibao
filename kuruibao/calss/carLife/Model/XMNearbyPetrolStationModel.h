//
//  XMNearbyPetrolStationModel.h
//  kuruibao
//
//  Created by x on 17/4/20.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMNearbyPetrolStationResultModel.h"

@interface XMNearbyPetrolStationModel : NSObject

@property (copy, nonatomic) NSString *resultcode;

@property (copy, nonatomic) NSString *reason;

@property (strong, nonatomic) XMNearbyPetrolStationResultModel *result;

@property (assign, nonatomic) int error_code;
@end



    
