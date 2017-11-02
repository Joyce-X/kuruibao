//
//  XMLoginView.m
//  kuruibao
//
//  Created by x on 16/9/30.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMLoginView.h"
#import "UIView+alert.h"
#import "NSString+Hash.h"

@interface XMLoginView()

@property (weak, nonatomic) IBOutlet UITextField *phoneTF; //!< 电话输入框

@property (weak, nonatomic) IBOutlet UITextField *pwdTF;//!< 密码输入框

@property (assign, nonatomic) BOOL isSelect; //!< 默认是选中的，也就是select = NO 的时候表示用户同意协议，为YES时代表不同意协议

@property (nonatomic,weak)UIView* coverView;//!< 分类中的属性

@end
@implementation XMLoginView

#pragma mark --- 监听按钮点击

//!< 登录
- (IBAction)loginBtnClick:(id)sender {
    
    //!< 验证手机号码正确性 和密码长度之后，通知代理做登录操作  判断是否同意协议
//    [self endEditing:YES];
    //-- 判断是否输入手机号码
    if(_phoneTF.text.length == 0)
    {
        
        [self showAlertWithMessage:@"请输入用户名" btnTitle:@"确定"];
        
        return;
    }
    //!< 判断手机号码正确性
//    if(![self validateMobile:_phoneTF.text])
//    {
//         [self showAlertWithMessage:@"手机号码格式不正确" btnTitle:@"确定"];
//        return;
//    }
//    
    
    //-- 判断是否输入密码
    if(_pwdTF.text.length == 0)
    {

         [self showAlertWithMessage:@"请输入密码" btnTitle:@"确定"];
  
        return;
    }

    
    //!< 判断密码格式
    if (_pwdTF.text.length < 6 || _pwdTF.text.length > 24) {
         [self showAlertWithMessage:@"密码长度6~20位" btnTitle:@"确定"];
        return;
    }
    
    
    //!< 判断是否同意协议
    if(_isSelect)
    {
        
        [self showAlertWithMessage:@"请同意酷锐宝用户安全协议!" btnTitle:@"确定"];
        return;
        
    
    }
    
    //!< 通知代理
    if(self.deleagte && [self.deleagte respondsToSelector:@selector(loginViewDidClickLoginBtn:phineNumber:pwd:)])
    {
        //!< 密码不进行加密传递 在登录操作时候进行加密操作
        [self.deleagte loginViewDidClickLoginBtn:self phineNumber:_phoneTF.text pwd:_pwdTF.text];
    }
    
}

//!< 忘记密码
- (IBAction)losePwdBtnClick:(id)sender {
    
    //!< 通知代理跳转到找回密码界面
    if(self.deleagte && [self.deleagte respondsToSelector:@selector(loginViewDidClickLosePwdBtn:)])
    {
        [self.deleagte loginViewDidClickLosePwdBtn:self];
    
    }
    
}


//!< 协议内容
- (IBAction)protocolTitleClick:(id)sender {
    
    //!< 通知代理展示用户协议界面
    if (self.deleagte && [self.deleagte respondsToSelector:@selector(loginViewDidClickUserProtocolBtn:)])
    {
        [self.deleagte loginViewDidClickUserProtocolBtn:self];
    }
    
}

//!< 选中协议
- (IBAction)selelctProtocolBtnClick:(UIButton *)sender{
    
    //!< 更改显示状态
    //!< 默认是选中的，也就是select = NO 的时候表示用户同意协议，为YES时代表不同意协议
    
    sender.selected = !sender.selected;
    _isSelect = sender.selected;
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


#pragma mark --- 从其他界面跳转到登录页面时，快速填充账号和密码

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
    
    _phoneTF.text = phoneNumber;


}

- (void)setPwd:(NSString *)pwd
{
    _pwd = pwd;
    
    _pwdTF.text = pwd;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.phoneTF becomeFirstResponder];
    
    [self.phoneTF resignFirstResponder];


}

@end
