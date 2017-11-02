//
//  XMSet_userBackViewController.m
//  kuruibao
//
//  Created by x on 16/9/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMSet_userBackViewController.h"

#import "AFNetworking.h"

#import "XMUser.h"


@interface XMSet_userBackViewController ()<UITextViewDelegate>

@property (nonatomic,weak)UIButton* sendBtn;

@property (nonatomic,weak)UITextView* textView;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@end

@implementation XMSet_userBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setBackSubViews];
 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"用户反馈页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"用户反馈页面");
    
}


- (void)setBackSubViews
{
     self.message = @"用户反馈";
    
    [self.imageVIew removeFromSuperview];
    
    //-----------------------------seperate line---------------------------------------//
    //!< statusBar
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    statusBar.backgroundColor = XMTopColor;
    
    [self.view addSubview:statusBar];
    
    //-----------------------------seperate line---------------------------------------//
    UIImageView *backIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monitor_background"]];
    
    backIV.frame = CGRectMake(0, 20, mainSize.width, mainSize.height - 20);
    
    [self.view addSubview:backIV];
    
    [self.view sendSubviewToBack:backIV];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加底部按钮
   
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    sendBtn.backgroundColor = XMGrayColor;
    
    [sendBtn setTitle:@"发送反馈" forState:UIControlStateNormal];
    
     [sendBtn setTitle:@"发送反馈" forState:UIControlStateDisabled];
    
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [sendBtn addTarget:self action:@selector(sendBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sendBtn];
    
    self.sendBtn = sendBtn;
    
    sendBtn.enabled = NO;
    
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view);
        
        make.right.equalTo(self.view);
        
        make.left.equalTo(self.view);
        
        make.height.equalTo(55);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加背景图
    UIView *backView = [UIView new];
    
    backView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    
    [self.view addSubview:backView];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backIV).offset(25);
        
        make.right.equalTo(backIV).offset(-25);
        
        make.bottom.equalTo(sendBtn.mas_top).offset(-18);
        
        make.top.equalTo(statusBar.mas_bottom).offset(FITHEIGHT(175));
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加label
    UILabel *mesLabel = [UILabel new];
    
    mesLabel.textColor = [UIColor whiteColor];
    
    mesLabel.text = @"意见反馈";
    
    mesLabel.font = [UIFont systemFontOfSize:14];
    
    [backView addSubview:mesLabel];
    
    [mesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backView).offset(16);
        
        make.top.equalTo(backView).offset(13);
        
        make.height.equalTo(12);
        
        make.width.equalTo(130);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< line
    UIView *line = [UIView new];
    
    line.backgroundColor = XMGrayColor;
    
    line.alpha = 0.4;
    
    [backView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backView).offset(16);
        
        make.right.equalTo(backView).offset(-16);
        
        make.top.equalTo(mesLabel.mas_bottom).offset(10);
        
        make.height.equalTo(1);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    UITextView *textView = [UITextView new];
    
    textView.textColor = XMGrayColor;
    
    textView.font = [UIFont systemFontOfSize:12];
    
    textView.backgroundColor = [UIColor clearColor];
    
    textView.text = @"意见反馈";
    
    textView.delegate = self;
    
    [backView addSubview:textView];
    
    self.textView = textView;
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(line).offset(10);
        
        make.left.equalTo(line);
        
        make.right.equalTo(line);
        
        make.bottom.equalTo(backView).offset(-5);
        
    }];

    
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = nil;

}

- (void)textViewDidChange:(UITextView *)textView
{
    
    if (_sendBtn.enabled == NO)
    {
        _sendBtn.backgroundColor = XMGreenColor;
        
        _sendBtn.enabled = YES;

    }
  
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];

}

//!<点击反馈按钮
- (void)sendBtnDidClick
{
    if (self.textView.text.length == 0)
    {
        [MBProgressHUD showError:@"请输入内容"];
        return;
    }
    
    NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo_nickName"];
    
    XMUser *user = [XMUser user];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"submitfeedback&userid=%ld&phone=%@&nickname=%@&feedback=%@",(long)user.userid,user.mobil,nickName,self.textView.text];
  
 
   
    urlStr  = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
     [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        id obj = dic[@"code"];
        
        if ([obj intValue] == 1)
        {
            //!< 发送成功
             [MBProgressHUD showSuccess:@"提交成功"];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
        }else
        {
            //!< 发送失败
             [MBProgressHUD showError:@"提交失败，网络超时"];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        [MBProgressHUD showError:@"提交失败，网络超时"];
        
    }];
    
}

@end
