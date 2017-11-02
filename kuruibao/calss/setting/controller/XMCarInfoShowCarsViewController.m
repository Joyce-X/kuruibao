//
//  XMCarInfoShowCarsViewController.m
//  kuruibao
//
//  Created by x on 16/8/31.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 展示用户添加的所有车辆信息，没有添加车辆的话就显示label
 如果有显示车辆信息，点击cell跳转到车辆信息详情界面
 
 
 ************************************************************************************************/

#import "XMCarInfoShowCarsViewController.h"
#import "XMCarModel.h"
#import "XMShowCarCell.h"
#import "XMShowCarDataViewController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "XMCar.h"
#import "XMUser.h"
#import "XMAddViewController.h"
#import "MJRefresh.h"



@interface XMCarInfoShowCarsViewController()<UITableViewDelegate,UITableViewDataSource,XMShowCarDataViewControllerDelegate,XMAddViewControllerDelegate>

/**
 *  数据源
 */
@property (nonatomic,strong)NSMutableArray* dataSource;

/**
 *  tab
 */
@property (nonatomic,weak)UITableView* tableView;

/**
 *  提示Label
 */
@property (nonatomic,weak)UILabel* mesLabel;

@property (nonatomic,weak)UIButton* addBtn;//->>添加按钮

@property (nonatomic,strong)AFHTTPSessionManager* session;

@property (assign, nonatomic) int pageIndex;//!< 请求页码下标



@end
@implementation XMCarInfoShowCarsViewController


 

- (void)viewDidLoad
{
    [super viewDidLoad];

    //->>设置子视图
    [self setupSubViews];
    
 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"个人用户车辆列表页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"个人用户车辆列表页面");
    
}

#pragma mark --- subViews



/**
 *  设置子视图
 */
- (void)setupSubViews
{
    
    self.message =  @"我的车辆";
    
    self.pageIndex = 1;
    
     //->>创建tableView
    [self creatTableView];
    
    [self creatMessageLabel];//!< 创建label显示提示信息
    
//   if(!isCompany)
//   {
       //->>设置添加车辆按钮
       UIButton *addCar = [UIButton buttonWithType:UIButtonTypeCustom];
       
       [addCar setBackgroundImage:[UIImage imageNamed:@"setCar_add"] forState:UIControlStateNormal];
       
       [addCar setBackgroundImage:[UIImage imageNamed:@"setCar_add_highlighted"] forState:UIControlStateHighlighted];
     
       CGFloat btn_w = 55;
     
       CGFloat btn_h = btn_w;
       
       CGFloat btn_x = mainSize.width - btn_w - 15;
       
       CGFloat btn_y = backImageH - btn_h * 0.5;
       
       addCar.frame = CGRectMake(btn_x, btn_y, btn_w, btn_h);
       
       [addCar addTarget:self action:@selector(addCarDidClick:) forControlEvents:UIControlEventTouchUpInside];

       [self.view addSubview:addCar];
       
       self.addBtn = addCar;
//   }
    
    
}




- (void)creatTableView
{
 
    //->>设置tableView  有车辆的情况
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH) style:UITableViewStylePlain];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.rowHeight = 110;
    
    tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    __weak typeof(self) wself = self;
    
    
    
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            //-- 个人账户情况，刷新头部
            //!< 异步请求数据
            [wself updateData];
            
        }];
    
    
        [tableView.mj_header beginRefreshing];
 
   
    
 
}



#pragma mark --- lazy

- (NSMutableArray *)dataSource
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
- (void)creatMessageLabel
{
    
    UILabel *messageLabel = [UILabel new];
    
    messageLabel.text = @"点击加号开始添加车辆";
    
    messageLabel.textAlignment = NSTextAlignmentCenter;
    
    messageLabel.textColor = [UIColor lightGrayColor];
    
    messageLabel.font = [UIFont systemFontOfSize:17];
    
    messageLabel.frame = CGRectMake(0, backImageH, mainSize.width, 80);
    
    messageLabel.alpha = 0;
    
    messageLabel.hidden = YES;
    
    [self.view addSubview:messageLabel];
    
    self.mesLabel = messageLabel;
    
}




    

//!< 获取数据
- (void)updateData
{
    //    用户编号
    XMUser *user = [XMUser user];
    
    
    
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_list&Userid=%ld",(long)user.userid];
    
    
         [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
             [self.tableView.mj_header endRefreshing];
             
            NSString *result =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            if ([result isEqualToString:@"-1"])
            {
                //!< 网络异常
                [MBProgressHUD showError:@"网络错误,请检查网络连接"];

                
                
            }else if([result isEqualToString:@"0"])
            {
                 [MBProgressHUD showError:@"没有车辆信息"];
                
                self.messageLabel.hidden = NO;
                
                self.dataSource = nil;
                
                //!< 用户无车辆信息
                [UIView animateWithDuration:1 animations:^{
                    self.messageLabel.alpha = 1;
                }];
            
            }else
            {
                //!< 返回车辆列表信息  数据转模型进行处理
                self.dataSource = [XMCar mj_objectArrayWithKeyValuesArray:responseObject];
                
                if (self.tableView)
                {
                    
                    [self.tableView reloadData];//!< 刷新数据
                    
                }
            }
            
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
             
            [self.tableView.mj_header endRefreshing];
            
            [MBProgressHUD showError:@"网络错误,请检查网络连接"];
            
        }];
    
}




#pragma mark --- 监听按钮的点击事件

- (void)addCarDidClick:(UIButton *)sender
{
    XMAddViewController *vc = [XMAddViewController new];
    
    vc.delegate = self;
    
    vc.userCarCount = self.dataSource.count;//!< 传递用户车辆数据
     
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark --------------  XMAddViewControllerDelegate
 //->>车辆信息已经更新
- (void)carInfoDidUpdate:(XMAddViewController *)viewController;
{
    //!< 更新车辆信息
    [self carInfoDidUpdata:nil];
    
}

#pragma mark --- XMShowCarDataViewControllerDelegate

- (void)carInfoDidUpdata:(XMShowCarDataViewController *)viewController
{
    XMUser *user = [XMUser user];
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.requestSerializer = [AFHTTPRequestSerializer serializer];
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_list&Userid=%ld",(long)user.userid];
    
    [session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSString *result =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([result isEqualToString:@"-1"])
        {
            
            
            
        }else if([result isEqualToString:@"0"])
        {
            
            self.messageLabel.hidden = NO;
            //!< 用户无车辆信息
            [UIView animateWithDuration:1 animations:^{
                self.messageLabel.alpha = 1;
            }];
            
        }else
        {
            //!< 返回车辆列表信息  数据转模型进行处理
            self.messageLabel.hidden = YES;
            
            self.dataSource = [XMCar mj_objectArrayWithKeyValuesArray:responseObject];
            
            [self.tableView reloadData];//!< 刷新数据
           
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD showError:@"网络连接失败"];
        
    }];
    
}

#pragma mark --- UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.dataSource.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    
    
     XMShowCarCell *cell = [XMShowCarCell dequeueReusableCellWithTableView:tableView];
    
     cell.car = self.dataSource[indexPath.row];
    
     return cell;
    


}


#pragma mark --- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    XMShowCarDataViewController *vc = [XMShowCarDataViewController new];
    vc.delegate = self;
    vc.car = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];

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
 @end
