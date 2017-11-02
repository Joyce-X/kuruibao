//
//  XMDVRVideoTableViewController.m
//  GKDVR
//
//  Created by x on 16/10/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/**********************************************************
 class description:
 
        DVR模块中设置 - 录像 - 设置选项内容控制器
 
 **********************************************************/
#import "XMDVRVideoTableViewController.h"
#import "AFNetworking.h"
#import "XMLDictionary.h"
#import "XMDVRSettingCell.h"

#define kXMDVRSettingManualChangeRecordStatusNotification @"kXMDVRSettingManualChangeRecordStatusNotification"

@interface XMDVRVideoTableViewController ()<UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSArray *titles;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (assign, nonatomic) NSInteger totalItem;//!< 总共设置的项目

@property (nonatomic,weak)UITableView* tableView;
@end

@implementation XMDVRVideoTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"记录仪详细设置页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"记录仪详细设置页面");
    
}


- (void)setupInit
{
    self.message = @"录像设置";
    
    self.totalItem  = 0;
    
    self.imageVIew.image = [UIImage imageNamed:@"DVR_mainBackground"];
    
    self.titles = @[@"录像",@"录音开关",@"录像方式",@"分辨率",@"录像时间",@"灵敏度"];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH) style:UITableViewStylePlain];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.backgroundColor  =XMWhiteColor;
    
    tableView.rowHeight = 44;
    
    tableView.tableFooterView = [UIView new];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
     
    [self loadNewData];
    
}

#pragma mark --- lazy

- (AFHTTPSessionManager *)session
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


#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"VideoCell";
    
    XMDVRSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        
        cell = [[XMDVRSettingCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        cell.imageView.image = [self getImageWithIndexPath:indexPath];
        
 
    }

    cell.textLabel.text = self.titles[indexPath.row];
    
    [self setupCellWithCell:cell indexPath:indexPath];


    return cell;
}




#pragma mark --- UItTableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0 || indexPath.row == 1)return;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self didSelectCell:cell indexPath:indexPath];
     


}

#pragma mark --- set cell
- (void)setupCellWithCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{

    switch (indexPath.row)
    {
        case 0:
        {
            UISwitch *siwitch = [UISwitch new];
            
            [siwitch addTarget:self action:@selector(videoSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            cell.accessoryView = siwitch;
            
            cell.detailTextLabel.text = @"是     ";
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
            
        case 1:
            
        {
            UISwitch *siwitch = [UISwitch new];
            
            [siwitch addTarget:self action:@selector(recordeSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            cell.accessoryView = siwitch;
            
            cell.detailTextLabel.text = @"静音     ";
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
            break;
            
        case 2:
            
            cell.detailTextLabel.text = @"自动";
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            
            break;
            
        case 3:
            
            cell.detailTextLabel.text = @"1080P";
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            
            break;
            
        case 4:
            
            cell.detailTextLabel.text = @"5分钟";
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            
            break;
            
        case 5:
            
            cell.detailTextLabel.text = @"高";
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            
            break;
            
        default:
            
            
            break;
    }
    
    
    
    
}


#pragma mark --- select cell

- (void)didSelectCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    NSString *title = cell.textLabel.text;
    
    switch (indexPath.row)
    {
        case 2:
        {
        
            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                otherButtonTitles:@"自动",@"手动", nil];
            
            sheet.tag = indexPath.row;
            
            [sheet showInView:self.view];
        
            
            
        }
            break;
        case 3:
        {
            
            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"1080P",@"720P", nil];
            
            sheet.tag = indexPath.row;
            
            [sheet showInView:self.view];
            
            
            
        }
            
            
            break;
        case 4:
        {
            
            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                otherButtonTitles:@"1分钟",@"3分钟",@"5分钟", nil];
            
            sheet.tag = indexPath.row;
            
            [sheet showInView:self.view];
            
            
            
        }
            
            
            break;
        case 5:
        {
            
            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"高",@"中",@"低", nil];
            
            sheet.tag = indexPath.row;
            
            [sheet showInView:self.view];
            
            
            
        }
            
            
            break;
            
        default:
            break;
    }
    
    
    
    
    
}



#pragma mark --- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSInteger index = actionSheet.tag;
    switch (index)
    {
        case 2:
            
            [self setupVideoStyleWithIndex:buttonIndex];
            
            break;
        case 3:
            
            [self setupResolutionWithIndex:buttonIndex];
            
            break;
        case 4:
            
            [self setupVideoTimeWithIndex:buttonIndex];
            
            break;
        case 5:
            
            [self setupSensitivityWithIndex:buttonIndex];
            
            break;
            
        default:
            break;
    }
    



}

#pragma mark --- monitor switch value changed

