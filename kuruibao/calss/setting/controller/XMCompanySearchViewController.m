//
//  XMCompanySearchViewController.m
//  kuruibao
//
//  Created by x on 17/5/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 
 企业账户下，车辆列表界面的搜索按钮，对应的搜索界面
 
 ************************************************************************************************/
#import "XMCompanySearchViewController.h"

#import "XMCompanySearchCell.h"

#import "XMSearchBar.h"

#import "XMCar.h"

#import "XMCompany_alertView.h"

@interface XMCompanySearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

/**
 历史数据
 */
@property (strong, nonatomic) NSMutableArray *historyList;

/**
 表格
 */
@property (weak, nonatomic) UITableView *tableView;

/**
 显示头部文字
 */
@property (weak, nonatomic) UILabel *headerLabel;

/**
 文本框
 */
@property (weak, nonatomic) UITextField *textField;

/**
 搜索结果
 */
@property (strong, nonatomic) NSMutableArray *searchList;

/**
 搜索到的汽车模型
 */
@property (strong, nonatomic) NSMutableArray *searchCars;

/**
 历史记录数组路径
 */
@property (copy, nonatomic) NSString *historyPath;

@end

@implementation XMCompanySearchViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupSubviews];
    
 
 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"车辆搜索页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"车辆搜索页面");
    
}


- (void)setupSubviews
{

    
    
    XMUser *user = [XMUser user];
    
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    //!< 历史数据存放路径
    self.historyPath = [docPath stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"/historyData/%@.plist",user.mobil]];
    
    //!< 判断文件夹是否存在
    NSString *directoryPath = [docPath stringByAppendingString:@"/historyData"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
    {
        //!< 文件夹不存在，
        XMLOG(@"---------文件夹不存在，创建文件夹---------");
      BOOL res =  [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
     
        if (res)
        {
            XMLOG(@"---------创建文件加成功---------");
        }else
        {
        
            XMLOG(@"---------创建文件夹失败---------");
        
        }
        
    }
    
    
    
    //!< 判断文件是否存在
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:self.historyPath];
    
    BOOL result;
    
    if (exist)
    {
        XMLOG(@"---------文件存在，解析数据---------");
        //!< 文件存在，取出历史数据
        
    }else
    {
        
        XMLOG(@"---------文件不存在准备创建---------");
        //!< 文件不存在，创建历文件
       result =  [[NSFileManager defaultManager] createFileAtPath:_historyPath contents:nil attributes:nil];
    
        if (result)
        {
            XMLOG(@"---------创建成功---------");
        }else
        {
            
            XMLOG(@"---------创建失败---------");
        
        }
    }
    
    NSData *data = [NSData dataWithContentsOfFile:_historyPath];
    
    self.historyList = [NSMutableArray arrayWithContentsOfFile:_historyPath];
    
    [self.dataSource addObjectsFromArray:self.historyList];
    
    //->>背景
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *backIV = [UIImageView new];
    
    backIV.image = [UIImage imageNamed:@"carLife_breakRule_background"];
    
    backIV.frame = self.view.bounds;
    
    [self.view addSubview:backIV];
    
    //!< 添加输入框
    UITextField *textField = [XMSearchBar searchBar];
    
    textField.placeholder = @"输入车牌号进行查询";
 
    textField.layer.cornerRadius = 15;
    
    textField.clipsToBounds = YES;
   
    
    textField.backgroundColor = XMColorFromRGB(0x36353d);
    
    textField.textColor = XMWhiteColor;
    
    textField.font = [UIFont systemFontOfSize:14];
   
    textField.returnKeyType = UIReturnKeySearch;
    
    textField.delegate = self;
    
    [self.view addSubview:textField];
    
    self.textField = textField;
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.view).offset(26);
        
        make.left.equalTo(self.view).offset(16);
        
        make.size.equalTo(CGSizeMake(FITWIDTH(302), 31));
        
    }];
    
    
    //!< 添加取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    
    [cancelBtn setTitleColor:XMWhiteColor forState:UIControlStateNormal];
    
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    
    [self.view addSubview:cancelBtn];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(textField.mas_centerY);
        
        make.right.equalTo(self.view).offset(-16);
        
        make.size.equalTo(CGSizeMake(40, 20));
        
    }];
    
    //!< 建表
    UITableView *tableView = [UITableView new];
    
    tableView.backgroundColor = XMClearColor;
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.bottom.right.equalTo(self.view);
        
        make.top.equalTo(textField.mas_bottom).offset(25);
        
        
    }];
    
    //!< 创建表头
    
    UIView *headerView = [UIView new];
    
    UILabel *headerLabel = [UILabel new];
    
    headerLabel.backgroundColor = XMClearColor;
    
    headerLabel.textColor = XMWhiteColor;
    
    headerLabel.text = @"历史搜索";
    
    headerLabel.font = [UIFont systemFontOfSize:18];
    
    headerLabel.frame = CGRectMake(12, 0, mainSize.width, 30);
    
   
    
    UIImageView *imageIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_line"]];
    
    imageIV.frame = CGRectMake(-12, 29, mainSize.width, 1);
    
    [headerLabel addSubview:imageIV];
    
    [headerView addSubview:headerLabel];
    
    self.headerLabel = headerLabel;
    
    headerView.frame = CGRectMake(0, 0, 0, 30);
    
    tableView.tableHeaderView = headerView;
    
    
    
    //!< 创建表尾
    UIView *footerView = [UIView new];
    
    footerView.frame = CGRectMake(0, 0, 0, 75);
    
    tableView.tableFooterView = footerView;
    //!< 边框
    UIView *borderView = [UIView new];
    
    borderView.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor;
    
    borderView.layer.borderWidth = 1;
    
    borderView.layer.cornerRadius = 2.5;
    
    borderView.clipsToBounds = YES;
    
    [footerView addSubview:borderView];
    
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(footerView.mas_centerX);
        
        make.centerY.equalTo(footerView);
        
        make.size.equalTo(CGSizeMake(FITWIDTH(265), 42));
        
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTrigger:)];
    
    [borderView addGestureRecognizer:tap];
    
    //!< 添加图标
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"company_clear"]];
    
    [borderView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(borderView.mas_centerY);
        
        make.left.equalTo(borderView).offset(FITWIDTH(72));
        
        make.size.equalTo(CGSizeMake(19, 18));
        
    }];
    
    //!< 添加文字
    UILabel *label = [UILabel new];
    
    label.textColor = XMWhiteColor;
    
    label.font = [UIFont systemFontOfSize:18];
    
    label.text = @"清空历史搜索";
    
    [borderView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(130, 18));
        
        make.centerY.equalTo(borderView.mas_centerY);
        
        make.left.equalTo(imageView.mas_right).offset(7);
        
    }];
    
    
    //!< 是否显示尾部
    if (self.historyList.count == 0)
    {
        footerView.hidden = YES;
        
        [self.dataSource addObject:@"无历史数据"];
    }
    
    //!< 监听文字变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textLengthDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    //!< 监听键盘落下
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    self.searchList = [NSMutableArray array];
    
    self.searchCars = [NSMutableArray array];
 
}


