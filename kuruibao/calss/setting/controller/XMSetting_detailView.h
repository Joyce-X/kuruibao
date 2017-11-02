//
//  XMSetting_detailView.h
//  kuruibao
//
//  Created by x on 16/9/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^setting)();

@protocol XMSetting_detailViewDelegate <NSObject>

//!< 点击消息推送按钮
- (void)pushMessageBtnDidClick:(UIButton *)sender;

@end


@interface XMSetting_detailView : UIView
/**
 *  点击账号设置
 */
@property (nonatomic,copy)setting setAccount;
/**
 *  点击离线地图
 */
@property (nonatomic,copy)setting offLineMap;
/**
 *  点击帮助
 */
@property (nonatomic,copy)setting helping;
/**
 *  点击用户反馈
 */
@property (nonatomic,copy)setting userBack;

@property (assign, nonatomic) BOOL isSelected;//!< 是否选中按钮
 
/**
 *  点击好评
 */
@property (nonatomic,copy)setting haoPing;

@property (nonatomic,weak)id<XMSetting_detailViewDelegate> delegate;

+ (instancetype)shared;
@end
