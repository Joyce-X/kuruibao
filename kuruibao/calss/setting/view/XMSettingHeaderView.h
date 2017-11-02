//
//  XMSettingHeaderView.h
//  kuruibao
//
//  Created by x on 16/8/3.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMSettingHeaderView;



@protocol XMSettingHeaderViewDelegate <NSObject>


/**
 *  点击头像时候，通知代理去切换控制器（tableview 发送通知切换控制器）
 *
 *
 */

- (void)headerViewDidClick:(XMSettingHeaderView *)headerView;

@end

@interface XMSettingHeaderView : UIView

/**
 *  头像
 */
@property (nonatomic,strong)UIImage* headerImage;


/**
 *  昵称
 */
@property (nonatomic,copy)NSString* nickName;



@property (nonatomic,weak)id<XMSettingHeaderViewDelegate> delegate;


//->>提供接口设置图片
- (void)updateHeaderImage;



@end














