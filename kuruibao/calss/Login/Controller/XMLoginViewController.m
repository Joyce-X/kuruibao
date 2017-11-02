//
//  XMLoginViewController.m
//  KuRuiBao
//
//  Created by x on 16/6/23.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMLoginViewController.h"
#import "XMUserProtocolViewController.h"
//#import "EMSDK.h"
#import "XMSettingViewController.h"
#import "XMSlideViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "NSString+Hash.h"
#import "XMLoginView.h"
#import "XMRegisterView.h"
#import "XMFindPwdViewController.h"
#import "AFNetworking.h"
#import "NSString+Hash.h"
#import "MJExtension.h"
#import "XMUser.h"


#define topViewHeight FITHEIGHT(245)  //顶部黑色背景高度
#define logoHeight  20 //logo高度
#define buttonHeight 39 //登录注册按钮高度
#define slideUpOffset 160 //键盘弹起时，View偏移量


static int timeline = 59; //!< 倒计时时间设置


@interface XMLoginViewController ()<XMLoginViewDelegate,XMRegisterViewDelegate>

@property (nonatomic,weak)NSTimer* timer;//!< 定时器
@property (nonatomic,weak)UIImageView* greenView;//!< 选项卡线条
@property (copy, nonatomic) NSString *registerNumber;//!< 注册的电话号码
@property (assign, nonatomic) BOOL isConnected;//!< 标记网络连接状态
@property (copy, nonatomic) NSString *verifyCode;//!< 注册时候获取的验证码
@property (nonatomic,strong)XMRegisterView* registerView;//!< 注册界面
@property (nonatomic,weak)XMLoginView* loginView;//!< 登录界面
@property (nonatomic,weak)UIButton* loginBtn;//!< 登录按钮
@property (copy, nonatomic) NSString *pwd;//md5
@property (strong, nonatomic) AFHTTPSessionManager *session;


@end


@implementation XMLoginViewController


#pragma mark --- lifeCircle

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    //-- 设置控件
    [self setupSubviews];
    
    //->>监听键盘通知 和网络变化的通知
    [self monitorKeyboard];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"登录页面");
 }

- (void)viewWillDisappear:(BOOL)animated
{
 
    [super viewWillDisappear:animated];
     MobClickEnd(@"登录页面");
    
}

#pragma mark --- setupSubViews

/**
 *  初始化子控件
 */
- (void)setupSubviews
{
    
    //!< 默认连接处于连接状态
    _isConnected = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //!< 状态栏
    UIView *statusBar =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    statusBar.backgroundColor =  XMTopColor;
    
    [self.view addSubview:statusBar];
    
    //!< 创建顶部带logo的大背景
    UIImageView *topview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, mainSize.width, topViewHeight)];
 
    topview.image = [UIImage imageNamed:@"Login_backgroundUp"];
    
    topview.userInteractionEnabled = YES;
    
    [self.view addSubview:topview];
    
    //!< 添加logo
    UIImageView *logoIV1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_Logo"]];
    
    logoIV1.contentMode = UIViewContentModeScaleAspectFit;
    
    [topview addSubview:logoIV1];
    
    [logoIV1 mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.equalTo(topview);
        
        make.height.equalTo(logoHeight);
        
        make.center.equalTo(topview);
        
    }];
    
    //!< 添加登录注册按钮
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    loginBtn.tag = 0;
    
    [loginBtn addTarget:self action:@selector(topBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    loginBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 0, 18, 0);
    
    [topview addSubview:loginBtn];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(topview);
        
        make.top.equalTo(topViewHeight - buttonHeight);
        
        make.width.equalTo(mainSize.width * 0.5);
        
        make.height.equalTo(buttonHeight);
        
    }];
    
    
    //!< 注册按钮
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    registerBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 0, 18, 0);
    
    registerBtn.tag = 1;
    
    [registerBtn addTarget:self action:@selector(topBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [topview addSubview:registerBtn];
    
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(topview);
        
        make.top.equalTo(loginBtn);
        
        make.width.equalTo(mainSize.width * 0.5);
        
        make.height.equalTo(buttonHeight);
        
    }];
    
    
    //!< 添加绿色线条
    UIImageView *greenLine = [UIImageView new];
    
    greenLine.image = [UIImage imageNamed:@"Login_slideLine"];
    
    greenLine.contentMode = UIViewContentModeScaleToFill;
    
    [topview addSubview:greenLine];
    
    self.greenView = greenLine;
    
    [greenLine mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.equalTo(registerBtn);
        
        make.height.equalTo(2);
        
        make.bottom.equalTo(registerBtn);
        
        make.left.equalTo(loginBtn);
        
    }];
    
    
    //!< 添加登录View和注册view
    XMLoginView *loginView = [[[NSBundle mainBundle] loadNibNamed:@"XMLogin" owner:nil options:nil] firstObject];
    
    loginView.deleagte = self;
    
    loginView.frame = CGRectMake(0, topViewHeight + 20, mainSize.width, mainSize.height - topViewHeight - 20);
    
    [self.view addSubview:loginView];
    
    self.loginView = loginView;
    
  }


