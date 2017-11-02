//
//  XMDVRSettingViewController.m
//  GKDVR
//
//  Created by x on 16/10/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/**********************************************************
 class description:
 
    preferences of video
 
 **********************************************************/

#import "XMDVRSettingViewController.h"
#import "XMDVRAboutViewController.h"
#import "XMDVREquipmentViewController.h"
#import "XMDVRVideoTableViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "XMDVRSettingCell.h"



@interface XMDVRSettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation XMDVRSettingViewController



#pragma mark --- life circle


- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self setupInit];
    
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"记录仪设置页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"记录仪设置页面");
    
}



- (void)setupInit
{
    self.message = @"设置";
    
    self.imageVIew.image = [UIImage imageNamed:@"DVR_mainBackground"];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:
                              CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH)];
    
    tableView.dataSource = self;
    
    tableView.delegate = self;
    
    tableView.tableFooterView = [UIView new];
    
    tableView.rowHeight = 44;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.backgroundColor = XMWhiteColor;
    
    [self.view addSubview:tableView];
    
    
}




#pragma mark --- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"settingCell";
    
    XMDVRSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
     if (cell == nil)
     {
        cell = [[XMDVRSettingCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
         cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        
     }
    
    switch (indexPath.row) {
        case 0:
            
            cell.textLabel.text = @"录像";
            
            cell.imageView.image = [UIImage imageNamed:@"DVR_setting_recording"];
            
             break;
            
        case 1:
            
            cell.textLabel.text = @"还原";
            
            cell.imageView.image = [UIImage imageNamed:@"DVR_setting_reset"];
            break;
            
        case 2:
            
            cell.textLabel.text = @"关于";
            
            cell.imageView.image = [UIImage imageNamed:@"DVR_setting_about"];
             break;
            
        default:
            
            break;
    }
    
    
    return cell;
    
}


#pragma mark --- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *wifiName = [self getCurrentWIFIName];
    
    
        if (wifiName == nil || ![wifiName containsString:@"DVR_"])
        {
            [MBProgressHUD showError:@"尚未联机"];
    
            return;
        }
    
    switch (indexPath.row)
    {
        case 0:
            
            [self.navigationController pushViewController:[XMDVRVideoTableViewController new] animated:YES];
            
            
            break;
            
        case 1:
            
            [self.navigationController pushViewController:[XMDVREquipmentViewController new] animated:YES];
            
            break;
            
        case 2:
            
            
            [self.navigationController pushViewController:[XMDVRAboutViewController new] animated:YES];
            
            
            break;
            
        default:
            
            break;
    }
  

}

//!< get WIFI  current name

- (NSString *)getCurrentWIFIName
{
    
    NSString *WIFIName = nil;
    
    NSArray *allWIFI = CFBridgingRelease(CNCopySupportedInterfaces());//!< all wifi
    
    
    for (NSString *wifi in allWIFI)
    {
        CFDictionaryRef dic = CNCopyCurrentNetworkInfo((__bridge CFStringRef)wifi);
        
        WIFIName = ((__bridge NSDictionary *)dic)[@"SSID"];
        
        
        
    }
    
    return WIFIName;
    
}


@end
