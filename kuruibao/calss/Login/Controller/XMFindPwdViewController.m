//
//  XMFindPwdViewController.m
//  KuRuiBao
//
//  Created by x on 16/6/23.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/**********************************************************
 class description:找回密码界面，登录时忘记密码情况进行找回密码操作
 
 **********************************************************/
#import "XMFindPwdViewController.h"
#import "XMFindPwdView.h"
#import "AFNetworking.h"
#import "NSString+Hash.h"

#define topViewHeight FITHEIGHT(245)  //顶部黑色背景高度
#define backImageH  FITHEIGHT(181) //高度
#define slideUpOffset 160 //键盘弹起时，View偏移量

@interface XMFindPwdViewController ()<XMFindPwdViewDelegate>

@property (assign, nonatomic) BOOL isConnected;//!< 标记网络连接状态
@property (copy, nonatomic) NSString *verifyPhoneNumber;//!< 接收短信验证码的手机号码
@property (nonatomic,weak)XMFindPwdView* findView;
@property (nonatomic,strong)NSTimer* timer;
@property (copy, nonatomic) NSString *verifyCode;//!< 找回密码时候获取的验证码

@property (strong, nonatomic) AFHTTPSessionManager *session;

@end

/**
 *  倒计时时间设置
 */
static int timeDeadLine = 59;


@implementation XMFindPwdViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //-- 设置初始化信息
    [self setupInitInfo];
    
    //->>监听键盘通知
    [self monitorKeyboard];
    
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"找回密码页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"找回密码页面");
    
}

#pragma mark -- init

- (void)setupInitInfo
{
    
    //!< 设置顶部颜色 和背景颜色
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    topView.backgroundColor = XMColorFromRGB(0x2e2e34);
    [self.view addSubview:topView];
    
    
    //!< 添加背景
    UIImageView *backView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, mainSize.width, mainSize.height - 20)];
    backView.image = [UIImage imageNamed:@"Login_background"];
    [self.view addSubview:backView];
    
    
    UIView *top = [UIView new];
    top.frame = CGRectMake(0, 20, mainSize.width, backImageH - 20);
    [self.view addSubview: top];
    
     //->>返回按钮
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    leftItem.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    [leftItem setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftItem addTarget:self action:@selector(backToLast) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftItem];
    [leftItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(top).offset(20);
        make.top.equalTo(top).offset(FITHEIGHT(26));
        make.size.equalTo(CGSizeMake(31, 31));
        
        
    }];
    
    //->>设置显示提示信息的label
    UILabel *message = [[UILabel alloc]init];
     message.textAlignment = NSTextAlignmentLeft;
    [message setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26]];//->>加粗
    message.text = @"找回密码";
    message.textColor = XMColorFromRGB(0xF8F8F8);
    [self.view addSubview:message];
     [message mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(top).offset(25);
        make.width.equalTo(200);
        make.height.equalTo(31);
        make.top.equalTo(leftItem.mas_bottom).offset(20);
        
    }];
    
    
    //!< 添加自定义视图
    XMFindPwdView *findView = [[[NSBundle mainBundle] loadNibNamed:@"XMFindPwd" owner:nil options:nil] firstObject];;
    findView.frame = CGRectMake(0, topViewHeight + 20, mainSize.width, mainSize.height - topViewHeight - 20);
    findView.delegate = self;
    [self.view addSubview:findView];
    self.findView = findView;
    
    self.isConnected = YES;
    
}

-(AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        _session.requestSerializer.timeoutInterval = 10;
    }
    return _session;
    
}

#pragma mark --- XMFindPwdViewDelegate
/**
 *  点击获取验证码按钮，通知控制器发送验证码
 *  para  电话号码
 *
 */
