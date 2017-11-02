//
//  XMSettingViewController.m
//  kuruibao
//
//  Created by x on 16/8/1.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 最主要的设置界面，展示与设置相关的所有内容
 
 
 ************************************************************************************************/

#import "XMSettingViewController.h"
#import "XMSettingCell.h"
#import "UIImage+JW.h"
#import "XMSettingHeaderView.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "XMUser.h"


//-- 点击cell发送通知的名称
#define kXMSettingCellDidClickNotification @"kXMSettingCellDidClickNotification"

//!< post when the nick name did changed
#define kXMNickNameChangeNotification @"kXMNickNameChangeNotification"

@interface XMSettingViewController()<UITableViewDelegate,UITableViewDataSource,XMSettingHeaderViewDelegate>




@property (nonatomic,strong)NSArray* dataSource;//!< datasSource

@property (strong, nonatomic) AFHTTPSessionManager *session;//!< session

@property (nonatomic,weak)XMSettingHeaderView* headerView;// description header part

@property (weak, nonatomic) UIView *bottomView;//!< 底部logo

@end
@implementation XMSettingViewController



- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        //!< 监听昵称变化的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nickNameChange:) name:kXMNickNameChangeNotification object:nil];
        
    }
    
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //!< 在初始化的时候获取用户信息
    
    if (!isCompany) {
        
         [self getUserInfo];
        
    }
   
    
    
    
    //-- 设置初始化信息
    [self setupInit];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"设置主页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"设置主页面");
    
}

#pragma mark --- lazy

- (AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
    }
    
    return _session;
    
    
}


/**
 *  设置初始化信息
 */
- (void)setupInit
{
    
    
    //-- 背景色
    self.view.backgroundColor = XMColorFromRGB(0xF8F8F8);
    
    //-- 创建tableView
    UITableView *tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, mainSize.width, mainSize.height - 20) style:UITableViewStylePlain];
    tab.backgroundColor = [UIColor clearColor];
    tab.separatorColor = [UIColor clearColor];
    tab.dataSource = self;
    tab.delegate = self;
    
    //-- 表头视图
    XMSettingHeaderView *headerView  =  [[NSBundle mainBundle]loadNibNamed:@"XMSettingHeaderView" owner:nil options:nil][0];
    
    headerView.frame = CGRectMake(0, 0, mainSize.width, 200);
    
    headerView.headerImage = isCompany ? [UIImage imageNamed:@"icon_setting"] : [UIImage imageNamed:@"center_userIcon"];
    
    XMUser *user = [XMUser user];
    
    headerView.nickName =  isCompany ? user.mobil : @"昵称";
    
    headerView.delegate = self;
    
    tab.tableHeaderView = headerView;
    
    
    [self.view addSubview:tab];
    
    self.headerView = headerView;
    
    self.tableView = tab;
    
    
    UIView *backView = [UIView new];
    
//    self.tableView.tableFooterView = backView;
    
    [self.view addSubview:backView];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view);
        
        make.bottom.equalTo(self.view);
        
        make.right.equalTo(self.view).offset(-65);
        
        make.height.equalTo(60);
        
    }];
    
    
    UIImageView *logoIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cesiumaiB"]];
    
    [backView addSubview:logoIV];
    
    [logoIV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(backView).offset(-15);
        
        make.centerX.equalTo(backView);
        
        make.height.equalTo(40);
        
        make.width.equalTo(80);
        
    }];
    
    self.bottomView = backView;
    
    
}



#pragma mark -- lazy

- (NSArray *)dataSource
{
    if (!_dataSource)
    {
        XMSettingCellModel *model_01 = [XMSettingCellModel new];
        
        if (isCompany)
        {
            model_01.text = @"车辆列表";
            model_01.imageName = @"center_carInfo";
            model_01.className = @"XMCompanyCarListViewController";
            
        }else
        {
            model_01.text = @"车辆信息";
            model_01.imageName = @"center_carInfo";
            model_01.className = @"XMCarInfoShowCarsViewController";
        
        }
        
        
        
        //!< wait to create new controller display record part. and click this cell must jump to rdVC
        
        XMSettingCellModel *model_02 = [XMSettingCellModel new];
        model_02.text = @"行车记录仪";
        model_02.imageName = @"setting_record";
        //        model_01.moreImageName = @"角标3+";
        model_02.className = @"XMDVRVideoViewController";
        
        XMSettingCellModel *model_03 = [XMSettingCellModel new];
        model_03.text = @"购买设备";
        model_03.imageName = @"center_buyDevice";
        model_03.className = @"XMBuyDeviceViewController";
        
        
        XMSettingCellModel *model_04 = [XMSettingCellModel new];
        model_04.text = @"设置";
        model_04.imageName = @"center_setting";
        model_04.className = @"XMSetViewController";
   
        
        XMSettingCellModel *model_05 = [XMSettingCellModel new];
        model_05.text = @"关于";
        model_05.imageName = @"center_about";
        model_05.className = @"XMAboutViewController";
      
        _dataSource = @[model_01,model_02,model_03,model_04,model_05];
        
        
    }
    
    return _dataSource;


}


#pragma mark -------------- 响应通知的方法
- (void)nickNameChange:(NSNotification *)noti
{
    
    self.headerView.nickName  = noti.userInfo[@"info"];
    
    
}

