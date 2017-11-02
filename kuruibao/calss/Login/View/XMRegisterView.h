//
//  XMRegisterView.h
//  kuruibao
//
//  Created by x on 16/9/30.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMRegisterViewDelegate <NSObject>

/**
 *  点击获取验证码按钮，通知控制器发送验证码
 *  para  电话号码
 *
 */
- (void)registerViewDidClickGetVerifyCodeBtnWithPhoneNumber:(NSString *)phoneNumber;


/**
 *  点击注册按钮
 *  账号
 *  密码
 */

- (void)registerViewDidClickRegisterBtnWithPhoneNumber:(NSString *)phoneNumber pwd:(NSString *)pwd verifyCode:(NSString *)verifyCode;


@end

@interface XMRegisterView : UIView

@property (nonatomic,weak)id<XMRegisterViewDelegate> delegate;

@property (assign, nonatomic) BOOL isShowTimer;//!< 是否显示倒计时label
@property (copy, nonatomic) NSString *labelText;//!< 倒计时文字
@property (copy, nonatomic) NSString *buttonText;//!< 按钮文字

@end
