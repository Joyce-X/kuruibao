//
//  XMRouteViewController.m
//  KuRuiBao
//
//  Created by x on 16/6/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:显示用户
 
 **********************************************************/
#import "XMRouteViewController.h"
#import "AFNetworking.h"
#import "XMTrackCell.h"
#import "MJRefresh.h"
#import "XMDefaultCarModel.h"
#import "XMUser.h"
#import "XMTrackAverageStateModel.h"
#import "XMTrackSegmentStateModel.h"
#import "NSDictionary+convert.h"
#import "CalendarViewController.h"
#import "XMTrackScoreViewController.h"
#import "XMEnlargeMapViewController.h"

#import "XMTrackCell_baidu.h"

#import "XMEnlargeMapViewController_BDViewController.h"

#define headerFooterIdentifier @"headerFooterViewIdentifier"

//!< 获取时间类型
typedef NS_ENUM(NSUInteger, XMTimeType) {
    XMTimeTypeAll,//!< 当前年月日yyyy年MM月dd日
    XMTimeTypeDay,//!< 当前是几号
    XMTimeTypeFormatter//yyyy-MM-dd
 };

@interface XMRouteViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) XMDefaultCarModel *defaultCar;//!< 用户默认车辆

@property (nonatomic,weak)UILabel* timeLabel;//!< 显示当天全部时间的Label

@property (nonatomic,weak)UIButton* dayButton;//!<显示当天的日期(中间最大的数字)

@property (nonatomic,weak)UILabel* distanceLabel;//!< 显示行驶里程的label

@property (nonatomic,weak)UILabel* moneyLabel;//!< 显示所花费的RMBlabel

@property (nonatomic,weak)UILabel* oilConsumptionLabel;//!< 显示油耗的label

@property (strong, nonatomic) NSArray *dataSource;//!< 数据源

@property (nonatomic,weak)UITableView* tableView;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (assign, nonatomic) BOOL notActive;//!< 没有激活

@property (assign, nonatomic) BOOL notCar;//!< 没有车辆

@property (strong, nonatomic) XMTrackAverageStateModel *averageModel;

@property (strong, nonatomic) NSMutableArray *sectionArray;//!< 分区是否展开

@property (copy, nonatomic) NSString *selectedDateStr;//!< 从日历选择的日期

@property (nonatomic,weak)UIButton* rightArrowBtn;

@end



@implementation XMRouteViewController


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
    
        //!< 监听用户的默认车辆获取成功或全部车辆获取成功的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(carInfodidChanged:) name:kCheXiaoMiUserDidUpdateCarInfoNotification object:nil];
        
     }
    
    return self;
}



#pragma mark -------------- life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupInit];
    
    //!< 刷新数据
    [self.tableView.mj_header beginRefreshing];


}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;

    MobClickBegain(@"轨迹主界面");
    
    [MobClick event:@"Click_Trajectory"];
    
    XMLOG(@"---------youmeng---进入轨迹界面---------");
    

}

- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    
    MobClickEnd(@"轨迹主界面");

}



#pragma mark -------------- init

