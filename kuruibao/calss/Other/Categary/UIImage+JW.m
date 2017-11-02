//
//  UIImage+JW.m
//  音乐播放器
//
//  Created by X on 15/12/16.
//  Copyright © 2015年 ~X~. All rights reserved.
//

#import "UIImage+JW.h"

@implementation UIImage (JW)

 + (instancetype)circleImageWithName:(id )name borderWide:(CGFloat)width color:(UIColor *)color
{
     //--创建原图
    UIImage *image;
    if ([name isKindOfClass:[NSString class]])
    {
        image = [UIImage imageNamed:name];
    }else
    {
        image = name;
    }
    
    CGFloat margin = width;//!< 边距
    
    CGFloat radius = MIN(image.size.width, image.size.height)/2;//!< 半径
    
    UIGraphicsBeginImageContext(CGSizeMake(radius* 2, radius* 2));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, radius * 2, radius* 2));
    
    [color set];
    
    CGContextFillPath(context);
    
    CGContextAddEllipseInRect(context, CGRectMake(margin, margin, radius * 2 - margin * 2, radius * 2 - margin * 2));
    
    CGContextClip(context);
    
    [image drawInRect:CGRectMake(margin, margin, radius * 2 - margin * 2, radius * 2 - margin * 2)];
    CGContextFillPath(context);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return newImage;
  
}
@end
