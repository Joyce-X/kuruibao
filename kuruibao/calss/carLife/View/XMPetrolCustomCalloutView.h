//
//  XMPetrolCustomCalloutView.h
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
  custom callout view of custom annotationView in petrol module
 
 ************************************************************************************************/

#import <UIKit/UIKit.h>

#import "XMNearbyPetrolItemModel.h"

@interface XMPetrolCustomCalloutView : UIView

//@property (copy, nonatomic) NSString *petrolStationName;
//
//@property (copy, nonatomic) NSString *petrolStationAddress;
//
//@property (copy, nonatomic) NSString *brandName;
//
//@property (strong, nonatomic) XMPetrolPriceModel *priceModel;
//
//@property (strong, nonatomic) XMGastpriceModel *gastpriceModel;

@property (strong, nonatomic) XMNearbyPetrolItemModel *model;

@property (nonatomic,weak)UIButton* naviBtn;//-- navi

@end
