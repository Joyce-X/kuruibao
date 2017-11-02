//
//  CalarViewController.m
//  TimeTest
//
//  Created by LvJianfeng on 16/7/21.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

#import "CalendarViewController.h"
#import "NSDate+Formatter.h"

#define LL_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define LL_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define Iphone6Scale(x) ((x) * LL_SCREEN_WIDTH / 375.0f)

#define HeaderViewHeight 30
#define WeekViewHeight 40

@interface CalendarViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *dayModelArray;

@property (strong, nonatomic) NSDate *tempDate;

@property (nonatomic,weak)UILabel* timeLabel;//!< 显示时间的Label


@end

@implementation CalendarViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupInit];
  
    [self getDataDayModel:self.tempDate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"日历选择页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"日历选择页面");
    
}


- (void)setupInit
{
    
    //!< 背景图
    
    UIImageView *backImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monitor_background"]];
    
    backImageView.frame = CGRectMake(0, 0, mainSize.width, mainSize.height);
    
    [self.view addSubview:backImageView];
    
    //-----------------------------seperate line---------------------------------------//
    
    
    //!< statusBar
    
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    statusBar.backgroundColor = XMTopColor;
    
    [self.view addSubview:statusBar];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 返回按钮
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
    
    [backBtn addTarget:self action:@selector(backBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    
     [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(35, 35));
        
        make.left.equalTo(backImageView).offset(18);
        
        make.top.equalTo(statusBar.mas_bottom).offset(18);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示当前月份的label
    self.tempDate = [NSDate date];
    
     UILabel *timeLabel = [UILabel new];
    
    timeLabel.textColor = [UIColor whiteColor];
    
    timeLabel.font = [UIFont systemFontOfSize:18];
    
    timeLabel.text = _tempDate.yyyyMMByLineWithDate;
    
    [self.view addSubview:timeLabel];
    
    self.timeLabel = timeLabel;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backImageView).offset(24);
        
        make.top.equalTo(backBtn.mas_bottom).offset(FITHEIGHT(88));
        
        make.height.equalTo(14);
        
        make.width.equalTo(200);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 切换月份的按键  ++++++++
    UIButton *rightArrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightArrowBtn setImage:[UIImage imageNamed:@"track_calendar_rightArrow"] forState:UIControlStateNormal];
    
    [rightArrowBtn addTarget:self action:@selector(rightArrowBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    rightArrowBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    
    [self.view addSubview:rightArrowBtn];
    
    [rightArrowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(backImageView).offset(-15);
        
        make.height.equalTo(30);
        
        make.width.equalTo(30);
        
        make.centerY.equalTo(timeLabel);
        
        
    }];
    
    //!< 切换月份的按键 --------
    UIButton *leftArrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftArrowBtn setImage:[UIImage imageNamed:@"track_calendar_leftArrow"] forState:UIControlStateNormal];
    
    [leftArrowBtn addTarget:self action:@selector(leftArrowBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    leftArrowBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    
    [self.view addSubview:leftArrowBtn];
    
    [leftArrowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(rightArrowBtn.mas_left).offset(-15);
        
        make.height.equalTo(30);
        
        make.width.equalTo(30);
        
        make.centerY.equalTo(timeLabel);
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加collectionView
    
    NSInteger width = (mainSize.width - 50) / 7;
    
    NSInteger height = width;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    
    flowLayout.itemSize = CGSizeMake(width, height);
    
    flowLayout.headerReferenceSize = CGSizeMake(width * 7, 15);
    
    flowLayout.sectionInset = UIEdgeInsetsMake(40, 0, 0, 0);
    
     flowLayout.minimumInteritemSpacing = 0;
    
    flowLayout.minimumLineSpacing = 10;
    
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    
    collectionView.delegate = self;
    
    collectionView.dataSource = self;
    
    collectionView.backgroundColor = [UIColor clearColor];
    
    [collectionView registerClass:[CalendarCell class] forCellWithReuseIdentifier:@"CalendarCell"];
    
    [collectionView registerClass:[CalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CalendarHeaderView"];
    
    [self.view addSubview:collectionView];
    
    self.collectionView = collectionView;
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backImageView).offset(25);
        
        make.right.equalTo(backImageView).offset(-25);
        
        make.top.equalTo(timeLabel.mas_bottom).offset(40);
        
        make.bottom.equalTo(backImageView);
        
    }];

}

#pragma mark -------------- system

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
    
}

#pragma mark -------------- 按钮点击事件

//!< 点击返回按钮
- (void)backBtnDidClick:(UIButton *)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    
    
}

//!< 点击月份 + 按钮
- (void)rightArrowBtnClick:(UIButton *)sender
{
    
    self.tempDate = [self getNextMonth:self.tempDate];
    
    self.timeLabel.text = self.tempDate.yyyyMMByLineWithDate;
    
    [self getDataDayModel:self.tempDate];
    
}

