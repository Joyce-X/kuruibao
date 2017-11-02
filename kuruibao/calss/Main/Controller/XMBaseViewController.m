//
//  XMBaseViewController.m
//  kuruibao
//
//  Created by x on 17/5/23.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

//!< 根控制器
/**
 大部分类，继承自这个基类
 */

#import "XMBaseViewController.h"



@interface XMBaseViewController ()



@end

@implementation XMBaseViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //!< 监听网络变化的通知
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(networkDidChange:) name:XMNetWorkDidChangedNotification object:nil];
   

   

}


#pragma mark ------- lazy

-(NSMutableArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [NSMutableArray array];
    }

    return _dataSource;

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

#pragma mark ------- 响应通知的方法

- (void)networkDidChange:(NSNotification *)noti
{
    NSInteger result = [[noti.userInfo objectForKey:@"info"] integerValue];
    
    if (result == 1 || result == 2)
    {
        //!< 网络恢复
        [self networkResume];
        
    }else
    {
        //!< 网络断开
        [self networkDisconnect];
        
    }
    
}

//!< 网络恢复
- (void)networkResume
{
    XMLOG(@"---------网络恢复---------");
    
}
//!< 网络失去连接
- (void)networkDisconnect
{
    XMLOG(@"---------网络已断开---------");
    
}


#pragma mark ------- system

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [self.view endEditing:YES];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;

}

@end