#pragma mark --- lazy

- (XMRegisterView *)registerView
{
    //!< 懒加载注册视图
    if (!_registerView)
    {
        _registerView = [[[NSBundle mainBundle]loadNibNamed:@"XMRegister" owner:nil options:nil] firstObject];
        
        _registerView.frame = CGRectMake(0, topViewHeight + 20, mainSize.width, mainSize.height - topViewHeight - 20);
        
        [_registerView setDelegate:self];
        
        [self.view addSubview:_registerView];
        
        self.registerView = _registerView;
    }
    return _registerView;
}


- (AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session  = [AFHTTPSessionManager manager];
        
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _session.requestSerializer.timeoutInterval = 20;//!< 请求超时时间为10秒
    }
    
    return _session;
}



#pragma mark --- 监听按钮点击事件

- (void)topBtnDidClick:(UIButton *)sender
{
    
    if (sender.tag) //!< 点击注册
    {
        [self registerView];
        
        _registerView.hidden = NO;
        
        [self.view endEditing:YES];
        
        [UIView animateWithDuration:0.25 animations:^{

            _greenView.transform = CGAffineTransformMakeTranslation(mainSize.width * 0.5, 0);
        }];
      
    }else   //!< 点击登录
    {
        _registerView.hidden = YES;
        
        [self.view endEditing:YES];
        
        [UIView animateWithDuration:0.25 animations:^{

            _greenView.transform = CGAffineTransformIdentity;
            
        }];

    }
    
    
}


//->> 监听键盘的弹起和落下
- (void)monitorKeyboard
{
    
    //!<监听键盘的弹起和落下
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //!< 监听网络变化
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitorNetState:) name:XMNetWorkDidChangedNotification object:nil];
    
}


#pragma mark --- 注册成功跳转登录

/**
 *  环信酷锐宝注册成功，开始跳转登录
 *
 *
 */
- (void)registerSuccessJumpToLoginWithPhoneNumber:(NSString *)phoneNumber pwd:(NSString *)pwd
{
    //!< 设置登录界面账号和密码，代码点击登录按钮
    [MBProgressHUD hideHUD];
    
    self.loginView.phoneNumber = phoneNumber;
    
    self.loginView.pwd = pwd;
    
    [self topBtnDidClick:self.loginBtn];//!< 切换界面
    
    [self loginViewDidClickLoginBtn:nil phineNumber:phoneNumber pwd:pwd];//!< 登录

}




#pragma mark --- XMLoginViewDelegate

/**
 *  点击忘记密码按钮
 */