#pragma mark ------- lazy
- (NSMutableArray *)historyList
{
    if (!_historyList)
    {
        _historyList = [NSMutableArray array];
    }

    return _historyList;


}

#pragma mark ------- UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dataSource.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMCompanySearchCell *cell = [XMCompanySearchCell dequeueReusableCellWithTableView:tableView];
    
    
    if (self.textField.text.length == 0 || self.textField.text.length == NSNotFound)
    {
        cell.textLabel.text = self.dataSource[indexPath.row];
        
        return cell;
    }
    
    NSString *text = self.dataSource[indexPath.row];

    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRange range = [text rangeOfString:self.textField.text];
    
    [str addAttribute:NSForegroundColorAttributeName value:XMGreenColor range:range];
    
    
    
    cell.textLabel.attributedText = str;

    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //!< 判断选中的是否为“无”“无历史数据”
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *title = cell.textLabel.text;
    
    if ([title isEqualToString:@"无"] || [title isEqualToString:@"无历史数据"]) {
        return;
    }
    
    //-- 判断是否正在检测
    //!< 如果正在检测车辆
    if([XMCheckManager shareManager].isChecking)
    {
        
        [MBProgressHUD showError:@"正在检测车辆,暂时不可切换"];
        
        return;
        
    }


    if (self.textField.text.length > 0)
    {
        //!< 存储数据，根据当前账户，，判断车辆是否存在。
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMShowCarVCCellClickNotification object:nil userInfo:@{@"carModel" : self.searchCars[indexPath.row]}];
        
        //!< 保存记录
        [self saveRecord:[self.searchCars[indexPath.row] chepaino]];
        
        
    }else
    {
        
        NSString *number = self.historyList[indexPath.row];
        
        
        
        XMCar *desCar;
        
        for (XMCar *car in self.allCars) {
            
            if ([number isEqualToString:car.chepaino])
            {
                desCar = car;
                
                break;
            }
            
        }
        
        if (desCar == nil)
        {
            [MBProgressHUD showError:@"该车两可能已被删除" toView:self.view];
            
            return;
        }
    
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMShowCarVCCellClickNotification object:nil userInfo:@{@"carModel" : desCar}];
        
        //!< 保存记录
        [self saveRecord:desCar.chepaino];
       
    
    }
   

}

