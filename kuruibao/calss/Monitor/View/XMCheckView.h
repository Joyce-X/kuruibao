//
//  XMCheckView.h
//  kuruibao
//
//  Created by x on 16/11/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMCheckViewDelegate  <NSObject>

@optional
/*
 *  完成检测通知代理
 */

- (void)checkViewDidEndCheck;


/**
 *
 *  将要开始检测第几项数据
 */

- (void)checkViewWillStartItem:(NSInteger)index;

@end

@interface XMCheckView : UIView

@property (nonatomic,weak)UILabel* messageLabel;//!< 显示正在检测的文字

@property (nonatomic,weak)id<XMCheckViewDelegate> delegate;

- (instancetype)initWithDelegate:(id<XMCheckViewDelegate>)delegate;

@end
