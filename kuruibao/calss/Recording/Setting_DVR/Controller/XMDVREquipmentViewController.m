//
//  XMDVREquipmentViewController.m
//  GKDVR
//
//  Created by x on 16/10/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMDVREquipmentViewController.h"
#import "AFNetworking.h"
#import "XMLDictionary.h"
#import "XMDVRSettingCell.h"


@interface XMDVREquipmentViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray *titles;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (nonatomic,weak)UITableView* tableView;

@end

@implementation XMDVREquipmentViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
   
}




- (void)setupInit
{
    self.message = @"还原设置";
    
    self.titles = @[@"格式化",@"恢复出厂设置",@"版本"];
    
    self.imageVIew.image = [UIImage imageNamed:@"DVR_mainBackground"];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height -backImageH) style:UITableViewStylePlain];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.backgroundColor = XMWhiteColor;
    
    tableView.rowHeight = 44;
    
    tableView.tableFooterView = [UIView new];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlStr = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=getversion";
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        NSString *result = [NSString stringWithCString:[responseObject bytes] encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:result];
        
        NSString *version = dic[@"Firmware_version"];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        cell.detailTextLabel.text = version;
        
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
    }];
    
    MobClickBegain(@"记录仪设备页面");
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    MobClickEnd(@"记录仪设备页面");


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


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    return 3;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"equipmentCell";
    
    XMDVRSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        
        cell = [[XMDVRSettingCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
    }
    
    cell.textLabel.text = self.titles[indexPath.row];
    
    cell.imageView.image = [self getImageWithIndexPath:indexPath];
    
    if (indexPath.row != 2)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}


#pragma mark --- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"确定格式化DVR SD卡" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        alert.tag = indexPath.row;
        
        [alert show];
        
    }else if(indexPath.row == 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"是否恢复出厂设置，需重启生效" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        alert.tag = indexPath.row;
        
        [alert show];

    
    
    }
    


}

#pragma mark --- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0)
    {
        [self setupFormatSDCardWithIndex:buttonIndex];
        
    }else if (alertView.tag == 1)
    {
    
        [self setupResetWithIndex:buttonIndex];
    
    }


}


#pragma mark --- operation

- (void)setupFormatSDCardWithIndex:(NSInteger)index
{
    if (index == 0)return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlStr = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=Formattf";
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showSuccess:@"格式化完毕"];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"格式化失败"];
        
    }];
    
    
}

- (void)setupResetWithIndex:(NSInteger)index
{
    
    if (index == 0)return;
    
    //http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=Restore
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlStr = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=Restore";
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showSuccess:@"恢复成功，需重启生效"];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
    }];
    
    
}



- (UIImage *)getImageWithIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image;
    
    switch (indexPath.row)
    {
        case 0:
            
            image = [UIImage imageNamed:@"DVR_setting_format"];
            
            break;
        case 1:
            
            image = [UIImage imageNamed:@"DVR_setting_resetFirst"];
            
            break;
        case 2:
            
            image = [UIImage imageNamed:@"DVR_setting_versionIcon"];
            
            break;
            
        default:
            break;
    }
    
    return image;
    
}

@end
