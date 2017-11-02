//
//  UIImage+color.m
//  kuruibao
//
//  Created by x on 16/7/13.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
 
#import "UIImage+color.h"

@implementation UIImage (color)

+(instancetype)creatImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;

}

@end
