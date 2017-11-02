//
//  XMScrollView.h
//  kuruibao
//
//  Created by x on 17/5/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMScrollView : UIView

/**
 是否正在动画
 */
@property (assign, readonly,nonatomic) BOOL isAnimating;

/**
 是否支持用户滑动
 */
@property (assign, nonatomic) BOOL canScrool;

/**
 开始动画
 */
- (void)move;


/**
 停止动画
 */
- (void)stop;


/**
 设置各项参数
 */
- (void)setParas:(NSDictionary *)dic;


/**
 设置滚动速率

 @param rate 速度 区间为1~10
 */
- (void)setAnimatRate:(CGFloat)rate;


/**
 清空数据
 */
- (void)clearData;

@end
