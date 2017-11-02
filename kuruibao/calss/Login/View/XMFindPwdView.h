//
//  XMFindPwdView.h
//  kuruibao
//
//  Created by x on 16/10/2.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMFindPwdView;
@protocol XMFindPwdViewDelegate <NSObject>

/**
 *  点击获取验证码按钮，通知控制器发送验证码
 *  para  电话号码
 *
 */
- (void)findPwdView:(XMFindPwdView*)findView didClickGetVerifyCodeBtnWithPhoneNumber:(NSString *)phoneNumber;


/**
 *  点击完成按钮  通知控制器更新密码
 *  账号
 *  密码 验证码
 */
- (void)findPwdView:(XMFindPwdView*)findView didClickFinishBtnWithPhoneNumber:(NSString *)phoneNumber pwd:(NSString *)pwd mask:(NSString *)mask;


@end

@interface XMFindPwdView : UIView

@property (nonatomic,weak)id<XMFindPwdViewDelegate> delegate;

@property (assign, nonatomic) BOOL isShowTimer;//!< 是否显示倒计时label
@property (copy, nonatomic) NSString *labelText;//!< 倒计时文字
@property (copy, nonatomic) NSString *buttonText;//!< 按钮文字

@end
