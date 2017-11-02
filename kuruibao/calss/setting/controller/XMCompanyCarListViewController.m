//
//  XMCompanyCarListViewController.m
//  kuruibao
//
//  Created by x on 17/5/24.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/**
    如果为企业用户的时候，显示的车辆列表界面
 */
#import "XMCompanyCarListViewController.h"

#import "AppDelegate.h"

#import "XMCar.h"

#import "XMCompany_section0_view.h"

#import "XMCompany_section1_cellTableViewCell.h"

#import "XMCompanySearchViewController.h"

#define pageSize 10000

@interface XMCompanyCarListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *driveArray;//!< 行驶车辆数组

@property (strong, nonatomic) NSMutableArray *stopArray;//!< 停驶车辆数组

@property (strong, nonatomic) NSMutableArray *lostArray;//!< 失联车辆数组

@property (strong, nonatomic) NSMutableArray *subViewsArray;//!< 存放按钮数组

/**
 行驶按钮的选中状态
 */
@property (assign, nonatomic) BOOL driveState;

/**
 停驶按钮的选中状态
 */
@property (assign, nonatomic) BOOL stopState;

/**
 失联按钮的选中状态
 */
@property (assign, nonatomic) BOOL lostState;

/**
 存放所有车数据
 */
@property (strong, nonatomic) NSMutableArray *allCarsArray;



/**
 显示在第一个分区的view
 */
@property (weak, nonatomic) UIView *sec0_view;


@end

@implementation XMCompanyCarListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupSubviews];
     
}



- (void)setupSubviews
{
    
    //!< 获取上一次按钮的状态
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    
    self.driveState = [df boolForKey:@"driveState"];
    
    self.stopState = [df boolForKey:@"stopState"];
    
    self.lostState = [df boolForKey:@"lostState"];

//    //!<第一次加载界面的时候为全部选中的状态
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        self.driveState = YES;
//        
//        self.stopState = YES;
//        
//        self.lostState = YES;
//        
//        
//    });
    
    
    //!< 初始化数组
    self.driveArray = [NSMutableArray array];
    
    self.stopArray = [NSMutableArray array];
    
    self.lostArray = [NSMutableArray array];
    
    self.subViewsArray = [NSMutableArray array];
    
     self.allCarsArray = [NSMutableArray array];

    
    //->>背景
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *backIV = [UIImageView new];
    
    backIV.image = [UIImage imageNamed:@"carLife_breakRule_background"];
    
    backIV.frame = self.view.bounds;
    
    [self.view addSubview:backIV];
    
    
    //!< 状态栏
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    statusBar.backgroundColor = XMTopColor;
    
    [self.view addSubview:statusBar];
    
    //->>返回按钮
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftItem.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 5, 5);
    
    [leftItem setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    [leftItem addTarget:self action:@selector(backToLast) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:leftItem];
    
    [leftItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(15);
        
        make.top.equalTo(self.view).offset(FITHEIGHT(43));
        
        make.size.equalTo(CGSizeMake(36, 36));
        
        
    }];
    
    //->>设置显示提示信息的label
    UILabel *message = [[UILabel alloc]init];

    message.textAlignment = NSTextAlignmentLeft;
    
    message.text = @"车辆列表";
    
    [message setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26]];//->>加粗
    
    message.textColor = XMColorFromRGB(0xF8F8F8);
    
    [self.view addSubview:message];
    
    [message mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(20);
        
        make.width.equalTo(200);
        
        make.height.equalTo(31);
        
        make.top.equalTo(leftItem.mas_bottom).offset(FITHEIGHT(20));
        
        
    }];
    
    
    //!< 搜索按钮
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [searchBtn setImage:[UIImage imageNamed:@"companyCarList_search"] forState:UIControlStateNormal];
    
    [searchBtn setImage:[UIImage imageNamed:@"companyCarList_search"] forState:UIControlStateHighlighted];

    [searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
     searchBtn.contentEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    
    [self.view addSubview:searchBtn];
    
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(50, 50));
        
        make.right.equalTo(self.view).offset(-10);
        
        make.top.equalTo(leftItem).offset(0);
        
    }];
    
    
    //!< 行驶按钮
    UIButton *driveBtn = [self createBtnWithTitle:@"行驶中" tag:10 select:self.driveState ];
    
    [driveBtn addTarget:self action:@selector(operateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:driveBtn];
    
    [self.subViewsArray addObject:driveBtn];
    
    [driveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(message.mas_bottom).offset(32);
        
        make.size.equalTo(CGSizeMake(68, 20));
        
        make.left.equalTo(self.view).offset(20);
        
        
    }];
    
    //!< 停驶按钮
    UIButton *stopBtn = [self createBtnWithTitle:@"停驶中" tag:11 select:self.stopState];
    
    [stopBtn addTarget:self action:@selector(operateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:stopBtn];
    
    [self.subViewsArray addObject:stopBtn];
    
    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(message.mas_bottom).offset(32);
        
        make.size.equalTo(CGSizeMake(68, 20));
        
        make.left.equalTo(driveBtn.mas_right).offset(12);
        
        
    }];
    
    //!< 失联按钮
    UIButton *lostBtn = [self createBtnWithTitle:@"失联" tag:12 select:self.lostState];
    
    [lostBtn addTarget:self action:@selector(operateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:lostBtn];
    
    [self.subViewsArray addObject:lostBtn];
    
    [lostBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(message.mas_bottom).offset(32);
        
        make.size.equalTo(CGSizeMake(68, 20));
        
        make.left.equalTo(stopBtn.mas_right).offset(12);
        
        
    }];
    
    
    //!< 创建表
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.backgroundColor = XMClearColor;
//    tableView.backgroundView = [UIImage new];
    
    tableView.tableFooterView = [UIView new];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.equalTo(self.view);
        
        make.top.equalTo(driveBtn.mas_bottom).offset(20);
        
    }];
    
        UILabel * textLabel = [UILabel new];
    //
        textLabel.font = [UIFont systemFontOfSize:20];

        textLabel.backgroundColor = XMClearColor;

        textLabel.textColor = [UIColor whiteColor];

        textLabel.frame = CGRectMake(24.5, 0, 200, 30);

        textLabel.tag = 134;

        textLabel.text = @"    当前车辆";
    
    tableView.tableHeaderView = textLabel;
 
    
    //!< 请求数据
    [self getUserAllCars_company];
    
}

