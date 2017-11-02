//
//  TestViewController.m
//  kuruibao
//
//  Created by x on 16/11/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:设置用户常用信息
 
 **********************************************************/

#import "XMSetCommonAddressViewController.h"
#import "XMSearchBar.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "XMChooseCommonADViewController.h"
#import "XMMapSearchResultViewController.h"





@interface XMSetCommonAddressViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate>

@property (nonatomic,weak)UITextField* searchTF;//!< 搜索框

@property (strong, nonatomic) NSArray *historys;//!< 历史数据

@property (strong, nonatomic) AMapSearchAPI *searchAPI;

@property (copy, nonatomic) NSString *searchKeyword;

@end

@implementation XMSetCommonAddressViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
    
}


- (void)setupInit
{
    
    //!< 顶部导航部分
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 64)];
    
    topView.backgroundColor = XMWhiteColor;
    
    [self.view addSubview:topView];
    
   
    //-----------------------------seperate line---------------------------------------//
    //!< 返回按钮
    
    //!< back button
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"Map_searchBack"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    backBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 10);
    
    [topView addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(topView);
        
        make.width.equalTo(46);
        
        make.height.equalTo(40);
        
        make.bottom.equalTo(topView).offset(-6);
        
    }];
    
    
    //!< search Bar
    XMSearchBar *searchBar = [XMSearchBar searchBar];
    
    searchBar.placeholder = @"搜索地点";
    
    searchBar.tag = 406;
    
    searchBar.delegate = self;
    
    searchBar.returnKeyType = UIReturnKeySearch;
    
   
    
    [topView addSubview:searchBar];
    
    self.searchTF = searchBar;
    
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(backBtn);
        
        make.left.equalTo(backBtn.mas_right);
        
        make.right.equalTo(topView).offset(-10);
        
        make.height.equalTo(35);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [searchBtn setBackgroundColor:XMBlueColor];
    
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    searchBtn.tag = 407;
    
    searchBtn.layer.cornerRadius = 5;
    
    
    
    [searchBtn addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchDown];
    
    searchBtn.hidden = YES;
    
    [topView addSubview:searchBtn];
    
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(searchBar);
        
        make.left.equalTo(topView.mas_right);
        
        make.size.equalTo(CGSizeMake(50, 30));
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
 
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, mainSize.width, mainSize.height - 64) style:UITableViewStylePlain];
    
    tableView.dataSource = self;
    
    tableView.delegate = self;
    
    tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:tableView];
    
    //!<监听内容变化的通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextLengthDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    
    
    
}

#pragma mark --- lazy

- (NSArray *)historys
{

    if (!_historys)
    {
        _historys = [NSArray arrayWithContentsOfFile:XMSearchHistoryPath];
    }

    return _historys;
}

- (AMapSearchAPI *)searchAPI
{
    if (!_searchAPI)
    {
        _searchAPI = [[AMapSearchAPI alloc]init];
        
        _searchAPI.delegate = self;
    }

    return _searchAPI;
}


#pragma mark --- UITableViewDelegate  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.historys.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"commonCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.textLabel.textColor = XMGrayColor;
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];

        
    }

    cell.imageView.image = [UIImage imageNamed:@"ellipse-3"];
    
    cell.textLabel.text = self.historys[indexPath.row];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *text = self.historys[indexPath.row];
    
    [self executeSerachActionWithText:text];
    


}

