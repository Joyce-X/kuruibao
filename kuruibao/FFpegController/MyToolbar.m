//
//  MyToolbar.m
//  MyDemo
//
//  Created by 智恒创 on 16/6/16.
//  Copyright © 2016年 zxc. All rights reserved.
//

#import "MyToolbar.h"

@implementation MyToolbar


- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    UIImage *image = [UIImage imageNamed:@""];
    CGContextDrawImage(c, rect, image.CGImage);
}


@end