//!< 初始化控件
- (void)setupInit
{
    
//    self.sectionArray = [NSMutableArray arrayWithObject:@(0)];
    self.sectionArray = [NSMutableArray array];
    
    //!< 状态栏
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    statusBar.backgroundColor = XMTopColor;
    
    [self.view addSubview:statusBar];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 背景
    UIImageView *backgroundIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monitor_background"]];
    
    backgroundIV.frame = CGRectMake(0, 20, mainSize.width, mainSize.height - 20 - 49);
    
    backgroundIV.userInteractionEnabled = YES;
    
    [self.view addSubview:backgroundIV];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 查看得分按钮
    
    UIButton *scoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [scoreBtn setImage:[UIImage imageNamed:@"track_scoer"] forState:UIControlStateNormal];
    
    [scoreBtn setImage:[UIImage imageNamed:@"track_scoer"] forState:UIControlStateHighlighted];
    
    [scoreBtn addTarget:self action:@selector(scoerBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];

    scoreBtn.contentEdgeInsets = UIEdgeInsetsMake(7, 8, 8, 7);
    
    [self.view addSubview:scoreBtn];
    
    [scoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(backgroundIV).offset(-17);
        
        make.size.equalTo(CGSizeMake(35, 35));
        
        make.top.equalTo(backgroundIV).offset(18);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 当天日期(年月日周)
    UILabel *timeLabel = [self labelWithFont:16 textColor:nil textAlignment:NSTextAlignmentCenter];
    
    timeLabel.text = [self getCurrentDateWitgTimeType:XMTimeTypeAll timeStr:nil];
    
    [self.view addSubview:timeLabel];
    
    self.timeLabel = timeLabel;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(mainSize.width, 16));
        
        make.top.equalTo(scoreBtn.mas_bottom).offset(30);
        
        make.centerX.equalTo(backgroundIV);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< day（日）
    
    UIButton *dayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [dayButton setTitle:[self getCurrentDateWitgTimeType:XMTimeTypeDay timeStr:nil] forState:UIControlStateNormal];
    
    dayButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:70];
    
    [dayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [dayButton addTarget:self action:@selector(dayButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:dayButton];
    
    self.dayButton = dayButton;
    
    [dayButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(timeLabel.mas_bottom).offset(20);
        
        make.size.equalTo(CGSizeMake(105, 55));
        
        make.centerX.equalTo(timeLabel);
        
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< left arrow
    
    UIButton *leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftArrow setImage:[UIImage imageNamed:@"track_leftArrow"] forState:UIControlStateNormal];
    
    [leftArrow addTarget:self action:@selector(leftArrowDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    leftArrow.contentEdgeInsets = UIEdgeInsetsMake(5, 12, 5, 23);
    
    [self.view addSubview:leftArrow];
    
    [leftArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(dayButton);
        
        make.left.equalTo(backgroundIV).offset(19);
        
        make.height.equalTo(40);
        
        make.width.equalTo(50);
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< right arrow
    
    UIButton *rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightArrow setImage:[UIImage imageNamed:@"track_rightArrow"] forState:UIControlStateNormal];
    
     [rightArrow setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateDisabled];
    
    [rightArrow addTarget:self action:@selector(rightArrowDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    rightArrow.enabled = NO;
    
    rightArrow.contentEdgeInsets = UIEdgeInsetsMake(5, 22, 5, 13);
    
    [self.view addSubview:rightArrow];
    
    self.rightArrowBtn = rightArrow;
    
    
    [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(dayButton);
        
        make.right.equalTo(backgroundIV).offset(-19);
        
        make.height.equalTo(40);
        
        make.width.equalTo(50);
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示行驶里程图片
    UIImageView *distabceImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_distance"]];
    
    distabceImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:distabceImageView];
    
    [distabceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backgroundIV).offset(24);
        
        make.top.equalTo(dayButton.mas_bottom).offset(20);
        
        make.size.equalTo(CGSizeMake(15, 15));
        
    }];
    
    //!< 显示money图片
    UIImageView *moneyImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_totalMoney"]];
    
    moneyImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:moneyImageView];
    
    [moneyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(backgroundIV).offset(FITWIDTH(138));
        
        make.bottom.equalTo(distabceImageView);
        
        make.size.equalTo(CGSizeMake(15, 15));
        
    }];
    
    
    //!< 显示油耗图片
    UIImageView *oilConsumptionImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_oilConsumption"]];
    
    oilConsumptionImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:oilConsumptionImageView];
    
    [oilConsumptionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(backgroundIV).offset(-FITWIDTH(75));
        
        make.bottom.equalTo(distabceImageView);
        
        make.size.equalTo(CGSizeMake(15, 15));
        
    }];
    
    
    //!< 显示行驶里程label
    
    UILabel *distanceLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentLeft];
    
    distanceLabel.text = @"0.00 km";
    
    distanceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.view addSubview:distanceLabel];
    
    self.distanceLabel = distanceLabel;
    
    [distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(distabceImageView);
        
        make.left.equalTo(distabceImageView.mas_right).offset(6);
        
        make.right.equalTo(moneyImageView.mas_left);
        
        make.height.equalTo(13);
        
    }];
    
    
    
    //-----------------------------seperate line---------------------------------------//
    
    
    //!< 显示money的label
    
    UILabel *moneyLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentLeft];
    
    moneyLabel.text = @"0.00RMB";
    
    moneyLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.view addSubview:moneyLabel];
    
    self.moneyLabel = moneyLabel;
    
    [moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(distabceImageView);
        
        make.left.equalTo(moneyImageView.mas_right).offset(6);
        
        make.right.equalTo(oilConsumptionImageView.mas_left);
        
        make.height.equalTo(13);
        
    }];
    
    
    
    //-----------------------------seperate line---------------------------------------//
    
    
    //!< 显示油耗的label
    
    UILabel *oilConsumptionLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentLeft];
    
    oilConsumptionLabel.text = @"0.0L";
    
    oilConsumptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self.view addSubview:oilConsumptionLabel];
    
    self.oilConsumptionLabel = oilConsumptionLabel;
    
    [oilConsumptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(distabceImageView);
        
        make.right.equalTo(backgroundIV).offset(-20);
        
        make.left.equalTo(oilConsumptionImageView.mas_right).offset(6);
        
        make.height.equalTo(13);
        
    }];
    
   
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加tableView
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.backgroundColor = [UIColor clearColor];;
    
    tableView.tableFooterView = [UIView new];
    
    tableView.showsVerticalScrollIndicator = NO;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self updateTrackData];
        
    }];

