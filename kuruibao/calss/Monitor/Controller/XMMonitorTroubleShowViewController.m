//
//  XMMonitorTroubleShowViewController.m
//  kuruibao
//
//  Created by x on 16/11/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/**********************************************************
 class description:专门用来展示问题项列表
 
 **********************************************************/

#import "XMMonitorTroubleShowViewController.h"

#import "XMTroubleItemModel.h"

#import "XMMonitorTroubleCell.h"


//#import "MJRefresh.h"

#import "AFNetworking.h"


@interface XMMonitorTroubleShowViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak)UITableView* tableView;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (nonatomic,weak)UILabel* timeLabel;


@end


@implementation XMMonitorTroubleShowViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
    
    [self updateData];//!< 更新时间
    
 
 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"展示问题项页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"展示问题项页面");
    
}

- (void)setupInit
{
    
    //!< 背景图
    UIImageView *backIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monitor_background"]];
    
    backIV.frame = self.view.bounds;
    
    [self.view addSubview:backIV];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 状态栏
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    statusBar.backgroundColor = XMTopColor;
    
    [self.view addSubview:statusBar];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 返回按钮
    //->>返回按钮
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftItem.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    [leftItem setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    [leftItem addTarget:self action:@selector(backBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:leftItem];
    
    [leftItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(20);
        
        make.top.equalTo(self.view).offset(FITHEIGHT(48));
        
        make.size.equalTo(CGSizeMake(31, 31));
        
        
    }];
    
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 展示消息的Label
    
    UILabel *message = [[UILabel alloc]init];
    
     message.textAlignment = NSTextAlignmentLeft;
    
    [message setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26]];//->>加粗
    
    message.textColor = XMColorFromRGB(0xF8F8F8);
    
    [self.view addSubview:message];
    
    NSString *title;
    
    switch (self.index)
    {
        case 0:
            
            title = @"发动机系统";
            
            break;
            
        case 1:
            
             title = @"电子刹车系统";
            
            break;
            
        case 2:
            
             title = @"车身控制系统";
            
            break;
            
        case 3:
            
             title = @"车辆其他项";
            
            break;
            
        default:
            break;
    }
    
    
    message.text = title;
    
    [message mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(25);
        
        make.width.equalTo(200);
        
        make.height.equalTo(31);
        
        make.top.equalTo(leftItem.mas_bottom).offset( FITHEIGHT(20));
        
        
    }];

    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加显示检测时间的Label
    
    UILabel *checkLabel = [UILabel new];
    
    checkLabel.text = @"检测时间:";
    
    checkLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    
    checkLabel.textColor = [UIColor whiteColor];
    
    CGSize size = [checkLabel.text sizeWithAttributes:@{
                        NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:15]
                                                }];
    
    [self.view addSubview:checkLabel];
    
    [checkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backIV).offset(36);
        
        make.top.equalTo(statusBar.mas_bottom).offset(FITHEIGHT(176));
        
        make.size.equalTo(size);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加显示时间
    UILabel *timeLabel = [UILabel new];
    
    timeLabel.textColor = [UIColor whiteColor];
    
    timeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    
    df.dateFormat = @"yyyy.MM.dd-HH.mm";
    
    NSString *timeStr = [df stringFromDate:[NSDate date]];
    
    timeLabel.text = timeStr;
    
    [self.view addSubview:timeLabel];
    
    self.timeLabel = timeLabel;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(checkLabel.mas_right).offset(5);
        
        make.centerY.equalTo(checkLabel);
        
        make.height.equalTo(checkLabel);
        
        make.width.equalTo(200);
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加显示问题项的View
    UIView *proView = [UIView new];
    
    proView.backgroundColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    
    [self.view addSubview:proView];
    
    [proView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(checkLabel.mas_bottom).offset(10);
        
        make.bottom.equalTo(backIV).offset(-70);
        
        make.left.equalTo(backIV).offset(26);
        
        make.right.equalTo(backIV).offset(-26);
        
    }];
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加线条
    UIView *line = [UIView new];
    
    line.backgroundColor  =XMGrayColor;
    
    [proView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(proView).offset(20);
        
        make.bottom.equalTo(proView).offset(-20);
        
        make.width.equalTo(1);
        
        make.left.equalTo(proView).offset(59);
        
        
    }];

    //-----------------------------seperate line---------------------------------------//
    //!< 添加显示问题项个数的label
    
    UILabel *numberLabel = [UILabel new];
    
    numberLabel.textColor = [UIColor whiteColor];
    
    numberLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:40];
    
    numberLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)self.troubleArray.count];
    
    numberLabel.textAlignment = NSTextAlignmentCenter;
    
    [proView addSubview:numberLabel];
    
    CGSize size_numbs = [numberLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:40]}];
    
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(line);
        
        make.right.equalTo(line).offset(-8);
        
        make.size.equalTo(size_numbs);
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示item
    UILabel *itemLabel = [UILabel new];
    
    itemLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    
    itemLabel.text = @"ITEM";
    
    itemLabel.textColor = [UIColor whiteColor];
    
    itemLabel.textAlignment = NSTextAlignmentRight;
    
    [proView addSubview:itemLabel];
    
    [itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(numberLabel);
        
        make.top.equalTo(numberLabel.mas_bottom).offset(4);
        
        make.width.equalTo(50);
        
        make.height.equalTo(9);
        
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    //  tableView
    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
 
    tableView.delegate = self;
 
    tableView.dataSource = self;
 
    tableView.backgroundColor = [UIColor clearColor];
 
    tableView.tableFooterView  = [UIView new];
 
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [proView addSubview:tableView];
    
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(line.mas_right);
        
        make.right.equalTo(proView);
        
        make.top.equalTo(line);
        
        make.bottom.equalTo(line);
        
    }];
 
    
    
    
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



