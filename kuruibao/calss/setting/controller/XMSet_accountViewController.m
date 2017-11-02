//
//  XMSet_accountViewController.m
//  kuruibao
//
//  Created by x on 16/9/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/**********************************************************
 class description:     用账号设置界面
 
 **********************************************************/
#import "XMSet_accountViewController.h"
#import "XMLoginNaviController.h"
#import "XMLoginViewController.h"
#import "XMUser.h"
#import "XMChangePWDViewController.h"
#import "AppDelegate.h"

#import "XMSDK.h"


@interface XMSet_accountViewController ()

@end

@implementation XMSet_accountViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
    
    
    
 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"设置账号页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"设置账号页面");
    
}


- (void)setupInit
{
     self.message = @"账号设置";
    
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
    
    //!< 退出按钮
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    exitBtn.backgroundColor = XMRedColor;
    
    [exitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    
    exitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [exitBtn addTarget:self action:@selector(exitBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:exitBtn];
    
    
    [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(self.view);
        
        make.right.equalTo(self.view);
        
        make.left.equalTo(self.view);
        
        make.height.equalTo(55);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 账户头像
    UIImageView *headerIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_UserIcon"]];
    
    [self.view addSubview:headerIV];
    
    [headerIV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(backIV).offset(FITHEIGHT(175));
        
        make.left.equalTo(backIV).offset(25);
        
        make.size.equalTo(CGSizeMake(22, 22));
        
    }];
    
    //!< 显示账号的label
    
     UILabel *currentUserAccount = [UILabel new];
    
    XMUser *user = [XMUser user];
    
    
    NSString *account;
    
    if (user.mobil.length < 4)
    {
        account = @"******";
        
    }else
    {
        
        account = [user.mobil stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@"****"];
        
    }

    
    currentUserAccount.text = account;
    
    currentUserAccount.textColor = XMGrayColor;
    
    currentUserAccount.font = [UIFont systemFontOfSize:14];
    
    [self.view addSubview:currentUserAccount];
    
    [currentUserAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(headerIV.mas_right).offset(13);
        
        make.width.equalTo(150);
        
        make.height.equalTo(10);
        
        make.centerY.equalTo(headerIV);
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加线条
    UIImageView *topLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_line"]];
    
    [self.view addSubview:topLine];
    
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(headerIV.mas_bottom).offset(10);
        
        make.left.equalTo(backIV);
        
        make.height.equalTo(1);
        
        make.right.equalTo(backIV);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加密码
    UIImageView *pwdIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_PwdIcon"]];
    
    [self.view addSubview:pwdIV];
    
    [pwdIV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(headerIV);
        
        make.top.equalTo(topLine.mas_bottom).offset(30);
        
        make.left.equalTo(headerIV);
        
        
    }];
   
    //-----------------------------seperate line---------------------------------------//
    //!< 添加密码label
    UILabel *pwdLabel = [UILabel new];
    
    pwdLabel.textColor = XMGrayColor;
    
    pwdLabel.font = [UIFont systemFontOfSize:14];
    
    pwdLabel.text = @"**********";
    
    [self.view addSubview:pwdLabel];
    
    [pwdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.equalTo(120);
        
        make.height.equalTo(10);
        
        make.left.equalTo(pwdIV.mas_right).offset(13);
        
        make.centerY.equalTo(pwdIV);
        
        
    }];
    
    if (!isCompany)
    {
        //-- 个人账号就添加修改密码功能
        
        //-----------------------------seperate line---------------------------------------//
        //!< 添加标记
        UIImageView *arrowIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_rightArrow"]];
        
        [self.view addSubview:arrowIV];
        
        [arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(backIV).offset(-39);
            
            make.centerY.equalTo(pwdIV);
            
            make.height.equalTo(16);
            
            make.width.equalTo(8);
            
            
        }];
        
        //!< 添加按钮
        
        UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [changeBtn setTitle:@"修改密码" forState:UIControlStateNormal];
        
        changeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        changeBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        
        
        [changeBtn addTarget:self action:@selector(changeBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        
        CGSize size = [@"修改密码" sizeWithAttributes:@{
                                                    NSFontAttributeName:[UIFont systemFontOfSize:14]
                                                    }];
        
        changeBtn.contentEdgeInsets = UIEdgeInsetsMake(15, 110-size.width, 15, 0);
        
        [self.view addSubview:changeBtn];
        
        [changeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(pwdIV);
            
            make.right.equalTo(arrowIV.mas_left).offset(-20);
            
            make.height.equalTo(40);
            
            make.width.equalTo(110);
            
        }];
        
    }
   
    //!< 添加线条
    UIImageView *bottomLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Login_line"]];
    
    [self.view addSubview:bottomLine];
    
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(pwdIV.mas_bottom).offset(10);
        
        make.left.equalTo(backIV);
        
        make.height.equalTo(1);
        
        make.right.equalTo(backIV);
        
    }];

}

//!< 点击更改密码按钮
- (void)changeBtnDidClick
{
    //!< 跳转到下一界面
    XMChangePWDViewController *changeVC = [XMChangePWDViewController new];
    
    [self.navigationController pushViewController:changeVC animated:YES];
    
    
}
//!< 点击退出出按钮
- (void)exitBtnDidClick
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
//     [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillResignActiveNotification object:nil];
    
     AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    delegate.sliderVC.mainVC = nil;
    
    [[XMSDKPlayer sharedPlayer] stopTrackPlay];//!< stop play FM
    
    
    //!< 删除账户信息
   [[NSFileManager defaultManager] removeItemAtPath:ACCOUNTPATH error:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:self.view];
        
        delegate.sliderVC.leftVC = nil;
        
        delegate.sliderVC = nil;
        
        
        
     [UIApplication sharedApplication].keyWindow.rootViewController = [[XMLoginNaviController alloc]initWithRootViewController:[XMLoginViewController new]];
        
        
    });
}
@end