//    [tableView.mj_header beginRefreshing];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backgroundIV).offset(24);
        
        make.right.equalTo(backgroundIV).offset(-24);
        
        make.top.equalTo(distanceLabel.mas_bottom).offset(25);
        
        make.bottom.equalTo(backgroundIV);
        
    }];

    
    [tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:headerFooterIdentifier];
    
    
}


#pragma mark ---------- lazy

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

#pragma mark -------------- UITableViewDelegate && UItableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([self.sectionArray containsObject:@(section)])
    {
        return 1;
    }
    
    return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMTrackCell_baidu *cell = [XMTrackCell_baidu dequeueReuseableCellWith:tableView];
    
    cell.qicheid = _defaultCar.qicheid;
    
    cell.segmentData = self.dataSource[indexPath.section];
    
    //!< 设置点击事件的响应
    __weak typeof(self) wSelf = self;
    
     cell.clickEnlarge = ^(UIButton *btn,UIEvent *event){
    
         [wSelf pushViewControllerWithBtn:btn event:event];
         
    };
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerFooterIdentifier];
    
     headerView.contentView.backgroundColor = XMClearColor;
    
    UILabel *textLabel = [headerView.contentView viewWithTag:134];
    
    UIImageView *arrowIV = [headerView viewWithTag:133];
    
    UIImageView *backIV = [headerView viewWithTag:135];
    
    if (!backIV)
    {
        backIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"route_headerBackground"]];
        
        backIV.tag = 135;
        
        CGFloat width = self.tableView.bounds.size.width;
        
        CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
        
        backIV.frame = CGRectMake(0, 0, width, height);
        
         [headerView.contentView addSubview:backIV];
    }
    
    if (!textLabel)
    {
       
        
        textLabel = [UILabel new];
        
        textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        
        textLabel.textColor = [UIColor whiteColor];
        
        textLabel.frame = CGRectMake(18, 13, 200, 10);
        
        textLabel.tag = 134;
        
        [headerView.contentView addSubview:textLabel];
    }
    
    textLabel.text = [self headerTitleWithSection:section];
    
    if (!arrowIV)
    {
        CGFloat width = self.tableView.bounds.size.width;
        
        CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
        
        arrowIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_openTriangle"]];
        
        CGFloat arrowIV_W = 18;
        
        CGFloat arrowIV_H  = 18;
        
        arrowIV.frame = CGRectMake((width-arrowIV_W -15) , (height - arrowIV_H)/2, arrowIV_W, arrowIV_H);
        
        arrowIV.contentMode = UIViewContentModeScaleAspectFit;
        
        arrowIV.tag = 133;
        
        [headerView.contentView addSubview:arrowIV];
    }
    
    if ([self.sectionArray containsObject:@(section)])
    {
        
        arrowIV.transform = CGAffineTransformMakeRotation(M_PI_2);
        
    }else
    {
        arrowIV.transform = CGAffineTransformMakeRotation(0);
    }

    headerView.tag = section;
   
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerViewDidCick:)];
    
    [headerView addGestureRecognizer:tap];
    
    
    return headerView;
 
}