#pragma mark ------- btn click


/**
 点击返回按钮
 */
- (void)backToLast
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (tempAppDelegate.sliderVC.closed)
    {
        [tempAppDelegate.sliderVC openLeftView];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

/**
 点击搜索按钮
 */
- (void)searchBtnClick
{
    XMLOG(@"---------search click---------");
    if (self.allCarsArray.count == 0)
    {
        [MBProgressHUD showError:@"获取数据失败" toView:self.view];
        
        return;
    }
    
    //!< 展示搜索控制器
    XMCompanySearchViewController *vc = [XMCompanySearchViewController new];
    
    vc.allCars = self.allCarsArray;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


/**
 点击操作按钮

 @param sender 事件发送者
 */
- (void)operateBtnClick:(UIButton *)sender
{
    
    sender.selected = !sender.selected;
    
    if (sender.selected)
    {
        //!< 选中就设置背景和边框
        sender.backgroundColor = XMGreenColor;
        
        sender.layer.borderColor = XMClearColor.CGColor;
        
    }else
    {
        sender.backgroundColor = XMClearColor;
        
        sender.layer.borderColor = XMWhiteColor.CGColor;
    
    }
    
    //!< 如果没有数据就返回
    if (self.allCarsArray.count == 0)
    {
        return;
    }
    
    [self.dataSource removeAllObjects];
    
    for (int i = 0;i< 3;i++)
    {
        
        UIButton *btn = self.subViewsArray[i];
        
        if (i == 0)
        {
            if (btn.selected)
            {
                [self.dataSource addObjectsFromArray:self.driveArray];
            }
            
            
        }
        
        if (i == 1)
        {
            if (btn.selected)
            {
                [self.dataSource addObjectsFromArray:self.stopArray];
            }
            
            
        }
        
        if (i == 2)
        {
            if (btn.selected)
            {
                [self.dataSource addObjectsFromArray:self.lostArray];
            }
            
            
        }
        
        
    }
    
    [self.tableView reloadData];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
    
}

#pragma mark ------- 请求数据

//!< 获取用户所有车辆
- (void)getUserAllCars_company
{
    
    if (!connect)
    {
        [MBProgressHUD showError:@"网络未连接"];
        
        return;
    }
    
    //!< 请求数据
    [MBProgressHUD showMessage:nil toView:self.view];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"c_qiche_list&companyid=%ld&Page=1&Pagesize=%d",(long)[XMUser user].companyid,pageSize];
    
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        NSString *stateCode =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([stateCode isEqualToString:@"0"])
        {
            
            [MBProgressHUD showError:@"网络错误" toView:self.view];
            
            return ;
            
        }else if ([stateCode isEqualToString:@"-1"])
        {
            
            XMLOG(@"用户没有车辆信息");
            [MBProgressHUD showError:@"用户没有车辆信息" toView:self.view];
            
            
            return;
        }
        
        
        //!< 请求到数据，修改数据源，刷新表格
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSArray *carList = result[@"rows"];
        
        if (carList.count == 0)
        {
            [MBProgressHUD showError:@"没有更多数据" toView:self.view];
            
            return;
        }
        
        
        for (NSDictionary *dic in carList)
        {
            XMCar *car = [[XMCar alloc]initWithDictionaryForCompany:dic];
            
            //!< 保存所有车辆，搜索界面用
            [self.allCarsArray addObject:car];
            
            //!< 跳过当前已经选中的车辆
            if ([car.chepaino isEqualToString:_carNumber])
            {
                continue;
            }
            
            switch (car.currentstatus)//!< 0 停驶  1 行驶  2 失联
            {
                case 0:
                    
                    [self.stopArray addObject:car];
                    
                    break;
                    
                case 1:
                    
                    [self.driveArray addObject:car];
                    
                    break;
                    
                case 2:
                    
                    [self.lostArray addObject:car];
                    
                    break;
                    
                default:
                    break;
            }
            
            
            
        }//kCheXiaoMiUserDidUpdateCarInfoNotification
        //-- 发送通知通知其他界面数据更新
        [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil userInfo:@{@"mode":@"cars",@"result":self.allCarsArray}];
        
        if (self.driveState)
        {
            [self.dataSource addObjectsFromArray:self.driveArray];
        }
        
        if (self.stopState)
        {
            [self.dataSource addObjectsFromArray:self.stopArray];
        }
        
        if (self.lostState)
        {
            [self.dataSource addObjectsFromArray:self.lostArray];
        }
        
        [self.tableView reloadData];//!< 刷新数据
        
        
        XMLOG(@"成功获取用户车辆列表");
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"网络超时"];
        
        XMLOG(@"获取用户汽车列表失败");
        
    }];
    
}