- (void)videoSwitchValueChanged:(UISwitch *)sender
{
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
    
    NSString *url;
    
    if (sender.on)
    {
       url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=setrecstatus&recstat=1";
        
    }else
    {
        url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=setrecstatus&recstat=0";
    }
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        if (sender.on)
        {
            cell.detailTextLabel.text = @"是    ";
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kXMDVRSettingManualChangeRecordStatusNotification object:self userInfo:@{@"info":@1}];
            
            
        }else
        {
            cell.detailTextLabel.text = @"否    ";
            [[NSNotificationCenter defaultCenter] postNotificationName:kXMDVRSettingManualChangeRecordStatusNotification object:self userInfo:@{@"info":@0}];
            
            
            
        }
        
        [MBProgressHUD showSuccess:@"设置成功"];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"操作失败"];
        
         sender.on = !sender.on;
        
    }];
    
    
    
}


- (void)recordeSwitchValueChanged:(UISwitch *)sender
{
    
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
    
    NSString *url;
    if (sender.on)
    {
        url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setaudio&recmute=0";
        
    }else
    {
        url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setaudio&recmute=1";
    }
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        if (sender.on)
        {
            cell.detailTextLabel.text = @"开启    ";
        }else
        {
            cell.detailTextLabel.text = @"静音    ";
        }
        
        [MBProgressHUD showSuccess:@"设置成功"];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"操作失败"];
        
        sender.on = !sender.on;
        
    }];
    

    
    
}

#pragma mark --- opteration

- (void)setupVideoStyleWithIndex:(NSInteger)index //!< 自动，手动
{
    
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];

    NSString *url;
    
    if(index == 0)
    {
        url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=setrecmode&recmode=0";
    
    }else
    {
        url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=setrecmode&recmode=1";
    
    }
    
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        if (!index)
        {
            cell.detailTextLabel.text = @"自动";
        }else
        {
            cell.detailTextLabel.text = @"手动";
        }
        
        [MBProgressHUD showSuccess:@"设置成功"];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"操作失败"];
        
        
        
    }];

    
    
    
    
}

- (void)setupResolutionWithIndex:(NSInteger)index //!< 1080,720
{
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
 
    NSString *url;
    
    if(index == 0)
    {
        url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setrecord&resolution=0";
        
    }else
    {
        url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setrecord&resolution=1";
        
    }
    
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        
        if (index)
        {
            cell.detailTextLabel.text = @"720P";
        }else
        {
            cell.detailTextLabel.text = @"1080P";
        }
        
        [MBProgressHUD showSuccess:@"设置成功"];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"操作失败"];
        
        
        
    }];

    
    
}

- (void)setupVideoTimeWithIndex:(NSInteger)index //!< 1,3,5
{
    
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];

    NSString *url;
    
    switch (index) {
        case 0:
            
            url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setrecord&rectime=0";
            
            break;
            
        case 1:
            
            url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setrecord&rectime=1";
            
            break;
            
        case 2:
            
            url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setrecord&rectime=2";
            
            break;
            
        default:
            
            url = @"http://192.168.63.9";
            break;
    }
    
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        
        
        switch (index) {
            case 0:
                
                cell.detailTextLabel.text = @"1分钟";
                break;
                
            case 1:
                
                 cell.detailTextLabel.text = @"3分钟";
                
                break;
                
            case 2:
                
                 cell.detailTextLabel.text = @"5分钟";
                
                break;
                
            default:
                break;
        }
        
        
        [MBProgressHUD showSuccess:@"设置成功"];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"操作失败"];
        
        
        
    }];
    
}

- (void)setupSensitivityWithIndex:(NSInteger)index //!< 高，中，低
{
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
    
    NSString *url;
    
    switch (index) {
        case 0:
            
            url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setgsensor&gsensordpi=2";
            
            break;
            
        case 1:
            
            url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setgsensor&gsensordpi=1";
            
            break;
            
        case 2:
            
            url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setgsensor&gsensordpi=0";
            
            break;
            
        default:
            url = @"";
            break;
    }
    
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        
        
        switch (index) {
            case 0:
                
                cell.detailTextLabel.text = @"高";
                break;
                
            case 1:
                
                cell.detailTextLabel.text = @"中";
                
                break;
                
            case 2:
                
                cell.detailTextLabel.text = @"低";
                
                break;
                
            default:
                break;
        }
        
        
        [MBProgressHUD showSuccess:@"设置成功"];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"操作失败"];
        
        
        
    }];
    
    
}


//!<  enter this view will load new data

- (void)loadNewData
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self setRecordVideoValue];             //!< is recording
    
    [self setAudioValue];                   //!< audio Switch
    
    [self setRecordStyleValue];             //!< recordStyle
    
    [self setRecordTimeAndResolutionValue]; //!< recordTime and resolution
    
    [self setSensitivityValue];             //!< sensitivity
    
}