//!< 头部高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

//!< 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 234;

}


#pragma mark -------------- btn Click


//!< 点击查看分数按钮
- (void)scoerBtnDidClick:(UIButton *)sender
{
    XMTrackScoreViewController *score = [XMTrackScoreViewController new];
    
    score.hidesBottomBarWhenPushed = YES;
    
    score.userid = _defaultCar.userid;
    
    score.Qicheid = _defaultCar.qicheid;
    
    [self.navigationController pushViewController:score animated:YES];
    
   
    
}

//!< 点击左边箭头
- (void)leftArrowDidClick:(UIButton *)sender
{
    
    if (self.selectedDateStr == nil)
    {
        self.selectedDateStr = [self getCurrentDateWitgTimeType:XMTimeTypeFormatter timeStr:nil];
    }
    
    //!< 当前显示的天数日期
    NSString *title = [self.dayButton titleForState:UIControlStateNormal];
    
    //!< 当前显示的时间号码
    NSUInteger current = [title integerValue];

    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    
    df.dateFormat = @"yyyy-MM-dd";
    
    if(current > 1)
    {
        //!< 不是这个月的第一天，就--之后重新赋值，数显显示日期，树新表格
        
        current --;
        
        NSString *subStr = [self.selectedDateStr substringWithRange:NSMakeRange(0, 8)];
        
        self.selectedDateStr = [subStr stringByAppendingFormat:@"%02lu",(unsigned long)current];
    
    
    }else
    {
        
        //!< 现在是等于1的情况，必须判断上个月份的数据
        //!< 将时间字符转转换成时间对象
      
        
//       self.selectedDateStr = [self.selectedDateStr substringToIndex:7];
        
        //!< 现在显示的时间
        NSDate *date = [df dateFromString:self.selectedDateStr];
    
        //!< 上个月的时间对象
        NSDate *lastDate = [self getLastMonth:date];
        
        //!< 获取上个月时间月份有多少天
        NSUInteger dayCount = [self numberOfDaysInMonth:lastDate];
        
        int month = [self.selectedDateStr substringWithRange:NSMakeRange(5, 2)].intValue;
        int year = [self.selectedDateStr substringToIndex:4].intValue;
        
        
        if (month == 1)
        {
            month = 12;
            
            year--;
        }else
        {
            month--;
        }
        
        
        self.selectedDateStr = [NSString stringWithFormat:@"%d-%02d-%02lu",year,month,(unsigned long)dayCount];
        
//        XMLOG(@"%@",self.selectedDateStr);
        
    }
 
    
    //!< 设置标题
    self.timeLabel.text = [self getCurrentDateWitgTimeType:XMTimeTypeAll timeStr:self.selectedDateStr];
    
    [self.dayButton setTitle:[self getCurrentDateWitgTimeType:XMTimeTypeDay timeStr:self.selectedDateStr] forState:UIControlStateNormal];
    
    
    //!< 刷新数据
    
    [self.tableView.mj_header beginRefreshing];
    
//    [self updateTrackData];
    
    self.rightArrowBtn.enabled = YES;
    
    
}