#pragma mark ------- UITextFieldDelegate
/**
 点击return

 @param cancelBtnClick
 @return
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];
    
//    [self.tableView reloadData];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (textField.text.length > 0)
    {
        return;
    }
    //!< 准备开始编辑，隐藏头尾，隐藏历史数据
    self.tableView.tableFooterView.hidden = YES;
    
    self.headerLabel.text = @"搜索结果";

    [self.dataSource removeAllObjects];
    
    [self.tableView reloadData];


}
#pragma mark ------- btn click

/**
 点击取消按钮返回
 */
- (void)cancelBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

/**
 点击清空历史数据

 @param tap tap
 */
- (void)tapTrigger:(UITapGestureRecognizer *)tap
{
    
    XMCompany_alertView *alert = [XMCompany_alertView alertView];
    
    [self.view addSubview:alert];
    
    alert.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    alert.alpha = 0;
    
    [UIView animateWithDuration:0.1 animations:^{
        
        alert.transform = CGAffineTransformIdentity;
        
        alert.alpha = 1;
        
    }];
    
    alert.clearBlock = ^{
    
        [self clearHistoryRecord];
        
    };
    
}

/**
 清楚历史记录
 */
- (void)clearHistoryRecord
{
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObject:@"无"];
    
    [self.tableView reloadData];
    
    self.tableView.tableFooterView.hidden = YES;
    
    //!< 删除记录 不能删除文件，后边可能还会存储，删除文件会导致存储失败
    [self.historyList removeAllObjects];
    
    [self.historyList writeToFile:_historyPath atomically:YES];
    
}


#pragma mark ------- 响应通知
/**
 textField 文字改变

 @param noti
 */
- (void)textLengthDidChange:(NSNotification *)noti
{
    
    [self.searchCars removeAllObjects];//!< 清空存放汽车模型数组
    
    NSString *destinationStr = self.textField.text;
    
    if (destinationStr.length == 0)
    {
        
        //!< 当输入文字长度变为0的时候，显示历史记录
        [self.dataSource removeAllObjects];
        
        [self.dataSource addObjectsFromArray:self.historyList];
        
        self.headerLabel.text = @"历史记录";
        
        
        [self.tableView reloadData];
        
        return;
        
    }
    
    self.headerLabel.text = @"搜索结果";

    
     //!< 文字改变的时候，遍历所有车辆
    for (XMCar *car in self.allCars)
    {
        if ([car.chepaino containsString:destinationStr]){
            
            //!< 包含搜索关键字就tianjia
            [self.searchList addObject:car.chepaino];
            
            [self.searchCars addObject:car];
            
        }
        
    }
    
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObjectsFromArray:self.searchList];
    
    [self.searchList removeAllObjects];
    
    [self.tableView reloadData];
    
}

/**
 键盘落下
 */
- (void)keyboardWillHide
{
    if (self.textField.text.length > 0)
    {
        self.headerLabel.text = @"搜索结果";
        
        return;
    }else
    {
    
        self.headerLabel.text = @"历史记录";
        
        [self.dataSource removeAllObjects];
        
        [self.dataSource addObjectsFromArray:self.historyList];
        
        [self.tableView reloadData];
    
    }
    
}

#pragma mark ------- tool method
/**
 保存记录

 @param record
 */
- (void)saveRecord:(NSString *)record
{
    if([self.historyList containsObject:record])
    {
        
        return;
    }else
    {
    
        [self.historyList addObject:record];
        
        [self.historyList writeToFile:_historyPath atomically:YES];
        
    
    }
    
    
    
}


#pragma mark ------- system
-(void)dealloc
{
    
    XMLOG(@"---------搜索界面已经销毁---------");
    [[NSNotificationCenter defaultCenter ] removeObserver:self];

}

@end
