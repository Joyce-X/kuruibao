//
//  XMPetrolModuleCustomAnnotationView.h
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
 custom annotationView of petrol station module
 
 ************************************************************************************************/
#import <MAMapKit/MAMapKit.h>
#import "XMPetrolCustomCalloutView.h"

@interface XMPetrolModuleCustomAnnotationView : MAAnnotationView

@property (readonly, nonatomic) XMPetrolCustomCalloutView *calloutView;

@end