//!< 点击右边箭头
- (void)rightArrowDidClick:(UIButton *)sender
{
    
    if (self.selectedDateStr == nil)
    {
        self.selectedDateStr = [self getCurrentDateWitgTimeType:XMTimeTypeFormatter timeStr:nil];
    }
    
    //!< 将时间字符转转换成时间对象
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    
    df.dateFormat = @"yyyy-MM-dd";
    
    //!< 现在显示的时间
    NSDate *date = [df dateFromString:self.selectedDateStr];
    
    //!< 获取当前显示的时间月份有多少天
    NSUInteger count = [self numberOfDaysInMonth:date];
    
    NSString *title = [self.dayButton titleForState:UIControlStateNormal];
    
    //!< 当前显示的时间号码
     NSUInteger current = [title integerValue];
    
    if (current < count)
    {
        //!< 当前时间小于当月天数的话，不需要转换月份，
        
        current ++;
        
        NSString *subStr = [self.selectedDateStr substringToIndex:8];
        
        self.selectedDateStr = [subStr stringByAppendingFormat:@"%02lu",(unsigned long)current];
        
        //!<
        
        
        
    }else
    {
        //!< 等于当前月份的天数，就需要修改月份了
        //!< 等于当前月份的天数，就需要修改月份了
        int year = [self.selectedDateStr substringToIndex:4].intValue;
        
        int month = [self.selectedDateStr substringWithRange:NSMakeRange(5, 2)].intValue;
        
        if (++month > 12) {
            month = 1;
            
            year ++;
            
        }
        
        self.selectedDateStr = [NSString stringWithFormat:@"%d-%02d-01",year,month];
    
    }
    
    
    //!< 设置标题
    self.timeLabel.text = [self getCurrentDateWitgTimeType:XMTimeTypeAll timeStr:self.selectedDateStr];
    
    [self.dayButton setTitle:[self getCurrentDateWitgTimeType:XMTimeTypeDay timeStr:self.selectedDateStr] forState:UIControlStateNormal];
    
    
    //!< 刷新数据
    
    [self.tableView.mj_header beginRefreshing];
    
//    [self updateTrackData];
    
    
     NSString *currentTimeStr = [df stringFromDate:[NSDate date]];
    
    
    if ([self.selectedDateStr isEqualToString:currentTimeStr])
    {
         sender.enabled = NO;
    }
    
   
  
    
    
}

//!< 点击显示当天日期的btn 跳转到日历界面

- (void)dayButtonDidClick:(UIButton *)sender
{
    //!< 点击当天时间，
    
    CalendarViewController *calendarVC = [CalendarViewController new];
    
    calendarVC.hidesBottomBarWhenPushed = YES;
    
    calendarVC.selelcedCompletion = ^(NSString *result)
    {
        
        
        [self changeTitleAndDayBtnWithString:result];
        
        [self getAverageDataWithTimeStr:result];
        
        [self getSegmentDataWithTimeStr:result];
        
        self.selectedDateStr = result;
        
        NSString *timeStr = [self getCurrentDateWitgTimeType:XMTimeTypeFormatter timeStr:nil];
        
        if([timeStr isEqualToString:result])
        {
            
            //!< 如果选择的是今天的时间，就设置右边按钮不可点击
            self.rightArrowBtn.enabled = NO;
            
            
        }else
        {
        
            //!< 否则设置右边按钮可以点击
            self.rightArrowBtn.enabled = YES;
            
        }
        
      
    };
    
    [self.navigationController pushViewController:calendarVC animated:YES];
    
    
}


//!< 点击头部视图
- (void)headerViewDidCick:(UITapGestureRecognizer *)tap
{
    
    [MobClick event:@"Click_TimeBar"];
    
    XMLOG(@"---------youmeng--点击轨迹的时间条---------");
    
    UITableViewHeaderFooterView *view = (UITableViewHeaderFooterView *)tap.view;
    
    NSInteger section = view.tag;
    
    UIImageView *triangleIV = [tap.view viewWithTag:133];
    
    if ([self.sectionArray containsObject:@(section)])
    {
        //!< 展开状态
        
        [self.sectionArray removeObject:@(section)];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            triangleIV.transform = CGAffineTransformIdentity;
            
        }];
        
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
        
        return;
    }
    
    [MBProgressHUD showMessage:nil toView:self.view];

    
      XMTrackSegmentStateModel *segmentData = self.dataSource[section];
    
