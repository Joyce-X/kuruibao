//
//  XMChangePWDViewController.m
//  kuruibao
//
//  Created by x on 16/12/13.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMChangePWDViewController.h"

#import "AFNetworking.h"

#import "NSString+Hash.h"

#import "XMUser.h"


@interface XMChangePWDViewController ()


@property (assign, nonatomic) BOOL isConnected;//!< 标记网络连接状态

@property (nonatomic,strong)NSTimer* timer;

@property (copy, nonatomic) NSString *verifyCode;//!< 找回密码时候获取的验证码


@property (nonatomic,weak)UIButton* verifyBtn;//!< 获取验证码按钮

@property (nonatomic,weak)UIButton* sureBtn;//!< 确认修改按钮

@property (nonatomic,weak)UITextField* verifyTF;//!< 输入验证码的TF

@property (nonatomic,weak)UITextField* firstTF;//!< 一次密码TF

@property (nonatomic,weak)UITextField* secondTF;//!< 二次密码TF

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (assign, nonatomic) int time;

@end

@implementation XMChangePWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubViews];

 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"修改密码页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"修改密码页面");
    
}


- (void)initSubViews
{
    self.message = @"修改密码";
    
    [self.imageVIew removeFromSuperview];//!< 删除原来的图片
    
    //-----------------------------seperate line---------------------------------------//
    //!<statusBar
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    statusBar.backgroundColor = XMTopColor;
    
    [self.view addSubview:statusBar];
    
    //-----------------------------seperate line---------------------------------------//
    //!< backgroundImage
    
    UIImageView *backIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, mainSize.width, mainSize.height - 20)];
    
    backIV.image = [UIImage imageNamed:@"monitor_background"];
    
    [self.view addSubview:backIV];
    
    [self.view sendSubviewToBack:backIV];

    //-----------------------------seperate line---------------------------------------//
    //!< 确认按钮
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [sureBtn setTitle:@"确认修改" forState:UIControlStateNormal];
    
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    [sureBtn setTitle:@"确认修改" forState:UIControlStateDisabled];
    
    sureBtn .titleLabel.font = [UIFont systemFontOfSize:15];
    
    sureBtn.backgroundColor = XMGrayColor;
    
    
    sureBtn.enabled = NO;
    
    [sureBtn addTarget:self action:@selector(surebtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sureBtn];
    
    self.sureBtn = sureBtn;
    
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backIV);
        
        make.right.equalTo(backIV);
        
        make.bottom.equalTo(backIV);
        
        make.height.equalTo(55);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    //!< 图标1
    
    UIImageView *verifyIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Register_VerifyIcon"]];
    
    [self.view addSubview:verifyIV];
    
    [verifyIV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(backIV).offset(FITHEIGHT(175));
        
        make.size.equalTo(CGSizeMake(22, 22));
        
        make.left.equalTo(backIV).offset(25);
        
    }];
    
    //!< TF1
    UITextField *verifyTF = [[UITextField alloc]init];
    
    verifyTF.placeholder = @"输入验证码";
    
    [verifyTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
     
    verifyTF.textColor = [UIColor whiteColor];
    
    verifyTF.font = [UIFont systemFontOfSize:14];
    
    verifyTF.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:verifyTF];
    
    self.verifyTF =verifyTF;
    
    [verifyTF mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(verifyIV);
        
        make.left.equalTo(verifyIV.mas_right).offset(13);
        
        make.height.equalTo(30);
        
        make.width.equalTo(160);
        
        
    }];
    
    
    UIButton *verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    
    [verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    verifyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    verifyBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    
    [verifyBtn addTarget:self action:@selector(verifyBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:verifyBtn];
    
    self.verifyBtn = verifyBtn;
    
    [verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(backIV).offset(-39);
        
        make.centerY.equalTo(verifyTF);
        
        make.width.equalTo(100);
        
        make.height.equalTo(30);
        
        
    }];
    
    
    //!< 添加线条
    UIImageView *topLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_line"]];
    
    [self.view addSubview:topLine];
    
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(verifyIV.mas_bottom).offset(10);
        
        make.left.equalTo(backIV);
        
        make.height.equalTo(1);
        
        make.right.equalTo(backIV);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 图标2
    
    UIImageView *firstIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_PwdIcon"]];
    
    [self.view addSubview:firstIV];
    
    [firstIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(topLine.mas_bottom).offset(30);
        
        make.size.equalTo(CGSizeMake(22, 22));
        
        make.left.equalTo(backIV).offset(25);
        
    }];
    
    //!< TF2
    UITextField *firstTF = [[UITextField alloc]init];
    
    firstTF.placeholder = @"输入新密码";
    
    [firstTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    
    
    firstTF.textColor = [UIColor whiteColor];
    
    firstTF.font = [UIFont systemFontOfSize:14];
    
    firstTF.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:firstTF];
    
    self.firstTF = firstTF;
    
    [firstTF mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(firstIV);
        
        make.left.equalTo(firstIV.mas_right).offset(13);
        
        make.height.equalTo(30);
        
        make.width.equalTo(200);
        
        
    }];
    
    
    //!< 添加线条
    UIImageView *firstLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_line"]];
    
    [self.view addSubview:firstLine];
    
    [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(firstIV.mas_bottom).offset(10);
        
        make.left.equalTo(backIV);
        
        make.height.equalTo(1);
        
        make.right.equalTo(backIV);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 图标3
    
    UIImageView *secondIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_PwdIcon"]];
    
    [self.view addSubview:secondIV];
    
    [secondIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(firstLine.mas_bottom).offset(30);
        
        make.size.equalTo(CGSizeMake(22, 22));
        
        make.left.equalTo(backIV).offset(25);
        
    }];
    
    //!< TF1
    UITextField *secondTF = [[UITextField alloc]init];
    
    secondTF.placeholder = @"再次输入新密码";
    
    [secondTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

     secondTF.textColor = [UIColor whiteColor];
    
    secondTF.font = [UIFont systemFontOfSize:14];
    
    secondTF.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:secondTF];
    
    self.secondTF = secondTF;
    
    [secondTF mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(secondIV);
        
        make.left.equalTo(secondIV.mas_right).offset(13);
        
        make.height.equalTo(30);
        
        make.width.equalTo(200);
        
        
    }];
    
    
    
    
    //!< 添加线条
    UIImageView *secondLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_line"]];
    
    [self.view addSubview:secondLine];
    
    [secondLine mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(secondIV.mas_bottom).offset(10);
        
        make.left.equalTo(backIV);
        
        make.height.equalTo(1);
        
        make.right.equalTo(backIV);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    
    //!< 监听tf文字长度变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldTextDidChnage:) name:UITextFieldTextDidChangeNotification object:nil];
    
    
}