- (void)loginViewDidClickLosePwdBtn:(XMLoginView *)loginView
{
    XMFindPwdViewController *findPwdViewController = [XMFindPwdViewController new];
    
    __weak typeof(self) wSelf = self;
    
    findPwdViewController.finishFind = ^(NSString *phoneNumber,NSString *pwd)
    {
        //!< 和注册相同方法 点击完成的话跳转到登录页面进行登录
        [wSelf registerSuccessJumpToLoginWithPhoneNumber:phoneNumber pwd:pwd];
    
    };
    
    [self.navigationController pushViewController:findPwdViewController animated:YES];
}


/**
 *
 *  点击用户协议
 *
 */
- (void)loginViewDidClickUserProtocolBtn:(XMLoginView *)loginView
{
     XMUserProtocolViewController *protocolVC = [[XMUserProtocolViewController alloc]init];
 
    [self presentViewController:protocolVC animated:YES completion:nil];


}

/**
 *  执行登录操作
 *
 *
 */
- (void)loginViewDidClickLoginBtn:(XMLoginView *)loginView phineNumber:(NSString *)phoneNumber pwd:(NSString *)pwd
{
    
    
    //!< 开始发送登录请求(在logView中已经进行判断)
     [self.view endEditing:YES];
    
     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Login&Mobil=%@&Password=%@&Source=G",phoneNumber,[pwd md5String]];
   
     [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
         
        if ([result isEqualToString:@"0"])
        {
            [MBProgressHUD showError:@"密码错误"];
        }else if ([result isEqualToString:@"-2"])
        {
            [MBProgressHUD showError:@"用户不存在"];
        
        }else if([result isEqualToString:@"-1"])
        {
            [MBProgressHUD showError:@"网络繁忙"];
        }else
        {
            //!< 登陆成功，字典转模型保存用户信息
            [MBProgressHUD showSuccess:@"登陆成功"];
            
                
            //!< 保存用户信息
            NSError *error = nil;
            
            id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            
            if([obj isKindOfClass:[NSArray class]])
            {
                NSDictionary *dic = [(NSArray *)obj firstObject];
                
                XMUser *user = [XMUser userWithDictionary:dic];
                
                [XMUser save:user];
                
                XMLOG(@"--保存的时候-------Joyce111 类型号码: %ld---------",user.typeId);
                
            }else
            {
                
                [MBProgressHUD showError:@"登录失败"];
                
                XMLOG(@"服务器返回参数错误");

                
                return;
            
            }
            
            //!< 跳转页面 设置主窗口
            XMSettingViewController *setVC = [[XMSettingViewController alloc]init];
            
            UITabBarController *mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"XMMainTabBarController"];
            
            XMSlideViewController *slideVC = [[XMSlideViewController alloc]initWithLeftView:setVC andMainView:mainVC];
            AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            tempAppDelegate.sliderVC = slideVC;
            
            tempAppDelegate.tabBarController = mainVC;
            
            [UIApplication sharedApplication].keyWindow.rootViewController = slideVC;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [MBProgressHUD showError:@"登录失败，请检查网络连接"];
        
     }];
    

    

}


#pragma mark --- XMRegisterViewDelegate

/**
 *  获取验证码
 *
 *  para:电话号码
 */
- (void)registerViewDidClickGetVerifyCodeBtnWithPhoneNumber:(NSString *)phoneNumber
{
    
    [self.view endEditing:YES];
    
    //!< 获取验证码
    self.registerNumber = phoneNumber;//!< 记录获取验证码手机号码，在注册的时候进行二次验证
    
    //!< 发请求获取验证码

    //!< 判断网络连接状态
    if (!_isConnected)
    {
        [MBProgressHUD showError:@"网络连接失败，请检查网络连接"];
        return;
    }
    
    [MBProgressHUD showSuccess:@"验证码已发送"];
    
    //!< 显示倒计时
    
    self.registerView.labelText = @"59秒后可重新获取";
    self.registerView.isShowTimer = YES;
    self.registerView.buttonText = @"重新获取验证码";
    
//    定时器
     self.timer =  [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(chageLabelTitle:) userInfo:nil repeats:YES];
    
    
    //!< 请求验证码
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"getmask&Mobil=%@",phoneNumber];
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //!< 发送成功
        _verifyCode = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        XMLOG(@"3333333--%@",_verifyCode);
     } failure:nil];
    
    
    


}


