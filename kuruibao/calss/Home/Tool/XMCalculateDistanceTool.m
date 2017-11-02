//
//  XMCalculateDistanceTool.m
//  kuruibao
//
//  Created by x on 16/11/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:计算两点之间的距离
 
 **********************************************************/

#import "XMCalculateDistanceTool.h"


@implementation XMCalculateDistanceTool


+ (NSArray *)calculateDistanceWithArray:(NSArray *)array startPoint:(CLLocationCoordinate2D)startPoint
{

    MAMapPoint start = MAMapPointForCoordinate(startPoint);
    
    for (AMapPOI *poi in array)
    {
        MAMapPoint endPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude));
        
        double distance =  MAMetersBetweenMapPoints(start, endPoint);

        poi.distance = distance;
        
       
    }
    
    return array;

    
}

@end
