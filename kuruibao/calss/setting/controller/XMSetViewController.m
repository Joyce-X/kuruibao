//
//  XMSetViewController.m
//  kuruibao
//
//  Created by x on 16/8/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 展示详细的设置信息界面
 
 
 ************************************************************************************************/

#import "XMSetViewController.h"
#import "XMSetting_detailView.h"
#import "AppDelegate.h"
#import "XMSet_accountViewController.h"
#import "XMSet_offLineMapViewController.h"
#import "XMSet_helpViewController.h"
#import "XMSet_userBackViewController.h"
#import "AFNetworking.h"
#import "XMUser.h"



@interface XMSetViewController()<XMSetting_detailViewDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *session;

@end

@implementation XMSetViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self creatSubViews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"设置子页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"设置子页面");
    
}


#pragma mark --- lazy

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

- (void)creatSubViews
{
    self.message = @"设置";
    self.view.backgroundColor = XMColorFromRGB(0xF8F8F8);
   
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH)];
    tableView.tableFooterView = [UIView new];
    tableView.backgroundColor = XMColorFromRGB(0xF8F8F8);
    [self.view addSubview:tableView];
    
    XMSetting_detailView *detailView = [XMSetting_detailView shared];
    
    detailView.delegate = self;
    
    detailView.isSelected =  [[NSUserDefaults standardUserDefaults] boolForKey:@"btnState"];
    
    [self setupCallBackForView:detailView];
    
    detailView.frame = CGRectMake(0, 20, 0, 378);
    
    tableView.tableHeaderView = detailView;
 
  
    
}

- (void)backToLast
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (tempAppDelegate.sliderVC.closed)
    {
        [tempAppDelegate.sliderVC openLeftView];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
 
}

//->>设置回调
- (void)setupCallBackForView:(XMSetting_detailView *)view
{
    view.setAccount = ^{
        
        XMSet_accountViewController *vc = [[XMSet_accountViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        
        
    };
    
//    view.offLineMap = ^{
//        
//        XMSet_offLineMapViewController *vc = [[XMSet_offLineMapViewController alloc]init];
//        [self.navigationController pushViewController:vc animated:YES];
//        
//        
//    };
    
    view.helping = ^{
        
        XMSet_helpViewController *vc = [[XMSet_helpViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        
        
    };
    
    view.userBack = ^{
        
        XMSet_userBackViewController *vc = [[XMSet_userBackViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        
        
    };
    
   
    
    view.haoPing = ^{
        
        //->>点击进行评分
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1185454831"]];
// 1185454831  529826126
        
    };


}

//!< 点击消息推送按钮
- (void)pushMessageBtnDidClick:(UIButton *)sender
{
    
    NSString *Value;
    
    if (sender.selected) {
        
        //!< 当前是选中状态，需要执行关闭推送
        Value = @"0";
        
    }else
    {
        
        //!< 当前是为选中状态，需要执行打开操作
       Value = @"1";
    
    }
    
    XMUser *user = [XMUser user];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"pushsetting&userid=%ld&type=0&Value=%@",(long)user.userid,Value];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];

        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if (result.intValue == 1)
        {
            
            sender.selected = !sender.selected;
            
            [MBProgressHUD showSuccess:@"操作成功"];
            
            [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:@"btnState"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
        }else
        {
        
            [MBProgressHUD showError:@"操作失败"];
        
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"操作失败"];
        
    }];
    
    



}











@end