//
    //!< 获取一段行程内的GPS数据
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_xc_gps_byxcid&qicheid=%@&Xingchengid=%@",_defaultCar.qicheid,segmentData.xingchengid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
       
        
        if (result.length > 10)
        {
            
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            NSDictionary *dic_first = arr.firstObject;
            
             NSDictionary *dic_last = arr.lastObject;
            
            if ([dic_first[@"locationx"] isKindOfClass:[NSNull class]] ||
                [dic_last[@"locationx"] isKindOfClass:[NSNull class]]  ||
                [dic_first[@"locationy"] isKindOfClass:[NSNull class]] ||
                [dic_last[@"locationy"] isKindOfClass:[NSNull class]]) {
                
                [MBProgressHUD showError:@"当前行程没有数据" toView:self.view];

                return ;
            }
            
            //!< 获取GPS数据成功
            
            
            if ([self.sectionArray containsObject:@(section)])
            {
                //!< 展开状态
                
                [self.sectionArray removeObject:@(section)];
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    triangleIV.transform = CGAffineTransformIdentity;
                    
                }];
                
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
                
                
            }else
            {
                //!< 闭合状态
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    triangleIV.transform =CGAffineTransformMakeRotation(M_PI_2) ;
                    
                }];
                
                [self.sectionArray addObject:@(section)];
                
                
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
                
            }

            
            
        }else
        {
            
            [MBProgressHUD showError:@"当前行程没有数据" toView:self.view];
                
            
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD showError:@"当前行程没有数据" toView:self.view];
        
    }];
//
    
    
    
}


#pragma mark -------------- 响应通知


/*!
 @brief 监听用户更换默认车辆 || 获取全部车辆信息成功的通知
 */
- (void)carInfodidChanged:(NSNotification *)noti
{
    
    NSString *changMode = noti.userInfo[@"mode"];//!< 默认车辆发生变化还是全部车辆
    
    id object = noti.userInfo[@"result"];//!< 改变的结果
    
    if([changMode isEqualToString:@"car"])
    {
        //!< 默认车辆变化
        self.defaultCar = object;
        
        if(_defaultCar.chepaino.length >2 && _defaultCar.tboxid.intValue > 2)
        {
             self.selectedDateStr = [self getCurrentDateWitgTimeType:XMTimeTypeFormatter timeStr:nil];
            //!< 只有在用户有车辆且已激活的情况下获取数据，没有激活和车辆的情况在刷新回调里进行处理
            //!< 请求当天全部行程的平均数据，
            [self getAverageDataWithTimeStr:nil];
        
            //!< 获取分段的行程数据
            [self getSegmentDataWithTimeStr:nil];
            
            
            //!< 默认车辆发生变化的时候就切换到当前时间
            [self changeTitleAndDayBtnWithString:nil];
        }
        
    }
    
}


#pragma mark -------------- 获取数据

//!< tableview刷新数据
- (void)updateTrackData
{
 
    [self getAverageDataWithTimeStr:self.selectedDateStr];
    
    [self getSegmentDataWithTimeStr:self.selectedDateStr];
    
    
    
}

//!< 获取当天平均数据
- (void)getAverageDataWithTimeStr:(NSString *)timeStr
{
    
    if (timeStr == nil)
    {
        //!< 如果没有传时间就默认当天时间
         timeStr = [self getCurrentDateWitgTimeType:XMTimeTypeFormatter timeStr:nil];
    }
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"getstatisticsbyday&qicheid=%@&Starttime=%@",_defaultCar.qicheid,timeStr];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([result isEqualToString:@"0"])
        {
            //!< 没有获取全部行程数据
             
        }else if ([result isEqualToString:@"-1"])
        {
            //!< 网络错误
            
            
         }else
        {
            //!< 获取行程数据成功
        
            NSArray *resultArr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            NSDictionary *resultDic = [NSDictionary nullDic:[resultArr firstObject]];
            
             [self setAverageDataWithDic:resultDic];
        
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
       if(self.viewLoaded  && self.view.window)
       {
            [MBProgressHUD showError:@"网络超时"];
       }
        
    }];


}