#pragma mark ------- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    
    return section == 0 ? 1 : self.dataSource.count;


}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    XMCompany_section1_cellTableViewCell *cell = [XMCompany_section1_cellTableViewCell dequeueWithTableView:tableView];
    
    if (indexPath.section == 0)
    {
        cell.carModel = self.defaultCar;
        if ([self.defaultCar isKindOfClass:[NSArray class]])
        {
            
            XMLOG(@"---------1111111111111111111111111111---------");
            
            XMLOG(@"---------%@---------",self.defaultCar);
            
        }
        cell.backgroundColor =  [UIColor colorWithRed:1 green:1 blue:1 alpha:0.15];
        
    }else
    {
    
        cell.carModel = self.dataSource[indexPath.row];

        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.05];

        
    }
    
    return cell;
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    return [UIView new];
   
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return section == 0 ? 0 : 10;

}

#pragma mark --- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //-- 判断是否正在检测
    //!< 如果正在检测车辆
    if([XMCheckManager shareManager].isChecking)
    {
        
        [MBProgressHUD showError:@"正在检测车辆,暂时不可切换"];
        
        return;
        
    }
    
    if (indexPath.section == 0)
    {
        //!< 点击的是默认车辆
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMShowCarVCCellClickNotification object:nil userInfo:@{@"carModel" : self.defaultCar}];
        
        return;
    }
    
    
    
        
        //-- 判断当前点击的是否是主界面的默认车辆
        
        XMCar *selectedCar = self.dataSource[indexPath.row];
        
        if ([self.carNumber isEqualToString:selectedCar.chepaino])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"当前车辆不可选" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            
            [alert show];
            
            return;
        }
    
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMShowCarVCCellClickNotification object:nil userInfo:@{@"carModel" : self.dataSource[indexPath.row]}];
        
        return;
    
    
    
}




#pragma mark ------- tool


/**
 创建按钮
 @param title 标题
 @param tag 标签
 @return btn
 */
- (UIButton *)createBtnWithTitle:(NSString *)title tag:(NSInteger)tag select:(BOOL)state
{
    
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.layer.cornerRadius = 2.5;
    
    btn.layer.borderColor = XMClearColor.CGColor;
    
    btn.layer.borderWidth = 0.5;
    
    btn.clipsToBounds = YES;
    
    [btn setTitleColor:XMWhiteColor forState:UIControlStateNormal];
    
    [btn setTitleColor:XMWhiteColor forState:UIControlStateSelected];
    
    [btn setTitle:title forState:UIControlStateNormal];
    
    [btn setTitle:title forState:UIControlStateSelected];
    
    [btn setBackgroundColor:XMGreenColor];

    btn.selected = state;
    
    btn.tag = tag;
    
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    if (state)
    {
        
        //!< 选中就设置背景和边框
        btn.backgroundColor = XMGreenColor;
        
        btn.layer.borderColor = XMClearColor.CGColor;
        
    }else
    {
        
        btn.backgroundColor = XMClearColor;
        
        btn.layer.borderColor = XMWhiteColor.CGColor;
        
        
    }
    
    return btn;
    
}


#pragma mark ------- system

- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;

}

#pragma mark ------- inherit  method

- (void)networkResume
{
    //!< 网络恢复时候，判断是否需要重新请求数据
    if (self.allCarsArray.count == 0)
    {
        [self getUserAllCars_company];
    }
    

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //!< 在页面即将销毁的时候，保存按钮的状态
    //!< 判断上次选中的按钮
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    
    UIButton *driveBtn = [self.view viewWithTag:10];
    
    UIButton *stopBtn = [self.view viewWithTag:11];
    
    UIButton *lostBtn = [self.view viewWithTag:12];
    
    [df setBool:driveBtn.selected forKey:@"driveState"];
    
    [df setBool:stopBtn.selected forKey:@"stopState"];
    
    [df setBool:lostBtn.selected forKey:@"lostState"];

    //!< 立即保存
    [df synchronize];
    
    MobClickBegain(@"企业用户车辆列表页面");
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"企业用户车辆列表页面");

}

@end
