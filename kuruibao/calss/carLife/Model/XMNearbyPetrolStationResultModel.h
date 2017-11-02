//
//  XMNearbyPetrolStationResultModel.h
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MJExtension.h"

#import "XMNearbyPetrolItemModel.h"

@interface XMNearbyPetrolStationResultModel : NSObject


@property (strong, nonatomic) NSArray <XMNearbyPetrolItemModel *> *data;//!< result array

@property (strong, nonatomic) NSDictionary  *pageinfo;//!< current page info

@end
