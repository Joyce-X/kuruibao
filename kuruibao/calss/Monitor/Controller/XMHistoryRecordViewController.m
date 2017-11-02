//
//  XMHistoryRecordViewController.m
//  kuruibao
//
//  Created by x on 17/5/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMHistoryRecordViewController.h"

#import "XMHistoryCell.h"

#import "XMTroubleItemModel.h"

#import "XMMonitorTroubleShowViewController.h"

@interface XMHistoryRecordViewController ()<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) UITableView *tableView;

@property (assign, nonatomic) int pageIndex;

@end

@implementation XMHistoryRecordViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    [self setupSubviews];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"历史故障页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"历史故障页面");
    
}

- (void)setupSubviews
{
    self.pageIndex = 1;
    
    //!< 背景
    UIImageView *backIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, mainSize.height)];
    
    backIV.image = [UIImage imageNamed:@"monitor_background"];
    
    [self.view addSubview:backIV];
    
    //-----------------------------seperate line---------------------------------------//
    
    //->>返回按钮
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftItem.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    [leftItem setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    [leftItem addTarget:self action:@selector(backToLast) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:leftItem];
    
    [leftItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(20);
        
        make.top.equalTo(self.view).offset(FITHEIGHT(48));
        
        make.size.equalTo(CGSizeMake(31, 31));
        
        
    }];
    
    //->>设置显示提示信息的label
    UILabel *message = [[UILabel alloc]init];
    
    message.textAlignment = NSTextAlignmentLeft;
    
    [message setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26]];//->>加粗
    
    message.textColor = XMColorFromRGB(0xF8F8F8);
    
    message.text = @"历史故障";
    
    [self.view addSubview:message];
    
    [message mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(25);
        
        make.width.equalTo(200);
        
        make.height.equalTo(31);
        
        make.top.equalTo(leftItem.mas_bottom).offset( FITHEIGHT(20));
        
        
    }];

    //!< 添加表格
    UITableView *tableView = [UITableView new];
    
    tableView.backgroundColor = XMClearColor;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.showsVerticalScrollIndicator = NO;

    
    
    tableView.tableFooterView = [UIView new];
    
    tableView.rowHeight = 66;
 
    
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        [self requestData];
        
    }];
    
    [tableView.mj_footer beginRefreshing];
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view).offset(25);
        
        make.right.equalTo(self.view).offset(-25);
        
        make.top.equalTo(message.mas_bottom).offset(56);
        
        make.bottom.equalTo(self.view);
        
    }];
    
}

- (void)requestData
{
    
//    /v2.ashx?key=XXXXXXX&method=getcommandhistory&参数=参数值………等等

    
    if (!connect)
    {
        
         [self.tableView.mj_footer endRefreshing];
        
        [MBProgressHUD showError:@"无网络" toView:self.view];
    }
    
    
    XMUser *user = [XMUser user];
    
//    self.qicheid = @"4";
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"getcommandhistory&Userid=%ld&qicheid=%@&Page=%d&Pagesize=20",user.userid,self.qicheid,self.pageIndex];
    
    
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.pageIndex++;
        
        [self.tableView.mj_footer endRefreshing];
        
        //!< 解析数据
        [self parseData:responseObject];
        
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.tableView.mj_footer endRefreshing];
        
        [MBProgressHUD showError:@"网络超时" toView:self.view];
        
    }];
    
    
}

- (void)parseData:(id)data
{
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                     
    if (str == nil || str.length < 2)
    {
        [MBProgressHUD showError:@"没有数据" toView:self.view];
        
        return;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSArray *result = dic[@"rows"];
    
    for (NSDictionary *recordDic in result)
    {
      
        id obj = recordDic[@"errorcodeindex"];
        
        if ([obj isKindOfClass:[NSNull class]])
        {
            continue;
        }
        
        if ([obj isKindOfClass:[NSString class]])
        {
            if ([(NSString *)obj  isEqualToString:@""])
            {
                continue;
            }
        }
        
        [self.dataSource addObject:recordDic];
        
    }
    
    if (self.dataSource.count == 0)
    {
        
         [MBProgressHUD showError:@"没有历史故障记录" toView:self.view];
        
        return;
    }
    
    
    [self.tableView reloadData];
    
}



#pragma mark ------- UITableViewDataSource,UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dataSource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"XMHistoryCell" owner:nil options:nil].firstObject;
    }

    NSDictionary *dic = self.dataSource[indexPath.row];
    
    cell.dic = dic;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMHistoryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *dic = cell.dic;
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Getcommandresult&Controlid=%@",dic[@"controlid"]];
    
    [MBProgressHUD showMessage:nil toView:self.view];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString *str = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if (str == nil || str.length < 4)
        {
            return;
        }
        
        
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:arr.count];
        
        for (NSDictionary *dic_p in arr)
        {
            
            XMTroubleItemModel *model = [[XMTroubleItemModel alloc]initWithDictionary:dic_p];
            
            [arrM addObject:model];
            
        }
        
        XMMonitorTroubleShowViewController *vc = [XMMonitorTroubleShowViewController new];
        
        vc.troubleArray = [arrM copy];
        
        [self.navigationController pushViewController:vc animated:YES];
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
         [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [MBProgressHUD showError:@"网络超时"];
    }];

}


/**
 点击返回按钮
 */
- (void)backToLast
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}



@end