//!< 点击月份 - 按钮
- (void)leftArrowBtnClick:(UIButton *)sender
{
    
    self.tempDate = [self getLastMonth:self.tempDate];
    
    self.timeLabel.text = self.tempDate.yyyyMMByLineWithDate;
    
    [self getDataDayModel:self.tempDate];
    
}

- (void)getDataDayModel:(NSDate *)date{
    NSUInteger days = [self numberOfDaysInMonth:date];
    NSInteger week = [self startDayOfWeek:date];
    self.dayModelArray = [[NSMutableArray alloc] initWithCapacity:42];
    int day = 1;
    for (int i= 1; i<days+week; i++) {
        if (i<week) {
            [self.dayModelArray addObject:@""];
        }else{
            MonthModel *mon = [MonthModel new];
            mon.dayValue = day;
            NSDate *dayDate = [self dateOfDay:day];
            mon.dateValue = dayDate;
            if ([dayDate.yyyyMMddByLineWithDate isEqualToString:[NSDate date].yyyyMMddByLineWithDate]) {
                mon.isSelectedDay = YES;
            }
            [self.dayModelArray addObject:mon];
            day++;
        }
    }
    [self.collectionView reloadData];
}

 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dayModelArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCell" forIndexPath:indexPath];
   
     id mon = self.dayModelArray[indexPath.row];
    if ([mon isKindOfClass:[MonthModel class]]) {
        cell.monthModel = (MonthModel *)mon;
    }else{
        cell.dayLabel.text = @"";
    
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    CalendarHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CalendarHeaderView" forIndexPath:indexPath];
    
    
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    id mon = self.dayModelArray[indexPath.row];
    if ([mon isKindOfClass:[MonthModel class]]) {
       NSString *resultStr = [(MonthModel *)mon dateValue].yyyyMMddByLineWithDate;
        
        NSDate *date = [NSDate date];
        
        MonthModel *model = (MonthModel *)mon;
        
        if (NSOrderedDescending == [model.dateValue compare:date])
        {
            
            [MBProgressHUD showError:@"当前日期不可选"];
            
            return;
            
        }
         
        [self.navigationController popViewControllerAnimated:YES];
        
        if (self.selelcedCompletion)
        {
            self.selelcedCompletion(resultStr);

        }
        
        
        
    }
}



#pragma mark -Private
- (NSUInteger)numberOfDaysInMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [greCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;

}

- (NSDate *)firstDateOfMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:date];
    comps.day = 1;
    return [greCalendar dateFromComponents:comps];
}

- (NSUInteger)startDayOfWeek:(NSDate *)date
{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];//Asia/Shanghai
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:[self firstDateOfMonth:date]];
    return comps.weekday;
}

- (NSDate *)getLastMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:date];
    comps.month -= 1;
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

- (NSDate *)dateOfDay:(NSInteger)day{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:self.tempDate];
    comps.day = day;
    return [greCalendar dateFromComponents:comps];
}

@end

@implementation CalendarHeaderView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        NSArray *weekArray = [[NSArray alloc] initWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六", nil];
        
        for (int i=0; i<weekArray.count; i++) {
            UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*(mainSize.width - 50)/7, 0, (mainSize.width - 50)/7, 15)];
            weekLabel.textAlignment = NSTextAlignmentCenter;
            weekLabel.textColor = [UIColor whiteColor];
            weekLabel.font = [UIFont systemFontOfSize:11];
            weekLabel.text = weekArray[i];
            [self addSubview:weekLabel];
        }
        
    }
    return self;
}
@end


@implementation CalendarCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CGFloat width = self.contentView.frame.size.width*0.6;
        CGFloat height = self.contentView.frame.size.height*0.6;
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake( self.contentView.frame.size.width*0.5-width*0.5,  self.contentView.frame.size.height*0.5-height*0.5, width, height )];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.font = [UIFont systemFontOfSize:14];
        dayLabel.layer.masksToBounds = YES;
        dayLabel.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:dayLabel];
        
         self.dayLabel = dayLabel;
        
    }
    return self;
}

- (void)setMonthModel:(MonthModel *)monthModel{
    _monthModel = monthModel;
    self.dayLabel.text = [NSString stringWithFormat:@"%02ld",(long)monthModel.dayValue];
    if (monthModel.isSelectedDay) {
        self.dayLabel.layer.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1].CGColor;
        self.dayLabel.layer.borderColor = XMColorFromRGB(0x7F70E9).CGColor;
        self.dayLabel.layer.borderWidth = 2;
    }else
    {
        self.dayLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
       self.dayLabel.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    NSDate *date = [NSDate date];
    
    if (NSOrderedDescending == [monthModel.dateValue compare:date])
    {
        self.dayLabel.textColor = XMGrayColor;
    }else
    {
        self.dayLabel.textColor = [UIColor whiteColor];
    }
    
   
 
    
    
    
    
}



@end


@implementation MonthModel

@end
