//
//  XMMessageViewController.m
//  kuruibao
//
//  Created by x on 16/9/13.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/**********************************************************
 class description:用来显示历史推送消息的界面
 
 **********************************************************/

#import "XMMessageViewController.h"

#import "MJRefresh.h"

#import "AFNetworking.h"

#import "XMUser.h"

#import "XMMonitorPushMessageCell.h"

#import "JPUSHService.h"


#define KEY @"pushmessage"


@interface XMMessageViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (strong, nonatomic) NSMutableArray *dataSource;//!< 数据源

@property (assign, nonatomic) int index;//!< 标记当前页码

@property (strong, nonatomic) XMUser *user;

@property (nonatomic,weak)UITableView* tableView;

@end

@implementation XMMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatSubViews];
    
 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [JPUSHService setBadge:0];

    MobClickBegain(@"推送消息界面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    MobClickEnd(@"推送消息界面");

}

- (void)creatSubViews
{
    
    self.index = 1;
    
    self.message = @"消息";
    
    [self.imageVIew removeFromSuperview];//!< 删除自带的图片
    
    //-----------------------------seperate line---------------------------------------//
    //!< 创建背景图
    UIImageView *backIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monitor_background"]];
    
    backIV.frame = self.view.bounds;
    
    [self.view addSubview:backIV];
    
    //-----------------------------seperate line---------------------------------------//
    //!< statusBar
    UIView *statusBar = [UIView new];
    
    statusBar.backgroundColor = XMTopColor;
    
    statusBar.frame = CGRectMake(0, 0, mainSize.width, 20);
    
    [backIV addSubview:statusBar];
    
    [self.view sendSubviewToBack:backIV];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加tableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
//    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.tableFooterView = [UIView new];
    
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.showsVerticalScrollIndicator = NO;
    
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    
//    [tableView.mj_footer beginRefreshing];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(statusBar.mas_bottom).offset(backImageH - 40);
        
        make.left.equalTo(backIV).offset(30);
        
        make.right.equalTo(backIV).offset(-30);
        
        make.bottom.equalTo(backIV).offset(-50);
        
    }];
    
    
    [self refreshData];//!< 刷新数据
}

#pragma mark -------------- lazy

- (NSMutableArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [NSMutableArray array];
    }

    return _dataSource;

}

- (XMUser *)user
{
     if (!_user)
    {
        _user = [XMUser user];
    }

    return _user;
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


#pragma mark -------------- UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.dataSource.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    XMMonitorPushMessageCell *cell = [XMMonitorPushMessageCell dequeueReuseableCellWithTableView:tableView];
    
    cell.pushMessage = self.dataSource[indexPath.row];
    
     return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *text = self.dataSource[indexPath.row];
    
    CGFloat width = tableView.bounds.size.width - 20;
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];

    return rect.size.height + 30;


}



#pragma mark -------------- 刷新数据

//!< 刷新数据的方法
- (void)refreshData
{
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"pushmessageget&Userid=%lu&Readstatus=0&Messagetype=0&Page=%d&Pagesize=20",(long)self.user.userid,self.index];
    
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         [_tableView.mj_footer endRefreshing];
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([result isEqualToString:@"0"])
        {
            //!< 没有推送数据
            
            [MBProgressHUD showError:@"没有推送数据"];
            
        }else if([result isEqualToString:@"-1"])
        {
            //!< 参数或者是网络错误
        }else
        {
            //!< 请求数据成功
        
            
            
            //!< 页码加一
            self.index ++;
            
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            NSArray *resultArr = resultDic[@"rows"];
            
            if (resultArr.count == 0)
            {
                [MBProgressHUD showError:@"没有更多数据"];
                
                return ;
            }
            
            NSInteger count = self.dataSource.count;
            
            for (NSDictionary *dic in resultArr)
            {
                NSString *message = dic[KEY];
                
                [self.dataSource addObject:message];
            }
        
           
            
            //!< 刷新表格
            
            NSMutableArray *indexPaths = [NSMutableArray array];
             
            for (int i = 0; i<resultArr.count; i++)
            {
                NSInteger row = count + i;
                
                NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
                
                [indexPaths addObject:ip];
            }
            
            
            
            //!< 插入新请求到的数据
            [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            
            //!< 将最新请求到的数据滚动到屏幕最顶端
            [_tableView scrollToRowAtIndexPath:indexPaths.firstObject atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //!< 请求数据失败
        [MBProgressHUD showError:@"网络超时"];
        
        [_tableView.mj_footer endRefreshing];
        
    }];
    
}

#pragma mark -------------- system

- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;

}


@end
