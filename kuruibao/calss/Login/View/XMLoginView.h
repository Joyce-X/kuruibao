//
//  XMLoginView.h
//  kuruibao
//
//  Created by x on 16/9/30.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMLoginView;

@protocol XMLoginViewDelegate<NSObject>

@required

/**
 *  点击忘记密码按钮
 *
 *
 */
- (void)loginViewDidClickLosePwdBtn:(XMLoginView *)loginView;


/**
 *
 *  点击用户协议
 *
 */
- (void)loginViewDidClickUserProtocolBtn:(XMLoginView *)loginView;

/**
 *  通知代理执行登录操作
 *
 *
 */
- (void)loginViewDidClickLoginBtn:(XMLoginView *)loginView phineNumber:(NSString *)phoneNumber pwd:(NSString *)pwd;


@end

@interface XMLoginView : UIView

@property (nonatomic,weak)id<XMLoginViewDelegate> deleagte;

@property (copy, nonatomic) NSString *phoneNumber;//!< 电话号码
@property (copy, nonatomic) NSString *pwd;

@end
