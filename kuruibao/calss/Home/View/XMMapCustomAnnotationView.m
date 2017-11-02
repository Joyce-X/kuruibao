//
//  XMMapCustomAnnotationView.m
//  kuruibao
//
//  Created by x on 16/11/27.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMMapCustomAnnotationView.h"
#import "XMMapCustomAnnotation.h"


#define kCalloutWidth       220.0
#define kCalloutHeight      90.0

@interface XMMapCustomAnnotationView ()

@property (nonatomic, strong, readwrite) XMMapCustomCalloutView *calloutView;

@end

@implementation XMMapCustomAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



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
            self.calloutView = [[XMMapCustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        
        if ([self.annotation isKindOfClass:[XMMapCustomAnnotation class]])
        {
            XMMapCustomAnnotation *anno = (XMMapCustomAnnotation *)self.annotation;
            
            NSString *imageName = [NSString stringWithFormat:@"%@.jpg",anno.carBrandId];
            
            UIImage *image = [UIImage imageNamed:imageName];
            
            self.calloutView.image = image? image : [UIImage imageNamed:@"companyList_placeholderImahe"];
            
            
            
            self.calloutView.time = anno.time;
            
        }else
        {
            self.calloutView.image = [UIImage imageNamed:@"2.jpg"];
         
        }
        
               self.calloutView.title = self.annotation.title;
        self.calloutView.subtitle = self.annotation.subtitle;
        
        
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}
@end