#pragma mark -------------- get new data

- (void)updateData
{
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"getcommandhistory&Userid=%@&qicheid=%@&Page=1&Pagesize=10",self.userid,self.qicheid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if (result.length > 2)
        {
            //!< 获取数据成功，对数据进行解析
            
            //!< 检测记录数组
            NSArray *records = [[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil] objectForKey:@"rows"];
            
            NSDictionary *dic = [records firstObject];
            
            NSString *timeStr = dic[@"createtime"];
            
            NSString *year = [timeStr substringWithRange:NSMakeRange(0, 4)];
            NSString *month = [timeStr substringWithRange:NSMakeRange(5, 2)];
            NSString *day = [timeStr substringWithRange:NSMakeRange(8, 2)];
            NSString *hour = [timeStr substringWithRange:NSMakeRange(11, 2)];
            NSString *minute = [timeStr substringWithRange:NSMakeRange(14, 2)];
            NSString *second = [timeStr substringWithRange:NSMakeRange(17, 2)];
            
            self.timeLabel.text = [NSString stringWithFormat:@"%@.%@.%@-%@.%@.%@",year,month,day,hour,minute,second];
            
            
        }
        
        
    } failure:nil];
    
    
    
}



#pragma mark -------------- btn Click

- (void)backBtnDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


#pragma mark -------------- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 
    return self.troubleArray.count;
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

   
    XMMonitorTroubleCell *cell = [XMMonitorTroubleCell dequeueReuseableCellWithTableView:tableView];
    
    XMTroubleItemModel *trouble =  self.troubleArray[indexPath.row];

    cell.model = trouble;
    
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMTroubleItemModel *trouble =  self.troubleArray[indexPath.row];

    CGFloat width = tableView.bounds.size.width - 66;
    
    CGRect rect = [trouble.codedesc boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    
    return rect.size.height + 10;
    
    
    

}
#pragma mark -------------- system

- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;

}

@end
