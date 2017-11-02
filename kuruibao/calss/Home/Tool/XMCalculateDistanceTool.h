//
//  XMCalculateDistanceTool.h
//  kuruibao
//
//  Created by x on 16/11/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
@interface XMCalculateDistanceTool : NSObject


/*!
 @brief 专门用来处理地图界面展示搜索列表时候的距离
 */
+ (NSArray *)calculateDistanceWithArray:(NSArray *)array startPoint:(CLLocationCoordinate2D)startPoint;

@end