- (void)findPwdView:(XMFindPwdView*)findView didClickGetVerifyCodeBtnWithPhoneNumber:(NSString *)phoneNumber
{
    
    [self.view endEditing:YES];
    
    //!< 获取验证码
    self.verifyPhoneNumber = phoneNumber;//!< 记录获取验证码手机号码，点击完成时进行二次验证
 
    //!< 判断网络连接状态
    if (!_isConnected)
    {
        [MBProgressHUD showError:@"网络连接失败，请检查网络连接"];
        return;
    }
    
    //!< 显示倒计时
    self.findView.labelText = @"59秒后可重新获取";
    self.findView.isShowTimer = YES;
    self.findView.buttonText = @"重新获取验证码";
    
    //    开启定时器
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(chageLabelTitle:) userInfo:nil repeats:YES];
    
    //!< 请求验证码
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"getmask&Mobil=%@",phoneNumber];
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD showSuccess:@"验证码已发送"];
        //!< 发送成功 记录验证码
        _verifyCode = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        
    } failure:nil];



}


/**
 *  点击完成按钮
 *  账号
 *  密码 验证码
 */

- (void)findPwdView:(XMFindPwdView*)findView didClickFinishBtnWithPhoneNumber:(NSString *)phoneNumber pwd:(NSString *)pwd mask:(NSString *)mask
{
    
    [self.view endEditing:YES];
    //!< 判断网络状态，判断手机号码是否一致  判断验证码是否一致
    if(!_isConnected)
    {
        [self showAlertWithMessage:@"未接入网络" btnTitle:@"确定"];
        return;
    }
    
    if(![_verifyPhoneNumber isEqualToString:phoneNumber])
    {
        [self showAlertWithMessage:@"当前手机与验证手机不一致" btnTitle:@"确定"];
        return;
    }
    
    if(![_verifyCode isEqualToString:mask])
    {
       [self showAlertWithMessage:@"验证码错误" btnTitle:@"确定"];
        return;
    }
    
    [MBProgressHUD showMessage:@"正在修改"];
    //!< 发送请求修改密码
    //!< 请求验证码
    
    NSString * md5Pwd = [pwd md5String];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Updatepasswordbymobil&Mobil=%@&Password=%@",phoneNumber,md5Pwd];
     [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        int result = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
        if (result)
        {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                //!< 成功
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"操作成功，准备跳转登录"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    //!< 关闭定时器
                    [self closeTimer];
                    
                    //!< 跳转到登录界面 执行block
                    [self.navigationController popViewControllerAnimated:YES];
                    self.finishFind(phoneNumber,pwd);
                    
                });

            });
        }else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //!< 失败
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"操作失败，请检查网络连接"];
            });
           
           
        
        
        }
        
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //!< 失败
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"操作失败，请检查网络连接"];
        
        
    }];
    

}







//!< 监控网络状态
- (void)netStateChanged:(NSNotification *)noti
{
    int statusCode = [noti.userInfo[@"info"] intValue];
    
    if (statusCode == 0 || statusCode == -1)
    {
        self.isConnected = NO;
        
    }else
    {
        self.isConnected = YES;
        
        
    }
    
    
}

//->> 监听通知
- (void)monitorKeyboard
{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStateChanged:) name:XMNetWorkDidChangedNotification object:nil];;
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;
}

- (void)backToLast
{
    
    [self closeTimer];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [self.view endEditing:YES];
}


#pragma mark -- timer

- (void)chageLabelTitle:(NSTimer *)sender
{
    
    self.findView.labelText = [NSString stringWithFormat:@"%d秒后重新发送",--timeDeadLine];
    
    if (timeDeadLine == 0)
    {
         //-- 时间到，
        [sender invalidate];
        self.timer = nil;
        self.findView.isShowTimer = NO;
        timeDeadLine = 59;
        self.findView.labelText = @"59秒后重新发送";
        
        
    }
    
    
    
}


/**
 *  关闭定时器
 */
- (void)closeTimer
{
    if(self.timer)
    {
         
        [self.timer invalidate];
        self.timer = nil;
        timeDeadLine = 59;
        
    }
    
    
}

#pragma mark -- 监听通知的方法

/**
 *  键盘即将弹出
 */
- (void)keyboardWillShow:(NSNotification *)noti
{
    if (self.view.y != 0)return;
    
    CGFloat duration = [noti.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    [UIView animateWithDuration:duration animations:^{
        
        self.view.y -= slideUpOffset;
        
    }];
    
    
    
}



/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHide:(NSNotification *)noti
{
    if (self.view.y == 0)return;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.y += slideUpOffset;
        
    }];
    
}


#pragma mark -- 监控内存
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     [self closeTimer];
}
     


@end
