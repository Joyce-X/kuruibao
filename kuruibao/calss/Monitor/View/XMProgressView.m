//
//  ProgressView.m
//  CircleAnimationTest
//
//  Created by ly on 15/11/6.
//  Copyright (c) 2015年 zmit. All rights reserved.
//

/***********************************************************************************************
 此类专门来描述体检得分
 
 
 ************************************************************************************************/

#import "XMProgressView.h"

 
@interface XMProgressView()


{
    
//    NSMutableString * str;
//    NSString *resultStr;
}


/**
 *  绘制颜色
 */
@property (nonatomic,strong)UIColor* color_stroke;


/**
 *  底色
 */
@property (nonatomic,strong)UIColor* color_background;



/**
 *  大小
 */
@property (nonatomic,assign) CGRect rect;


//创建全局属性
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer2;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic,assign) float currentValue;
@property (nonatomic,assign) int  increase;
//@property(nonatomic,strong)UIView* roundView;

@end

@implementation XMProgressView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        self.backgroundColor = [UIColor clearColor];
    
    }
    
    return self;
}

/**
 *  向外界提供接口，重绘
 */
- (void)setPercent:(float)percent{
     self.scoer =  percent;
     [self setNeedsDisplay];
}


/**
 *  显示的时候调用进行绘制
 */
- (void)drawRect:(CGRect)rect
{
    [self initData];
}


/**
 *  初始化数据
 */
- (void)initData {
    
     
    
    self.rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);;
    self.color_background = XMColor(184, 186, 192)
    ;
    _increase = 0;
    
    [self circleAnimationTypeOne];
    
    if (self.scoer >0) {
        [self animation];
    }
    
   _timer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(numShow) userInfo:nil repeats:YES];
    
    
}


- (void)circleAnimationTypeOne
{
    
    //创建出CAShapeLayer（底色layer）
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = self.rect;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //设置线条的宽度和颜色
    self.shapeLayer.lineWidth = self.lineWidth; //->>线宽
    self.shapeLayer.strokeColor = self.color_background.CGColor;//->>底色
    
    
    //创建出圆形贝塞尔曲线
    UIBezierPath* circlePath=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.rect.size.width / 2, self.rect.size.height / 2 )radius:self.rect.size.height / 2 startAngle:M_PI_2 endAngle:2.5*M_PI  clockwise:YES];
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer.path = circlePath.CGPath;
    
    //添加并显示
    [self.layer addSublayer:self.shapeLayer];
    
    
    
    
    
    //->>浮层layer
    
    UIBezierPath* circlePath2=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.rect.size.width / 2, self.rect.size.height / 2 )radius:self.rect.size.height / 2 startAngle:M_PI_2 endAngle:2*M_PI*_scoer+M_PI_2 clockwise:YES];
    
    
    
    //创建出CAShapeLayer
    self.shapeLayer2 = [CAShapeLayer layer];
    self.shapeLayer2.frame = self.rect;
//    self.shapeLayer2.lineJoin = @"round";
    self.shapeLayer2.fillColor = [UIColor clearColor].CGColor;
    
    //设置线条的宽度和颜色
    self.shapeLayer2.lineWidth = self.lineWidth;
    self.shapeLayer2.strokeColor =  self.color_stroke.CGColor;
    
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer2.path = circlePath2.CGPath;
    
    //添加并显示
    [self.layer addSublayer:self.shapeLayer2];
    
    //
    //    UIView* view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    //    view.center = CGPointMake(self.rect.size.width / 2, self.rect.size.height);
    //    view.layer.cornerRadius=10;
    //    view.layer.masksToBounds=YES;
    //    view.backgroundColor= kCColor(0,174,239);
    //    _roundView=view;
    //    [self addSubview:view];
    
}
- (void)animation {
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 4 * self.scoer;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1];
    pathAnimation.autoreverses = NO;
//
    
//    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    keyAnimation.path=self.shapeLayer2.path;
//    keyAnimation.fillMode = kCAFillModeForwards;
//    keyAnimation.calculationMode = kCAAnimationPaced;
//    keyAnimation.duration = 4*self.scoer;
//    keyAnimation.removedOnCompletion = NO;
    [self.shapeLayer2 addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    //    [_roundView.layer addAnimation:keyAnimation forKey:nil];
}




- (void) numShow {
    
    if (self.scoer < 0) {
        
        [_timer invalidate];
        return;
    }
    if (self.scoer <= 0.01) {
        
        [_timer invalidate];
        return;
    }
    if (_increase >=100*self.scoer) {
        [_timer invalidate];
        return;
    }
    _increase += 1;
    [self.delegate shouldSetText:[NSString stringWithFormat:@"%d",_increase]];
    
}


/**
 *  设置分数，同时设置绘制颜色
 */
- (void)setScoer:(float)scoer
{
    UIColor *color = nil;
    
    if (scoer < 70)
    {
         color = XMRedColor;
        
    }else if(scoer < 100)
    {
        color = XMBlueColor;

    
    }else
    {
        
        color = XMGreenColor;

    
    }
    
    self.color_stroke = color;
    
    _scoer = scoer / 100.0;

}

@end