#pragma mark --------- AMapSearchDelegate
/**
 *  当请求发生错误时，会调用代理的此方法.
 *
 *  @param request 发生错误的请求.
 *  @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{

    [MBProgressHUD hideHUD];
    
    [MBProgressHUD showError:@"网络超时"];

}

/**
 *  POI查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 *  @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{

    [MBProgressHUD hideHUD];
    
    if (response.count > 0)
    {
        //!< 搜索成功，跳转到显示大头针界面
        XMChooseCommonADViewController *chooseCommonVC = [[XMChooseCommonADViewController alloc]init];
        
        chooseCommonVC.pois = response.pois;
        
        chooseCommonVC.index = self.index;
        
        [self.navigationController pushViewController:chooseCommonVC animated:YES];
        
    }else
    {
        //!< 没有搜索到结果
        XMMapSearchResultViewController *vc = [XMMapSearchResultViewController new];
        
        [self.navigationController pushViewController:vc animated:YES];

    
    }
    
  
    


}


#pragma mark --- UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //!< 点击return按键
    if(textField.text.length == 0)return YES;
    
    [self executeSerachActionWithText:textField.text];

    return YES;
}


#pragma mark --- 按钮的点击事件

//!< 返回按钮的点击
- (void)backBtnDidClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

//!< 顶部搜索栏 搜索按钮的点击
- (void)searchBtnClick:(UIButton *)seder
{
    NSString *text = self.searchTF.text;
    
    if (text.length == 0)return;
    
    [self executeSerachActionWithText:text];
    
    
}

#pragma mark --- 搜索方法

//!<执行搜索操作用给定的文字
- (void)executeSerachActionWithText:(NSString *)text
{
    if(text.length == 0)return;
    
    [MBProgressHUD showMessage:@"正在搜索"];
    
    [self.view endEditing:YES];
 
     self.searchKeyword = text;
    
    //-- 用户输入文字， 构造搜索对象，设置请求参数开始进行搜索
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc]init];
    
    //-- 设置城市的时候应该根据用户当前的位置来设置，反地理编码来获取
    
    if(_currentCity)
    {
        request.city = _currentCity;
        //   request.cityLimit = YES; 不进行城市限制
        
    }
    
    request.keywords = text;
    
    request.offset = 10; //默认20
    
    request.page = 1;//!< 第一页
    
    //-- 开始进行搜索
    [self.searchAPI AMapPOIKeywordsSearch:request];
    
 }


#pragma mark --- 搜索成功 执行结果

- (void)executeSearchResultWithArray:(NSArray *)pois
{
    
    /**
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:pois.count];
    
    for (AMapPOI * poi in pois)
    {
        
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc]init];
        
        annotation.title = poi.name;
        
        annotation.subtitle = poi.address;
        
        annotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        
        [annotations addObject:annotation];
        
    }
    
    self.annotations = annotations;
    
    [_mapView addAnnotations:annotations];
    
    [_mapView showAnnotations:annotations animated:YES];
    
       */
    
}

#pragma mark --- 通知响应事件

//!< 文字长度发生变化
- (void)textFieldTextLengthDidChange:(NSNotification *)noti
{
    
    //!< 从没有值变为有值 缩小宽度，创建按钮平移近来，没有值就移除按钮，加宽输入框
    UITextField *textField = (UITextField *)noti.object;
    
    if (textField.tag != 406) return;
    
    static BOOL shouldReduce = YES;
    
    if (shouldReduce)
    {
        CGRect frame = textField.frame;
        
        frame.size.width -= 50;
        
        shouldReduce = NO;
        
        UIButton *searchBtn = [textField.superview viewWithTag:407];
        
        searchBtn.hidden = NO;
        
        [UIView animateWithDuration:0.1 animations:^{
            
            textField.frame = frame;
            
            searchBtn.transform = CGAffineTransformMakeTranslation(-55, 0);
            
        }];
    }
    
    if (textField.text.length == 0)
    {
        CGRect frame = textField.frame;
        
        frame.size.width += 50;
        
        UIButton *searchBtn = [textField.superview viewWithTag:407];
        
        
        
        [UIView animateWithDuration:0.2 animations:^{
            
            textField.frame = frame;
            
            searchBtn.transform = CGAffineTransformMakeTranslation(55, 0);
            
        }];
        
        shouldReduce = YES;
        
        searchBtn.hidden = YES;
        
        
    }
    



}


@end