//!< 获取当天行程数据成功后设置数据
- (void)setAverageDataWithDic:(NSDictionary *)dic
{
    XMTrackAverageStateModel *model = [[XMTrackAverageStateModel alloc]initWithDictionary:dic];
    
    self.averageModel = model;
    
    if (self.viewLoaded)
    {
        self.distanceLabel.text = model.totallicheng;
        
        self.oilConsumptionLabel.text = model.totalpenyou;
        
        self.moneyLabel.text = model.totalMoney;
    }
    
    
    
}



//!< 获取当天分段数据
- (void)getSegmentDataWithTimeStr:(NSString *)timeStr
{
    
    if (timeStr == nil)
    {
        //!< 没有传时间，默认为当前时间
        timeStr = [self getCurrentDateWitgTimeType:XMTimeTypeFormatter timeStr:nil];
    }
    
    XMUser *user = [XMUser user];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_xc_bytime&Userid=%ld&qicheid=%@&Starttime=%@",user.userid,_defaultCar.qicheid,timeStr];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([result isEqualToString:@"0"])
        {
            
            //!< 没有分段数据
            if(self.isViewLoaded)
            {
                [MBProgressHUD showError:@"当天没有行程数据" toView:self.view];
                
                
                self.dataSource = nil;
                
                [self.tableView reloadData];
                
            
            }
            
            
            
        }else if([result isEqualToString:@"-1"])
        {
             //!< 网络错误
            if(self.viewLoaded && self.defaultCar.chepaino.length < 5)
            {
                [MBProgressHUD  showError:@"未添加车辆"];
                
            }else
            {
                [MBProgressHUD  showError:@"网络错误"];

            }
        
        }else
        {
        
            //!< 获取成功
            NSArray *resultArr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            //!< 设置数据
            [self setSegmentDataWithArray:resultArr];
        
        }
        
        [_tableView.mj_header endRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //!< 获取失败
        if(self.viewLoaded)
        {
            [MBProgressHUD  showError:@"网络超时" toView:self.view];
            
        }
         [_tableView.mj_header endRefreshing];
        
    }];
    
    
    
    
}


//!< 设置分段数据
- (void)setSegmentDataWithArray:(NSArray *)array
{
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dic in array)
    {
       NSDictionary * newDic = [NSDictionary nullDic:dic];
        
        XMTrackSegmentStateModel *model = [[XMTrackSegmentStateModel alloc]initWithDictionary:newDic];
        
        [arrM addObject:model];
        
    }
    
    
    
//    NSInteger oldCount = self.dataSource.count;
    
    self.dataSource = [arrM copy];
    
    //!< 每一个分区都不展开
//    if (self.tableView)
//    {
//        
//        [_sectionArray removeAllObjects];
// 
//        
//        NSInteger count = self.dataSource.count - oldCount;
//        
//        if (count > 0)
//        {
//            
//            for (int i = 0; i < count; i++)
//            {
//                [_sectionArray addObject:@(i)];
//            }
//            
//        }else if (count == 0)
//        {
//            [_sectionArray addObject:@(0)];
//        
//        }
//
        [self.sectionArray removeAllObjects]; //!< 关闭每个分区
    
        [self.tableView reloadData];
//
//     }


}


- (NSString *)headerTitleWithSection:(NSInteger)section
{

    XMTrackSegmentStateModel *model = self.dataSource[section];
    
    NSArray *startTimeArr = [model.starttime componentsSeparatedByString:@"T"];
    
    NSArray *endTimeArr = [model.endtime componentsSeparatedByString:@"T"];
    
    return [NSString stringWithFormat:@"%@ ~ %@",startTimeArr.lastObject,endTimeArr.lastObject];



}

#pragma mark -------------- statusBarStyle

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;

}


#pragma mark -------------- tool method

//!< 获取当前日期
- (NSString *)getCurrentDateWitgTimeType:(XMTimeType)type timeStr:(NSString *)timeStr
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *now;
    
