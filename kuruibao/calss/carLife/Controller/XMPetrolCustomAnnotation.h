//
//  XMPetrolCustomAnnotation.h
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
 custom annotation in petrol station module
 
 ************************************************************************************************/
#import <MAMapKit/MAMapKit.h>
#import "XMNearbyPetrolItemModel.h"

@interface XMPetrolCustomAnnotation : MAPointAnnotation

@property (strong, nonatomic) XMNearbyPetrolItemModel *model;

@end