#pragma mark -------------- lazy
- (AFHTTPSessionManager *)session
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


#pragma mark -------------- 按钮点击事件

- (void)verifyBtnDidClick
{
    
    [self.view endEditing:YES];
    
     //!< 手机号码
     NSString *phoneNumber = [XMUser user].mobil;
    
        //!< 显示倒计时
    
    [self.verifyBtn setTitle:@"重新发送(59s)" forState:UIControlStateDisabled];
    
    [self.verifyBtn setTitleColor:XMGrayColor forState:UIControlStateDisabled];
    
    _verifyBtn.enabled = NO;
    
    self.time = 59;
    
    //    开启定时器
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(chageBtnTitle:) userInfo:nil repeats:YES];
    
    //!< 请求验证码
      NSString *urlStr = [mainAddress stringByAppendingFormat:@"getmask&Mobil=%@",phoneNumber];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    
            [MBProgressHUD showSuccess:@"验证码已发送"];
            
            //!< 发送成功 记录验证码
            _verifyCode = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
     
        } failure:nil];
        
    
    
}

- (void)chageBtnTitle:(NSTimer *)timer
{
    
    self.time--;
    
    if (self.time == 0)
    {
        
        [self.timer invalidate];
        
        self.timer = nil;
        
        _verifyBtn.enabled = YES;
        
        [self.verifyBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        
        return;
        
    }
    
     NSString *title = [NSString stringWithFormat:@"重新发送(%ds)",self.time];
    
     [self.verifyBtn setTitle:title forState:UIControlStateDisabled];
    
}

- (void)surebtnDidClick
{
    
    //!< 判断验证码是否一致
    if (![self.verifyCode isEqualToString:_verifyTF.text])
    {
        [MBProgressHUD showError:@"验证码错误"];
        
        return;
    }
    
    //!< 两次密码长度是否合法
    if (_firstTF.text.length < 6 || _secondTF.text.length < 6)
    {
        [MBProgressHUD showError:@"密码长度不能少于6位"];
        
        return;
    }
    
     //!< 两次密码是否一致
    if(![_firstTF.text isEqualToString:_secondTF.text])
    {
    
        [MBProgressHUD showError:@"两次输入密码不一致"];
         return;
     
    }
    
    //!< 信息一致开始修改密码
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    XMUser *user = [XMUser user];
    
    NSString *newPwd = [_secondTF.text md5String];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Updatepassword&userID=%ld&Password=%@&V=1",(long)user.userid,newPwd];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        [MBProgressHUD hideHUDForView:self.view];
        
        if ([result isEqualToString:@"1"])
        {
        
            [MBProgressHUD showSuccess:@"修改成功"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
             [self.navigationController popViewControllerAnimated:YES];
            });
            
            
        }else if ([result isEqualToString:@"-1"])
        {
        
            [MBProgressHUD showError:@"网络异常"];
            
        }
        
       
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"网络超时"];
        
        
    }];
    
}

- (void)textfieldTextDidChnage:(NSNotification *)noti
{
    if (_verifyTF.text.length > 0 && _firstTF.text.length > 0 && _secondTF.text.length > 0)
    {
        //!< 三个输入框都有值的时候，确定按钮可点击
        _sureBtn.enabled = YES;
        
        _sureBtn.backgroundColor = XMGreenColor;
        
        
    }else
    {
    
        if (_sureBtn.enabled)
        {
            _sureBtn.enabled = NO;
            
            _sureBtn.backgroundColor = XMGrayColor;
        }
    
    }
    
    
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
- (void)closeTimer
{
    if (self.timer)
    {
        [self.timer invalidate];
        
        self.timer = nil;
    }
    
    
}



#pragma mark -- 监控内存
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self closeTimer];
}
























@end