- (void)setRecordVideoValue
{
    //!< 1 judege is recording
    
    NSString *url_recordStatus = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=getrecstatus";
    
    [self.session GET:url_recordStatus parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.totalItem++;
        
        NSString *result_status = [NSString stringWithCString:[responseObject bytes] encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic_status = [NSDictionary dictionaryWithXMLString:result_status];
        
        BOOL isRecord = [dic_status[@"RecStat"] intValue];
        
        XMDVRSettingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        UISwitch *switch_recordStatus = (UISwitch *)cell.accessoryView;
        
        if (isRecord)
        {
            [switch_recordStatus setOn:YES];
            
            cell.detailTextLabel.text = @"是     ";
            
        }else
        {
            
            [switch_recordStatus setOn:NO];
            
            cell.detailTextLabel.text = @"否     ";
         
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.totalItem++;
        
    }];
    
    
}


- (void)setAudioValue
{
    //!< 2 judge audio switch
    
    NSString *url_audio = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=getaudio";
    [self.session GET:url_audio parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.totalItem++;
        
        NSString *result_audio = [NSString stringWithCString:[responseObject bytes] encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic_audio = [NSDictionary dictionaryWithXMLString:result_audio];
        
        BOOL audioOpen = [dic_audio[@"RecMute"] intValue];
        
        XMDVRSettingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        UISwitch *switch_audioStatus = (UISwitch *)cell.accessoryView;
        
        if (audioOpen)
        {
            [switch_audioStatus setOn:NO];
            
            cell.detailTextLabel.text = @"静音     ";
            
        }else
        {
            
            [switch_audioStatus setOn:YES];
            
            cell.detailTextLabel.text = @"开启     ";
            
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        self.totalItem++;
        
    }];
    
    
}


- (void)setRecordStyleValue
{
    //!< get recordStyle
    
    NSString *url_recMode = @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=getrecmode";
    
    [self.session GET:url_recMode parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.totalItem++;
        
        NSString *resultStr = [NSString stringWithCString:[responseObject bytes] encoding:NSUTF8StringEncoding];
        
        NSDictionary *recModeDic = [NSDictionary dictionaryWithXMLString:resultStr];
        
        int result = [recModeDic[@"RecMode"] intValue];
        
        XMDVRSettingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        if (result)
        {
            //!< manual
            
            cell.detailTextLabel.text = @"手动";
            
        }else
        {
            //!< auto
            
            cell.detailTextLabel.text = @"自动";
            
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.totalItem++;
    }];

    
    
}


- (void)setRecordTimeAndResolutionValue
{
    
    NSString *url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=getrecord";
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.totalItem ++;
        
        NSString *result = [NSString stringWithCString:[responseObject bytes] encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:result];
        
        int resolution = [dic[@"Resolution"] intValue];
        
        int recordTime = [dic[@"Rectime"] intValue];
        
        XMDVRSettingCell *cell_resolution = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        
        XMDVRSettingCell *cell_recordTime = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];

        if (resolution)
        {
            cell_resolution.detailTextLabel.text = @"720P";
        }else
        {
            cell_resolution.detailTextLabel.text = @"1080P";

        
        }
        
        switch (recordTime) {
            case 0:
                
                cell_recordTime.detailTextLabel.text = @"1分钟";
                
                break;
                
            case 1:
                
                cell_recordTime.detailTextLabel.text = @"3分钟";
                
                break;
                
            case 2:
                
                cell_recordTime.detailTextLabel.text = @"5分钟";
                
                break;
                
            default:
                break;
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        self.totalItem ++;
    }];
    
}

- (void)setSensitivityValue
{
    NSString *url = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=getgsensor";
    
    [self.session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        self.totalItem ++;
        
        NSString *result = [NSString stringWithCString:[responseObject bytes] encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:result];
        
        int sensitivity = [dic[@"Gsensordpi"] intValue];
        
        XMDVRSettingCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        
        switch (sensitivity) {
            case 0:
                
                cell.detailTextLabel.text = @"低";
                
                break;
                
            case 1:
                
                cell.detailTextLabel.text = @"中";
                
                break;
                
            case 2:
                
                cell.detailTextLabel.text = @"高";
                
                break;
            default:
                break;
        }
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        self.totalItem ++;
    }];
    
    
}



- (void)setTotalItem:(NSInteger)totalItem
{
    _totalItem = totalItem;
    
    if (totalItem == 5)
    {
        [MBProgressHUD hideHUDForView:self.view];
    }


}


- (UIImage *)getImageWithIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image;
    
    switch (indexPath.row)
    {
        case 0:
            
            image = [UIImage imageNamed:@"DVR_setting_videoIcon"];
            
            break;
        case 1:
            
            image = [UIImage imageNamed:@"DVR_setting_audioSwitch"];
            
            break;
        case 2:
            
            image = [UIImage imageNamed:@"DVR_setting_recordStyle"];
            
            break;
        case 3:
            
            image = [UIImage imageNamed:@"DVR_setting_resolution"];
            
            break;
        case 4:
            
            image = [UIImage imageNamed:@"DVR_setting_recordTime"];
            
            break;
        case 5:
            
            image = [UIImage imageNamed:@"DVR_setting_sensitivityIcon"];
            
            break;
         
            
        default:
            break;
    }

    return image;

}

@end
