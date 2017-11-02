//
//  XMFMView.h
//  kuruibao
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
 自定义View 来展示音乐电台模块的内容
 
 ************************************************************************************************/
#import <UIKit/UIKit.h>
#import "XMTrack.h"
@protocol XMFMViewDelegate;

@interface XMFMView : UIView

@property (weak, nonatomic) id<XMFMViewDelegate> delegate;

//!< 显示的数据模型
@property (strong, nonatomic) NSArray *items;

@property (strong, nonatomic) XMTrack *track;

//!< show play view
- (void)showPlayView;

//!< stop play when start navi
- (void)stopPlay;


/**
 * @brief the animaton will auto diaappare when view disappare
 */
- (void)addAnimation;

@end

#pragma mark ------- XMFMViewDelegate

@protocol XMFMViewDelegate <NSObject>

@required

/**
 * @brief 通知代理刷新数据
 */
- (void)fmViewShouldRefreshItem:(XMFMView *)fmView ;

/**
 * @brief 点击某一个元素，通知控制器播放
 */
- (void)fmView:(XMFMView *)fmView itemClick:(UIView *)customView;


//!< 点击上一首
- (void)fmViewDidClickLastItem;

//!< 点击播放或暂停
- (void)fmViewDidClickPlayButton:(BOOL)isPlay;

//!< 点击下一首
- (void)fmViewDidClickNextItem;


@end
