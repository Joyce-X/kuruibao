//
//  XMPetrolCustomCalloutView.m
//  kuruibao
//
//  Created by x on 17/4/21.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMPetrolCustomCalloutView.h"

#define kArrorHeight        10

//#define kPortraitMargin     5
//#define kPortraitWidth      70
//#define kPortraitHeight     50
//
//#define kTitleWidth         120
//#define kTitleHeight        20

#define kColumnMargin  15

#define kRowMargin  13

#define kRowHeight  12.5

@interface XMPetrolCustomCalloutView ()


@property (weak, nonatomic) UILabel *nameLabel;

@property (weak, nonatomic) UILabel *addressLabel;

@property (weak, nonatomic) UILabel *brandLabel;

@property (weak, nonatomic) UILabel *E90Label;

@property (weak, nonatomic) UILabel *E93Label;

@property (weak, nonatomic) UILabel *E97Label;

//@property (weak, nonatomic) UILabel *E0Label;

//@property (weak, nonatomic) UILabel *nine2Label;

@property (weak, nonatomic) UILabel *nine5Label;

//@property (weak, nonatomic) UILabel *nine0Label;

//@property (weak, nonatomic) UILabel *distanceLabel;



@end


@implementation XMPetrolCustomCalloutView

- (void)drawRect:(CGRect)rect
{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    self.layer.shadowOpacity = 1.0;
    
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:0.7].CGColor);
    
    [self getDrawPath:context];
    
    CGContextFillPath(context);
    
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        [self initSubViews];
    }
    
    return self;
}

