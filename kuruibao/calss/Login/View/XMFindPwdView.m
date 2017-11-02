//
//  XMFindPwdView.m
//  kuruibao
//
//  Created by x on 16/10/2.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMFindPwdView.h"
#import "UIView+alert.h"

@interface XMFindPwdView()

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;//!< 电话
@property (weak, nonatomic) IBOutlet UITextField *verifyTF;//!< 验证码

@property (weak, nonatomic) IBOutlet UITextField *pwdTF;//!< 密码
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;//!< 倒计时
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;//!< 获取验证码
@property (nonatomic,weak)UIView* coverView;//分类属性
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;//!< 完成按钮

@end

@implementation XMFindPwdView

//!< 获取验证码
- (IBAction)getCodeBtnClick:(id)sender {
    
    //!< 判断手机号码是否正确，错误提示手机号码不正确，正确通知控制器发送验证码
    
    
    //!< 验证是否输入手机号码
    if (_phoneTF.text.length == 0)
    {
        [self showAlertWithMessage:@"请输入手机号码" btnTitle:@"确定"];
        return;
    }
    
    
    //!< 判断手机号码正确性
    if(![self validateMobile:_phoneTF.text])
    {
        [self showAlertWithMessage:@"手机号码格式不正确" btnTitle:@"确定"];
        return;
    }
    
    //!< 通知代理发送验证码
    if (self.delegate && [self.delegate respondsToSelector:@selector(findPwdView:didClickGetVerifyCodeBtnWithPhoneNumber:)])
    {
        [self.delegate findPwdView:self didClickGetVerifyCodeBtnWithPhoneNumber:_phoneTF.text];
    }

}

//!< 完成

- (IBAction)finishBtnClick:(id)sender {
    
    //!< 判断电话号码是否为空，是否合法，密码是否为空，是否合法
    
    //!< 电话是否为空
    if(_phoneTF.text.length == 0)
    {
        [self showAlertWithMessage:@"请输入电话号码" btnTitle:@"确定"];
        return;
        
    }
    
    //!< 电话是否合法
    if(![self validateMobile:_phoneTF.text])
    {
        [self showAlertWithMessage:@"手机号码格式错误" btnTitle:@"确定"];
        return;
        
    }
    
    //!< 4位验证码
    
    if (_verifyTF.text.length != 4)
    {
        [self showAlertWithMessage:@"请输入4位验证码" btnTitle:@"确定"];
        return;
        
    }
    
    
    //!< 密码是否为空
    if(_pwdTF.text.length == 0)
    {
        [self showAlertWithMessage:@"请输入密码" btnTitle:@"确定"];
        return;
        
    }
    
    //!< 密码是否合法
    if(_pwdTF.text.length < 6 || _pwdTF.text.length > 20)
    {
        [self showAlertWithMessage:@"密码为6~20位" btnTitle:@"确定"];
        return;
        
    }
    
   
    
    
    //!< 通知代理执行注册操作
    if(self.delegate && [self.delegate respondsToSelector:@selector(findPwdView:didClickFinishBtnWithPhoneNumber:pwd:mask:)])
    {
        
        [self.delegate  findPwdView:self didClickFinishBtnWithPhoneNumber:_phoneTF.text pwd:_pwdTF.text mask:_verifyTF.text];
    }
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.timeLabel.hidden = YES;
//    self.finishBtn.highlighted = YES;
//    self.finishBtn.enabled = NO;
}

 
/**
 *  判断电话号码是否合法
 */
- (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


#pragma mark --- setter

- (void)setIsShowTimer:(BOOL)isShowTimer
{
    _isShowTimer = isShowTimer;
    if (isShowTimer)
    {
        //!< 显示倒计时Label 隐藏获取验证码按钮
        _timeLabel.hidden = NO;
        _getCodeBtn.hidden = YES;
        
    }else
    {
        _timeLabel.hidden = YES;
        _getCodeBtn.hidden = NO;
        
    }
    _finishBtn.highlighted = NO;
    self.finishBtn.enabled = YES;
    
}

//!< 倒计时文字
- (void)setLabelText:(NSString *)labelText
{
    _labelText = labelText;
    _timeLabel.text = labelText;
    
}

//!< 按钮文字
- (void)setButtonText:(NSString *)buttonText
{
    _buttonText = buttonText;
    [_getCodeBtn setTitle:buttonText forState:UIControlStateNormal];
    
}

@end
