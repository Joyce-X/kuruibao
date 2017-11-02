//
//  XMParkingCustomCalloutView.m
//  kuruibao
//
//  Created by x on 17/4/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMParkingCustomCalloutView.h"

#import "XMParkDetailSearchResultModel.h"

#import <MAMapKit/MAGeometry.h>

#define kArrorHeight        10

//#define kPortraitMargin     5
//#define kPortraitWidth      70
//#define kPortraitHeight     50
//
//#define kTitleWidth         120
//#define kTitleHeight        20
#define kColumnMargin  15

#define kRowMargin  13

#define kRowHeight  14

@interface XMParkingCustomCalloutView ()


@property (weak, nonatomic) UILabel *nameLabel;

@property (weak, nonatomic) UILabel *addressLabel;

@property (weak, nonatomic) UILabel *topLabel;

//@property (weak, nonatomic) UILabel *totalCountLabel;

//@property (weak, nonatomic) UILabel *leftCountLabel;

//@property (weak, nonatomic) UILabel *distanceLabel;

//@property (strong, nonatomic) UIView *activityView;

//@property (assign, nonatomic) float latitude;

//@property (assign, nonatomic) float longitude;

@end


@implementation XMParkingCustomCalloutView

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
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8].CGColor);
    
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
    
    //!< topLabel
    UILabel *topLabel = [self createLabelWithFrame:CGRectMake(18.5, 15.5, swidth - 27, 15) textColor:0xc5c5c5 font:18 title:nil alignment:1];
    
    [self addSubview:topLabel];
    
    self.topLabel = topLabel;
    
    
    CGFloat baseline = 31 + 15;
    
    //!< add nameLabel
    UILabel *name = [self createLabelWithFrame:CGRectMake(kColumnMargin, baseline, 40, kRowHeight) textColor:0xffffff font:13 title:@"名称" alignment:0];
    
    [self addSubview:name];
    
    UILabel *nameLabel = [self createLabelWithFrame:CGRectMake(45 + kColumnMargin, baseline, swidth - 45 - kColumnMargin * 2, kRowHeight) textColor:0xc5c5c5 font:13 title:@"" alignment:2];
    
    [self addSubview:nameLabel];
    
    self.nameLabel = nameLabel;
    
    //!< add address
    UILabel *address = [self createLabelWithFrame:CGRectMake(kColumnMargin, baseline + kColumnMargin + kRowHeight, 40, kRowHeight) textColor:0xffffff font:13 title:@"地址" alignment:0];
    
    [self addSubview:address];
    
    
    UILabel *addressLabel = [self createLabelWithFrame:CGRectMake(45 + kColumnMargin, baseline+ kColumnMargin + kRowHeight, swidth - 45 - kColumnMargin * 2, kRowHeight) textColor:0xc5c5c5 font:13 title:@"" alignment:2];
    
    [self addSubview:addressLabel];
    
    self.addressLabel = addressLabel;
    
    
    //!< add button
    UIButton *naviBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [naviBtn setBackgroundImage:[UIImage imageNamed:@"carLife_saveCar_startNavi_normal"] forState:UIControlStateNormal];
    
    [naviBtn setBackgroundImage:[UIImage imageNamed:@"carLife_saveCar_startNavi_highlight"] forState:UIControlStateHighlighted];
    
    [naviBtn setTitle:@"开始导航" forState:UIControlStateNormal];
    
    [naviBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [naviBtn setFont:[UIFont systemFontOfSize:14]];
    
    naviBtn.frame = CGRectMake(15,baseline + kRowHeight * 2 + kRowMargin * 1 + 13, swidth - 39, 35);
    
    [naviBtn addTarget:self action:@selector(naviBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    naviBtn.tag = 110;
    
    [self addSubview:naviBtn];
    
    self.naviBtn = naviBtn;
    
    
    
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



#pragma mark ------- btn click

- (void)naviBtnClick
{
    
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kXMNaviToPetrolStationNotification object:nil userInfo:@{@"info":self.superview,@"model":self.model}];
    
    XMLOG(@"******************************btn click*******************");
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMNaviToParkingStationNotification object:nil userInfo:@{@"info":self.superview,@"error":@0,@"latitude":@(self.model.WD.floatValue),@"longitude":@(self.model.JD.floatValue)}];
    
}



- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.naviBtn.frame, point))
    {
        
        //        [self removeFromSuperview];  ignore this step
        
//        [self naviBtnClick];
        
        //-- notify the map to deselect an annotationView
        return self.naviBtn;
        
    }
    
    return [super hitTest:point withEvent:event];
    
}
//
//- (void)setCCID:(NSString *)CCID
//{
//    _CCID = CCID;
//    
//     [self activityView];
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    manager.requestSerializer.timeoutInterval = 4;
//    
//    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
//    
//    paras[@"key"] = @"1a12913ca9de19f10c61db4f943be5f8";
//    
//    paras[@"CCID"] = CCID;
//
//    [manager POST:@"http://japi.juhe.cn/park/baseInfo.from" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        XMParkDetailSearchResultModel *model = [XMParkDetailSearchResultModel mj_objectWithKeyValues:responseObject];
//        
//        if (![model.reason isEqualToString:@"success"])
//        {
//            //!< let controller to deselect this annotationView, and show user reuest failed
//            [[NSNotificationCenter defaultCenter] postNotificationName:kXMNaviToParkingStationNotification object:nil userInfo:@{@"info":self.superview,@"error":@1}];
//            
//            return;
//        }
//        
//        [self.activityView removeFromSuperview];
//        
//        
//        XMParkDetailModel *dmodel = model.result.firstObject;
//        
//        self.latitude = dmodel.WD.floatValue;
//        
//        self.longitude = dmodel.JD.floatValue;
//        
//        _nameLabel.text = [NSString stringWithFormat:@"名称:%@",dmodel.CCMC];
//        
//        _addressLabel.text = [NSString stringWithFormat:@"地址:%@",dmodel.CCDZ];
//        
//        _typeLabel.text = [NSString stringWithFormat:@"类型:%@",dmodel.CCFL];
//        
//        _totalCountLabel.text = [NSString stringWithFormat:@"总车位:%@",dmodel.ZCW];
//        
//        _leftCountLabel.text = [NSString stringWithFormat:@"剩余车位:%@",dmodel.KCW];
//        
//        
//        //!< calculate distance
//        
//        
//        float latitude =  [[NSUserDefaults standardUserDefaults] floatForKey:@"parkLatitude"];
//        
//        float  longitude =  [[NSUserDefaults standardUserDefaults] floatForKey:@"parkLongitude"];
//        
//        //1.将两个经纬度点转成投影点
//        MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(dmodel.WD.floatValue,dmodel.JD.floatValue));
//        
//        MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(latitude,longitude));
//        
//        //2.计算距离
//        CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
//        
//        if(distance <= 1000)
//        {
//            _distanceLabel.text = [NSString stringWithFormat:@"距离:%.2f米",distance];
//
//        }else
//        {
//            distance = distance /1000.0;
//            
//            _distanceLabel.text = [NSString stringWithFormat:@"距离:%.1f公里",distance];
//            
//        
//        }
//        
//        
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        //!< let controller to deselect this annotationView, and show user reuest failed
//        [[NSNotificationCenter defaultCenter] postNotificationName:kXMNaviToParkingStationNotification object:nil userInfo:@{@"info":self.superview,@"error":@1}];
//        
//    }];
//    
//    
//    
//    
//    
//
//
//}