#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.dataSource.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMSettingCell *cell = [XMSettingCell dequeueReusableCellWithTableview:tableView];
    XMSettingCellModel *model = self.dataSource[indexPath.row];
    cell.cellModel = model;
    
  
    return cell;

}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    //->>当前模型
     XMSettingCellModel *model = self.dataSource[indexPath.row];
    //->>判断是否点击的是购买设备界面
    if([model.className isEqualToString:@"XMBuyDeviceViewController"])
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://www.cesiumai.com"]]) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cesiumai.com"]];
             return;
        }
       
        
    }
    
    //-- 关闭左侧设置栏
   AppDelegate *temDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [temDelegate.sliderVC closeLeftView];
    temDelegate.tabBarController.tabBar.hidden = YES;
    
    //-- 发送通知
   
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMSettingCellDidClickNotification object:self userInfo:@{@"class" : model.className}];
    
    
 
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    static float change = 0;
    
    change = scrollView.contentOffset.y - change;
    
    CGRect frame = self.bottomView.frame;
    
    frame.origin.y -= change;
    
    self.bottomView.frame = frame;
    
    change = scrollView.contentOffset.y;


}

/**
 *  设置状态栏样式
 */

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;

}


#pragma mark --- XMSettingHeaderViewDelegate

- (void)headerViewDidClick:(XMSettingHeaderView *)headerView
{
    //!< 头像被点击，发送通知跳转到个人信息设置界面

    if (isCompany)
    {
        //-- 如果是企业账号就不响应点击事件
        return;
    }
    
    //    //-- 关闭左侧设置栏
        AppDelegate *temDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
        [temDelegate.sliderVC closeLeftView];
    
        temDelegate.tabBarController.tabBar.hidden = YES;
    
     [[NSNotificationCenter defaultCenter] postNotificationName:kXMSettingCellDidClickNotification object:self userInfo:@{@"class":@"XMUserInfoViewController"}];

}



#pragma mark -- 监听按钮点击

/**
 *  点击更多按钮
 */
//- (void)moreBtnDidClick
//{
//     XMLOG(@"点击更多按钮");
//    //-- 跳转到车辆信息界面
//    
//}


//#pragma mark -- 监听头像点击的通知
//
//- (void)headerBtnClick
//{
//    //-- 进入头像界面，更换头像
//     XMLOG(@"收到通知");
//    
//}

#pragma mark --- 获取用户信息

- (void)getUserInfo
{
    
    //!< 初始化的时候获取用户信息并且显示

    XMUser *user = [XMUser user];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"getuserinfo&mobil=%@",user.mobil];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        
            int statusCode = [dic[@"code"] intValue];
            
            if (statusCode == 1)
            {
                //!< 获取数据成功加载数据
                [self setUserInfoWithDictionary:dic];
                
            }else
            {
                 //!< 请求失败加载响应的用户信息
                 [self setUserInfo];
            }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //!< 请求失败加载响应的用户信息
        [self setUserInfo];
        
    }];
    
    
    
    
    
}

- (void)setUserInfo
{
    //!< 获取用户信息失败的时候，加载本地，本地没有就显示默认信息
    
    UIImage * image = [UIImage imageWithContentsOfFile:XIAOMI_HEADERLOCALPATH];
    
    if (image == nil)
    {
        image = [UIImage imageNamed:@"center_userIcon"];
    }
    
    self.headerView.headerImage = image;
    
    
    NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo_nickName"];
    
    if (nickName == nil || nickName.length == 0)
    {
        nickName = @"昵称";
    }
    
    self.headerView.nickName = nickName;
    
    
}

//!< 获取用户信息成功的时候设置用户信息
- (void)setUserInfoWithDictionary:(NSDictionary *)dictionary
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dic = [dictionary[@"data"] firstObject];
    
    //!< 头像地址 @"http://120.24.74.215:8029"
    NSString *headerImagePath = dic[@"userimage"];
    
    
    if ([headerImagePath containsString:@"http://120.24.74.215:8029"])
    {
        headerImagePath = [headerImagePath stringByReplacingOccurrencesOfString:@"http://120.24.74.215:8029" withString:@"http://api.cesiumai.cn"];
    }
    
    if (![headerImagePath containsString:@"http://api.cesiumai.cn"])
    {
        headerImagePath = [@"http://api.cesiumai.cn" stringByAppendingString:headerImagePath];
    }
    
    
    if (headerImagePath.length > 0 && ![headerImagePath isEqualToString:@"(null)"])
    {
        
              //!< 保存地址到本地
            [defaults setObject:headerImagePath forKey:@"userInfo_userImage"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:headerImagePath]]];
                
                NSData *data = UIImagePNGRepresentation(image);
                
                [data writeToFile:XIAOMI_HEADERLOCALPATH atomically:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    if(image == nil)
                    {
                        self.headerView.headerImage = [UIImage imageNamed:@"center_userIcon"];
                    
                    }else
                    {
                    
                    self.headerView.headerImage = image;
                        
                    }
                    
                    
                });
                
             });
            
            
        
        
    }else
    {
        //!< 没有上传过图片，显示默认地址；
        
        //!< 保存地址到本地
        [defaults setObject:headerImagePath forKey:@"userInfo_userImage"];
        
        self.headerView.headerImage = [UIImage imageNamed:@"center_userIcon"];
    }
    
    //!< 性别
    [defaults setObject:dic[@"sex"] forKey:@"userInfo_sex"];
    
    //!< 签名
    [defaults setObject:dic[@"signname"] forKey:@"userInfo_signName"];
    
    
    //!< 生日
    [defaults setObject:dic[@"birthday"] forKey:@"userInfo_birthday"];
    
    //!< 地区
    [defaults setObject:dic[@"userarea"] forKey:@"userInfo_area"];
    
    //!< 昵称
    NSString *nickName = dic[@"nickname"];
    
    [defaults setObject:nickName forKey:@"userInfo_nickName"];
    
    if (nickName == nil || nickName.length == 0)
    {
        nickName = @"昵称";
    }
    
    self.headerView.nickName = nickName;
    
    
    
}


@end
