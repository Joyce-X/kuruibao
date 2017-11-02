//
//  XMCommonView.h
//  kuruibao
//
//  Created by x on 16/12/6.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMCommonView;

@protocol XMCommonViewDelegate <NSObject>

/*!
 @brief 点击常用地址视图
 */
- (void)commonViewDidClick:(XMCommonView *)view;


/*!
 @brief 点击常用地址的导航按钮
 */
- (void)commonViewNaviBtnDidClick:(XMCommonView *)view;


/*!
 @brief 触发长按手势
 */
- (void)commonViewDidTriggerLongPress:(XMCommonView *)view;

@end

@interface XMCommonView : UIView

@property (strong, nonatomic) UIImage *image;//!< 显示的图片

@property (copy, nonatomic) NSString *address;//!< 显示的地址

@property (nonatomic,weak)id<XMCommonViewDelegate> delegate;

@end