- (void)setModel:(XMParkStationModel *)model
{

    _model = model;
  
    self.nameLabel.text = model.CCMC;
    
    self.addressLabel.text = model.CCDZ;
    
    
    
    float scale = model.KCW.floatValue/model.ZCW.intValue;
   
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"目前空车位%@个 总车位%@个",model.KCW,model.ZCW]];
    
    NSRange range;
    
    if (model.KCW.floatValue < 10)
    {
        range = NSMakeRange(5,1);
        
    }else if (model.KCW.intValue < 100)
    {
        
        range = NSMakeRange(5,2);
     
    }else if (model.KCW.intValue < 1000)
    {
        
        range = NSMakeRange(5,3);
    
    }else
    {
        
        range = NSMakeRange(5,4);
        
    }
    
    
    if ( scale == 0)
    {
        [str addAttribute:NSForegroundColorAttributeName value:XMColorFromRGB(0xc5f5f5) range:range];
        
    }else if(scale >= 0.3)
    {
        [str addAttribute:NSForegroundColorAttributeName value:XMColorFromRGB(0x62d476) range:range];
    
    }else
    {
        [str addAttribute:NSForegroundColorAttributeName value:XMColorFromRGB(0xfc3768) range:range];
    
    }
    
   
    self.topLabel.attributedText = str;
    
}

@end
