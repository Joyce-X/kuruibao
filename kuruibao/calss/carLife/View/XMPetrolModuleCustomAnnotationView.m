//
//  XMPetrolModuleCustomAnnotationView.m
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMPetrolModuleCustomAnnotationView.h"

#import "XMPetrolCustomAnnotation.h"

#define kCalloutWidth       265.0   //200
#define kCalloutHeight      255        //253.0 + 23 + 23

@interface XMPetrolModuleCustomAnnotationView ()

@property (readwrite, nonatomic) XMPetrolCustomCalloutView *calloutView;

@end

@implementation XMPetrolModuleCustomAnnotationView

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
            self.calloutView = [[XMPetrolCustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            XMPetrolCustomAnnotation *anno = self.annotation;
          
            self.calloutView.model = anno.model;
            
            self.leftCalloutAccessoryView = self.calloutView.naviBtn;
            
         }
        
         
        [self addSubview:self.calloutView];
//        self.calloutView = nil;
        
        
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

    NSLog(@"%@",NSStringFromCGRect(self.bounds));
    NSLog(@"%@",NSStringFromCGRect(self.calloutView.frame));
    
    //-- the btn frame in self coordinate system
    CGRect frame = [self convertRect:self.calloutView.naviBtn.frame fromView:self.calloutView];
    
    if (CGRectContainsPoint(frame, point))
    {
        
        return YES;
        
    }else
    {
    
        return [super pointInside:point withEvent:event];

    }
}


@end