//    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSDateComponents *comps;
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
//
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    
    df.dateFormat = @"yyyy-MM-dd";
    
    if (timeStr)
    {
        //!< 有传时间就用传来的时间
       
        
        now = [df dateFromString:timeStr];
        
        
        
        
    }else
    {
    
        //!< 没有传时间就默认为当前时间
        now=[NSDate date];
        
    }
    
    
    comps = [calendar components:unitFlags fromDate:now];
    
    NSInteger year = [comps year];
    
    NSInteger  week = [comps weekday];
    
    NSInteger  month = [comps month];
    
    NSInteger  day = [comps day];
    
    NSString *weekStr;
    
    switch (week)
    {
        case 1:
            
            weekStr = @"星期天";
            
            break;
        case 2:
            
            weekStr = @"星期一";
            

            break;
        case 3:
            
            weekStr = @"星期二";
            

            break;
        case 4:
            
            weekStr = @"星期三";
            break;
 
        case 5:
            
            weekStr = @"星期四";
 
            break;
        case 6:
            
            weekStr = @"星期五";
            

            break;
        case 7:
            
            weekStr = @"星期六";
            

            break;
        
            
        default:
            break;
    }
   
    
    if (type == XMTimeTypeDay)//!< dayBtn
    {
        
        return [NSString stringWithFormat:@"%ld",(long)day];
        
    }else if(type == XMTimeTypeAll)//!< 标题
    {
        return [NSString stringWithFormat:@"%ld年 %ld月 %ld日 %@",(long)year,(long)month,(long)day,weekStr];
    
    }else if(type == XMTimeTypeFormatter)//!< 请求数据做参数是用
    {
        
        return [df stringFromDate:now];
        
        
    }else
    {
        return nil;
    }
    
   
   
    
}


//!< 选择完成时间之后通过结果来改变标题和当前日期
- (void)changeTitleAndDayBtnWithString:(NSString *)result
{
    
    NSString *title = [self getCurrentDateWitgTimeType:XMTimeTypeAll timeStr:result];
    
    self.timeLabel.text = title;
    
    NSString *dayBtnTitle = [self getCurrentDateWitgTimeType:XMTimeTypeDay timeStr:result];
    
    [self.dayButton setTitle:dayBtnTitle forState:UIControlStateNormal];
    
    
    
}



//!< 创建label

- (UILabel *)labelWithFont:(float)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [UILabel new];
    
    label.backgroundColor = [UIColor clearColor];
    
    label.textAlignment = textAlignment;
    
     label.textColor = [UIColor whiteColor];
    
    label.font = [UIFont systemFontOfSize:font];

    return label;
}

#pragma mark -------------- date

- (NSUInteger)numberOfDaysInMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [greCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    
}
- (NSDate *)getLastMonth:(NSDate *)date{
    NSCalendar *greCalendar = [NSCalendar  currentCalendar];
//    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:date];
//    comps.month -= 1;
    return [greCalendar dateFromComponents:comps];
    
  
    
}

- (NSDate *)getNextMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:date];
    comps.month += 1;
    return [greCalendar dateFromComponents:comps];
}






//!< 点击cell的地图区域进行跳转
- (void)pushViewControllerWithBtn:(UIButton *)sender event:(UIEvent *)event
{
   
    //!< 通过点击的点获取在tab中的下标
    
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![sender pointInside:[touch locationInView:sender] withEvent:event])
    {
        return;
    }
    
    CGPoint point = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
   //!< 如果是哈尔滨账号就显示百度地图
        if (isCompany)
        {
            XMUser *user = [XMUser user];
    
            if (user.companyid == 362)
            {
                
                XMEnlargeMapViewController_BDViewController * vc = [XMEnlargeMapViewController_BDViewController new];
                
                vc.segmentData = self.dataSource[indexPath.section];
                
                vc.qicheid = self.defaultCar.qicheid;
                
                vc.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:vc animated:YES];

                return;
            }
            
            
        }
    
    //!< 如果不是就显示高德
    XMEnlargeMapViewController * vc = [XMEnlargeMapViewController new];
    
    vc.segmentData = self.dataSource[indexPath.section];
    
    vc.qicheid = self.defaultCar.qicheid;
    
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
    
}






@end
