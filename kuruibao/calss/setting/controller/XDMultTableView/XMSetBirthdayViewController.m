//
//  XMSetBirthdayViewController.m
//  kuruibao
//
//  Created by x on 16/9/7.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 设置生日的控制器
 
 
 ************************************************************************************************/
#import "XMSetBirthdayViewController.h"

@interface XMSetBirthdayViewController ()

@property (nonatomic,weak)UIDatePicker* datePicker;//->>时间选择器

@property (nonatomic,assign)BOOL isChange;//!< 是否有改变
@end

@implementation XMSetBirthdayViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"设置生日页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"设置生日页面");
    
}

- (void)setupSubViews
{
    
    self.message = @"设置生日";
    
    //->>添加datepicker
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    //datePicker.center = self.view.center;
//    datePicker.backgroundColor  = [UIColor brownColor];
    [datePicker addTarget:self action:@selector(datePickerValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:0];//->>设置最大时间
    NSDateFormatter *df =[[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy-MM-dd";
    datePicker.minimumDate = [df dateFromString:@"1900-01-01"];//->>设置最小时间
    [self.view addSubview:datePicker];
    
    self.datePicker = datePicker;
    
    __weak typeof(self) wSelf = self;
    
    [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(wSelf.view);
        make.right.equalTo(wSelf.view);
        make.height.equalTo(216);
        make.top.equalTo(wSelf.view).offset(backImageH);
        
        
    }];
    
    
    
    
    
    
}

- (void)backToLast
{
    if (_isChange)
    {
        NSDateFormatter *df =[[NSDateFormatter alloc]init];
        df.dateFormat = @"yyyyMMdd";
        NSString *dateString = [df stringFromDate:_datePicker.date];
        NSString *birthday = [NSString stringWithFormat:@"%@ 年 %@ 月 %@ 日",[dateString substringToIndex:4],[dateString substringWithRange:NSMakeRange(4, 2)],[dateString substringFromIndex:6]];
        
        [[NSUserDefaults standardUserDefaults] setObject:birthday forKey:@"userInfo_birthday"];
        self.completion(birthday);
    }
   
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)datePickerValueDidChange:(UIDatePicker *)dp
{
    
    _isChange = YES;
    
}


@end
