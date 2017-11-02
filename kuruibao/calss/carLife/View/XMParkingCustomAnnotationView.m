//
//  XMParkingCustomAnnotationView.m
//  kuruibao
//
//  Created by x on 17/4/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMParkingCustomAnnotationView.h"

#import "XMCarLife_SaveCarAnnotation.h"

#define kCalloutWidth       265.0
#define kCalloutHeight      162

@interface XMParkingCustomAnnotationView ()

@property (readwrite, nonatomic) XMParkingCustomCalloutView *calloutView;

@end

@implementation XMParkingCustomAnnotationView

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            self.calloutView = [[XMParkingCustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            XMCarLife_SaveCarAnnotation *anno = (XMCarLife_SaveCarAnnotation*)self.annotation;
            
            self.calloutView.model = anno.model;
            
             
            
        }
        
        
        [self addSubview:self.calloutView];
        
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
    
    
    
    
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    
    //    NSLog(@"hittest");
    UIView *view = [super hitTest:point withEvent:event];
    
    //    NSLog(@"%@----",view);
    
    //    if ([view isKindOfClass:[UIButton class]])
    //    {
    ////        self.calloutView = nil;
    //    }
    
    return view;
    
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    
//    NSLog(@"%@",NSStringFromCGRect(self.bounds));
//    NSLog(@"%@",NSStringFromCGRect(self.calloutView.frame));
    
    // -- the btn frame in self coordinate system
    CGRect frame = [self convertRect:self.calloutView.naviBtn.frame fromView:self.calloutView];
    
    if (CGRectContainsPoint(frame, point))
    {
        
        return YES;
        
    }else
    {
        
        return [super pointInside:point withEvent:event];
        
    }
    return YES;
}

@end
