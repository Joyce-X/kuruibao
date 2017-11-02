//
//  XMBaseViewController.h
//  kuruibao
//
//  Created by x on 17/5/23.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MJExtension.h"

#import "AFNetworking.h"

#import "MJRefresh.h"

#import "XMUser.h"

#define connect ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable)

@interface XMBaseViewController : UIViewController

/**
 *  数据源
 */
@property (nonatomic,strong)NSMutableArray* dataSource;


/**
 会话请求
 */
@property (strong, nonatomic) AFHTTPSessionManager *session;

//!< 网络恢复
- (void)networkResume;

//!< 网络失去连接
- (void)networkDisconnect;




@end
