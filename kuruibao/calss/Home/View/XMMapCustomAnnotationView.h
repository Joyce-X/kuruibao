//
//  XMMapCustomAnnotationView.h
//  kuruibao
//
//  Created by x on 16/11/27.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <AMapNaviKit/AMapNaviKit.h>
#import "XMMapCustomCalloutView.h"

@interface XMMapCustomAnnotationView : MAAnnotationView

@property (nonatomic, readonly) XMMapCustomCalloutView *calloutView;


@end