/**
 *  注册酷锐宝账户，同时注册环信账号
 *
 *
 */
- (void)registerViewDidClickRegisterBtnWithPhoneNumber:(NSString *)phoneNumber pwd:(NSString *)pwd verifyCode:(NSString *)verifyCode
{
    
    
    if (![_verifyCode isEqualToString:verifyCode])
    {
        [self showAlertWithMessage:@"验证码错误" btnTitle:@"确定"];
        return;
    }
    
    //!< 获取验证码手机和注册手机是否一致，
    if (![_registerNumber isEqualToString:phoneNumber]) {
        
        
        [self showAlertWithMessage:@"注册手机和验证手机不一致" btnTitle:@"确定"];
        return;
    }
    
    [self.view endEditing:YES];
    
     [MBProgressHUD showMessage:@"正在注册"];
    
    //!< 一切验证通过开始注册
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Reg&Mobil=%@&Password=%@&Mask=%@",phoneNumber,[pwd md5String],_verifyCode];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUD];
        //!< 状态值
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        int state = [result intValue];
        
            switch (state) {
            case 0:
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:@"注册失败，请检查网络连接"];
                     });
               
                
                break;
            case -3:
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:@"该账户已经注册"];
                     });
                
                 
                break;
              
            default:
                    
//                //!< 注册环信
//                [self registerEaseMobWithNumber:phoneNumber pwd:pwd ];
                    
                    [MBProgressHUD showMessage:@"注册成功，正在跳转登录"];
                    
                    //!< 跳转登录操作
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self registerSuccessJumpToLoginWithPhoneNumber:phoneNumber pwd:pwd];
                    });
                NSString *userNumber = [NSString stringWithFormat:@"%d",state];
                
                //!< 保存用户编号到沙河
                [[NSUserDefaults standardUserDefaults] setObject:userNumber forKey:@"userNumber"];
                [[NSUserDefaults standardUserDefaults] synchronize];
             
                break;
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"注册失败,请检查网络连接"];
        
    }];
  }



#pragma mark --- ****************************

#pragma mark -- 监听通知的方法

/**
 *  键盘即将弹出
 */
- (void)keyboardWillShow:(NSNotification *)noti
{
    if (self.view.y != 0)return;
    
    XMLOG(@"%@",noti.userInfo);
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
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
 

//!< 监控网络状态
- (void)monitorNetState:(NSNotification *)noti
{
    
    int state = [noti.userInfo[@"info"] intValue];
    
    if (state < 1)
    {
        //!< 未连接
         self.isConnected = NO;
        
    }else
    {
        //!< 连接WIFI 或者3G
        self.isConnected = YES;
    
    }
    
     
}



//-- 结束编辑状态
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [self.view endEditing:YES];
    
}


#pragma mark -- timer

- (void)chageLabelTitle:(NSTimer *)sender
{
    
    self.registerView.labelText = [NSString stringWithFormat:@"%d秒后重新发送",--timeline];
    
    if (timeline == 0)
    {
         //-- 时间到
        [sender invalidate];
        
        self.timer = nil;
        
        self.registerView.isShowTimer = NO;
        
        timeline = 59;
        
        self.registerView.labelText = @"59秒后重新发送";
    }
    
    
    
}


/**
 *  关闭定时器
 */
- (void)closeTimer
{
    if(self.timer)
    {
        XMLOG(@"定时器销毁");
         [self.timer invalidate];
        self.timer = nil;
        timeline = 59;
        
    }
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;

}


- (void)dealloc
{
    
    //-- 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //-- 销毁定时器
    [self closeTimer];
    
    
    
    
}

@end