- (void)initSubViews
{
    
    CGFloat swidth = self.bounds.size.width;
    
    //!< new
    //!< titleLabel
    UILabel *brandLabel = [self createLabelWithFrame:CGRectMake(0, 15.5, swidth, 14.5) textColor:0xffffff font:18 title:nil alignment:1];
    
    [self addSubview:brandLabel];
    
    self.brandLabel = brandLabel;
    
    
    CGFloat baseLine = 45.5;
    
    CGFloat width = 80;
    
    CGFloat hight = 12.5;
    
    CGFloat font = 13;
    
    //!< nameLabel
    UILabel *name = [self createLabelWithFrame:CGRectMake(kColumnMargin, baseLine, width, hight) textColor:0xffffff font:font title:@"名称" alignment:0];
    
    [self addSubview:name];
    
    UILabel *nameLabel =  [self createLabelWithFrame:CGRectMake(90, baseLine + kRowHeight *0 + kRowMargin * 0, swidth-kColumnMargin -90, hight) textColor:0xc5c5c5 font:font title:nil alignment:3];
    
    [self addSubview:nameLabel];
    
    self.nameLabel = nameLabel;
    
    //!<  address Label
    UILabel *address = [self createLabelWithFrame:CGRectMake(kColumnMargin, baseLine + kRowHeight *1 + kRowMargin * 1, width, hight) textColor:0xffffff font:font title:@"地址" alignment:0];
    
    [self addSubview:address];
    
    UILabel *addressLabel =  [self createLabelWithFrame:CGRectMake(90, baseLine + kRowHeight *1 + kRowMargin * 1, swidth-kColumnMargin-90, hight) textColor:0xc5c5c5 font:font title:nil alignment:3];
    
    [self addSubview:addressLabel];
    
    self.addressLabel = addressLabel;
    
    
    //!<  E90 Label
    UILabel *E90 = [self createLabelWithFrame:CGRectMake(kColumnMargin, baseLine + kRowHeight *2 + kRowMargin * 2, width, hight) textColor:0xffffff font:font title:@"90#" alignment:0];
    
    [self addSubview:E90];
    
    UILabel *E90Label =  [self createLabelWithFrame:CGRectMake(swidth/2, baseLine + kRowHeight *2 + kRowMargin * 2, swidth/2-kColumnMargin, hight) textColor:0xc5c5c5 font:font title:nil alignment:3];
    
    [self addSubview:E90Label];
    
    self.E90Label = E90Label;
    
    
    //!<  E93 Label
    UILabel *E93 = [self createLabelWithFrame:CGRectMake(kColumnMargin, baseLine + kRowHeight *3 + kRowMargin * 3, width, hight) textColor:0xffffff font:font title:@"93#" alignment:0];
    
    [self addSubview:E93];
    
    UILabel *E93Label =  [self createLabelWithFrame:CGRectMake(swidth/2, baseLine + kRowHeight *3 + kRowMargin * 3, swidth/2-kColumnMargin, hight) textColor:0xc5c5c5 font:font title:nil alignment:3];
    
    [self addSubview:E93Label];
    
    self.E93Label= E93Label;
    
    
    //!< E95 Label
    UILabel *nine5 = [self createLabelWithFrame:CGRectMake(kColumnMargin, baseLine +  kRowHeight *4 + kRowMargin * 4, width, hight) textColor:0xffffff font:font title:@"95#" alignment:0];
    
    [self addSubview:nine5];
    
    UILabel *nine5Label =  [self createLabelWithFrame:CGRectMake(swidth/2, baseLine + kRowHeight *4 + kRowMargin * 4, swidth/2-kColumnMargin, hight) textColor:0xc5c5c5 font:font title:nil alignment:3];
    
    [self addSubview:nine5Label];
    
    self.nine5Label = nine5Label;
    
    //!<  97 Label
    UILabel *E97 = [self createLabelWithFrame:CGRectMake(kColumnMargin, baseLine + kRowHeight *5 + kRowMargin * 5, width, hight) textColor:0xffffff font:font title:@"97#" alignment:0];
    
    [self addSubview:E97];
    
    UILabel *E97Label =  [self createLabelWithFrame:CGRectMake(swidth/2, baseLine + kRowHeight *5 + kRowMargin * 5, swidth/2-kColumnMargin, hight) textColor:0xc5c5c5 font:font title:nil alignment:3];
    
    [self addSubview:E97Label];
    
    self.E97Label = E97Label;
    
    //!< add button
    UIButton *naviBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [naviBtn setBackgroundImage:[UIImage imageNamed:@"carLife_saveCar_startNavi_normal"] forState:UIControlStateNormal];
    
    [naviBtn setBackgroundImage:[UIImage imageNamed:@"carLife_saveCar_startNavi_highlight"] forState:UIControlStateHighlighted];

    [naviBtn setTitle:@"开始导航" forState:UIControlStateNormal];
    
    [naviBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [naviBtn setFont:[UIFont systemFontOfSize:14]];
    
    naviBtn.frame = CGRectMake(kColumnMargin + 5, baseLine + kRowHeight *6 + kRowMargin * 5 + 13, swidth - 39, 35);
    
    [naviBtn addTarget:self action:@selector(naviBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    naviBtn.tag = 110;
    
    [self addSubview:naviBtn];
    
    self.naviBtn = naviBtn;
    
    
    
    /**
    
    //!< old $$$$
    CGFloat width = self.bounds.size.width - kColumnMargin * 2;
    
    
    //!< add petrol station name
    UILabel *nameLabel = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowMargin, width, kRowHeight)];
    
    [self addSubview:nameLabel];
    
    self.nameLabel = nameLabel;
    
    //!< add address
    UILabel *addressLabel = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 1 + kRowMargin * 2, width, kRowHeight)];
    
    [self addSubview:addressLabel];
    
    self.addressLabel = addressLabel;
    
    //!< add brand
    UILabel *brandLabel = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 2 + kRowMargin * 3, width, kRowHeight)];
    
    [self addSubview:brandLabel];
    
    self.brandLabel = brandLabel;
    
    //!< add E90Label
    UILabel *E90Label = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 3 + kRowMargin * 4, width, kRowHeight)];
    
    [self addSubview:E90Label];
    
    self.E90Label = E90Label;
    
    //!< add E93Label
    UILabel *E93Label = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 4 + kRowMargin * 5, width, kRowHeight)];
    
    [self addSubview:E93Label];
    
    self.E93Label = E93Label;
    
    //!< add E97Label
    UILabel *E97Label = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 5 + kRowMargin * 6, width, kRowHeight)];
    
    [self addSubview:E97Label];
    
    self.E97Label = E97Label;
    
    //!< add E0Label
    UILabel *E0Label = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 6 + kRowMargin * 7, width, kRowHeight)];
    
    [self addSubview:E0Label];
    
    self.E0Label = E0Label;
    
    //!< add nine2Label
    UILabel *nine2Label = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 7 + kRowMargin * 8, width, kRowHeight)];
    
    [self addSubview:nine2Label];
    
    self.nine2Label = nine2Label;
    
    //!< add nine5Label
    UILabel *nine5Label = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 8 + kRowMargin * 9, width, kRowHeight)];
    
    [self addSubview:nine5Label];
    
    self.nine5Label = nine5Label;
    
    //!< add nine0Label
    UILabel *nine0Label = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 9 + kRowMargin * 10, width, kRowHeight)];
    
    [self addSubview:nine0Label];
    
    self.nine0Label = nine0Label;
    
    //!< add nine0Label
    UILabel *distanceLabel = [self createLabelWithFrame:CGRectMake(kColumnMargin, kRowHeight * 10 + kRowMargin * 11, width, kRowHeight)];
    
    [self addSubview:distanceLabel];
    
    self.distanceLabel = distanceLabel;
     
     */
    
 
    
//    [self bringSubviewToFront:naviBtn];
    
}

- (UILabel *)createLabelWithFrame:(CGRect)frame textColor:(int)color font:(float)font title:(NSString *)title alignment:(int)alignment
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    
    label.font = [UIFont systemFontOfSize:font];
    
    label.textColor = XMColorFromRGB(color);
    
    label.text = title;
    
    switch (alignment) {
            
        case 0:
            
            label.textAlignment = NSTextAlignmentLeft;
            
            break;
            
        case 1:
            
            label.textAlignment = NSTextAlignmentCenter;
            
            break;
     
            
        default:
            
            label.textAlignment = NSTextAlignmentRight;
            
            break;
    }
    
    return label;
}


- (void)setModel:(XMNearbyPetrolItemModel *)model
{

    _model = model;
    
    
    model.price.E90 = model.price.E90 ? model.price.E90 : @"暂无数据";
    
    model.price.E93 = model.price.E93 ? model.price.E93 : @"暂无数据";
    
    model.price.E97 = model.price.E97 ? model.price.E97 : @"暂无数据";
    
    model.price.E0 = model.price.E0 ? model.price.E0 : @"暂无数据";
    
    model.gastprice.nine2 = model.gastprice.nine2 ? model.gastprice.nine2 : @"暂无数据";
    
    model.gastprice.nine5 = model.gastprice.nine5 ? model.gastprice.nine5 : @"暂无数据";
    
    model.gastprice.zero = model.gastprice.zero ? model.gastprice.zero : @"暂无数据";
    
    self.nameLabel.text = model.name;
    
    self.addressLabel.text = model.address;
    
    self.brandLabel.text = model.brandname;
    
    self.E90Label.text = model.price.E90;
    
    self.E93Label.text = model.price.E93;
    
    self.E97Label.text = model.price.E97;
    
    self.nine5Label.text = model.gastprice.nine5;
    
    

}

#pragma mark ------- btn click

- (void)naviBtnClick
{
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMNaviToPetrolStationNotification object:nil userInfo:@{@"info":self.superview,@"model":self.model}];
    
//    XMLOG(@"******************************btn click*******************");
    
}



- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.naviBtn.frame, point))
    {
        
        
        
//        [self removeFromSuperview];  ignore this step
        
        [self naviBtnClick];
        
        //-- notify the map to deselect an annotationView
        return self.naviBtn;
        
    }
    
   return [super hitTest:point withEvent:event];
        
    
    
}

@end
