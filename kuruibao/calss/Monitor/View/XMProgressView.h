//
//  XMProgressView.h
//  kuruibao
//
//  Created by x on 16/8/10.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMProgressViewDelegate <NSObject>

/**
 *  通知代理改变体检分数
 */
- (void)shouldSetText:(NSString *)text;

@end

@interface XMProgressView : UIView

/**
 *  通知代理改变体检得分
 */
@property (nonatomic,weak)id<XMProgressViewDelegate> delegate;

/**
 *  体检得分（绘制的比例）
 */
@property (nonatomic,assign) float scoer;

/**
 *  绘制起点
 */
@property (nonatomic,assign) float strokeStart;

/**
 *  百分比
 */
@property (nonatomic,assign) float percent;

/**
 *  绘制终点
 */
@property (nonatomic,assign) float strokeEnd;

/**
 *  线宽
 */
@property (nonatomic,assign) float lineWidth;



@end
