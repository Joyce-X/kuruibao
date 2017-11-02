//
//  XMMapDownloadViewController.m
//  kuruibao
//
//  Created by x on 16/9/18.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 下载管理界面，管理下载的离线地图
 
 
 ************************************************************************************************/
#import "XMMapDownloadViewController.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import "AFNetworking.h"
#import "XMSet_offLineMapViewController.h"
#import "XMOfflineMapProgress.h"
#import "XMDownloadCell.h"
#import "XMDownLoadViewController.h"


#define kNetInfoLabelHeight 25
#define kPromptDownloadBtnHeight 50
#define kToolBarHeight 44
#define GB (1024 * 1024 * 1024.0)


@interface XMMapDownloadViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (nonatomic,weak)UITableView* tableView;//!< 显示数据表格
@property (strong, nonatomic) NSMutableArray *firstSectionData;//!< 第一分区数据源
@property (strong, nonatomic) NSMutableArray *secondSectionData;//!< 第二分区数据源
@property (nonatomic,weak)UILabel* messageLabel;//!< 显示网络状态的label

@property (copy, nonatomic) NSString *tempSecondName;//!< 点击第二分区的cell对应的临时名称
@property (strong, nonatomic) NSIndexPath *tempSecondIndexPath;//!< 点击第二分区临时对应的indexPath（也可用于第一分区）
@property (strong, nonatomic) MAOfflineItem *tempItem;//!< 第一分区暂时的item

//@property (strong, nonatomic) NSTimer *timer;

@end

@implementation XMMapDownloadViewController



#pragma mark --- life circle

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self setupData];//!< 初始化数据
        
        [self monitorNetwork];//!< 监听网络变化
        
     }
    
    return self;


}


//!< 初始化数据
- (void)setupData
{
    XMOfflineMapProgress *offlineProgress = [XMOfflineMapProgress shareInstance];
    self.firstSectionData = [offlineProgress.downloadStages objectForKey:@"downloading"];
     self.secondSectionData = [NSMutableArray arrayWithContentsOfFile:XIAOMI_offlineMapfinishedPath];
    if(self.firstSectionData == nil)
    {
        self.firstSectionData = [NSMutableArray array];
    
    }
    
}

//!< 监听网络变化
- (void)monitorNetwork
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidChange:) name:XMNetWorkDidChangedNotification object:nil];
    
    
}



- (void)networkDidChange:(NSNotification *)noti
{
    int result = [noti.userInfo[@"info"] intValue];
    
    NSString *title = nil;
    switch (result) {
        case 0:
            
            //!< 没有连接到网络
            title = @"当前网络不可用";
            
            
            break;
        case 1:
            
            //!< 4G网络
            title = @"非WiFi环境，下载将消耗较多流量";
            
            break;
        case 2:
            
            //!< WiFi网络
            title = @"当前为WiFi网络，请放心下载";
            break;
        case -1:
            
            //!< 未知网络
            title = @"当前网络不可用";
            
            break;
            
        default:
            
            
            break;
    }
    _messageLabel.text = title;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createSubViews];  
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //!< 判断是否应该显示tableView
    if (self.firstSectionData.count == 0 && self.secondSectionData.count == 0)
    {
        self.tableView.hidden = YES;
    }else
    {
        self.tableView.hidden = NO;
    }
    [self.tableView scrollsToTop];

}


- (void)createSubViews
{
    
    //!< 网络状态label
    self.view.backgroundColor = XMColor(244, 244, 244);
    
    //!< 提示网络状态label
    UILabel *messgaeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 64, mainSize.width, kNetInfoLabelHeight)];
    messgaeLabel.backgroundColor = [UIColor orangeColor];
    messgaeLabel.textAlignment = NSTextAlignmentCenter;
    messgaeLabel.alpha = 0.4;
    messgaeLabel.textColor = [UIColor blackColor];
    messgaeLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:messgaeLabel];
    self.messageLabel = messgaeLabel;
    
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    NSString *title = nil;
    switch (status)
    {
        case AFNetworkReachabilityStatusUnknown:
            title = @"当前网络不可用";
            break;
        case AFNetworkReachabilityStatusNotReachable:
            title = @"当前网络不可用";
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            title = @"非WiFi环境，下载将消耗较多流量";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            title = @"当前为WiFi环境，可放心下载";
            break;
            
        default:
            break;
    }
    _messageLabel.text = title;
    
    

    
 
    //!< 创建提示下载地图的按钮
    UIButton *prompt = [[UIButton alloc]initWithFrame:CGRectMake(0, 124, mainSize.width, kPromptDownloadBtnHeight)];
    [prompt setTitleColor:XMColorFromRGB(0x5DD672) forState:UIControlStateNormal];
    [prompt addTarget:self action:@selector(promptBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [prompt setTitle:@"还没有离线地图，点击选择城市" forState:UIControlStateNormal];
    [self.view addSubview:prompt];
    
    
    //!< 创建tableView
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64 + kNetInfoLabelHeight , mainSize.width, mainSize.height - kNetInfoLabelHeight - 64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = XMColor(244, 244, 244);;
    
    UILabel *diskSpace = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 25)];
    diskSpace.textAlignment = NSTextAlignmentCenter;
//    diskSpace.backgroundColor = XMGrayColor;
    diskSpace.textColor = [UIColor blackColor];
    diskSpace.font = [UIFont systemFontOfSize:14];
    diskSpace.text = [NSString stringWithFormat:@"可用%.1fG,共%.1fG",[self freeDiskSpace],[self totalDiskSpace]];
    tableView.tableFooterView = diskSpace;
    [self.view addSubview:tableView];
    self.tableView = tableView;
     
    
}




-(void)dealloc
{
    XMLOG(@"下载管理界面销毁");
    
}

#pragma mark --- lazy
- (NSMutableArray *)secondSectionData
{
    if (!_secondSectionData)
    {
        _secondSectionData = [NSMutableArray array];
    }
    
    return _secondSectionData;

}

#pragma mark --- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.firstSectionData.count : self.secondSectionData.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        XMDownloadCell *cell = [XMDownloadCell dequeueResuableCellWithTableView:tableView];
        
        MAOfflineItem *item = self.firstSectionData[indexPath.row];
       
        
        //!< 更新地区的名称
        [cell updateTitleWithItem:item];
        
        //!< 根据当前是否处于下载状态来更新子控件显示的内容
        
        NSMutableDictionary *downloadStages = [XMOfflineMapProgress shareInstance].downloadStages;
        NSArray *arr = [downloadStages objectForKey:@"cache"];
        if ([arr containsObject:item]) {
            //!< 第一次加载
            [cell updateAccessoryViewWithItem:item];

        }else
        {
        
            //!< 取出对应的下载项目的下载信息
            NSMutableDictionary *stage  = [downloadStages objectForKey:item.adcode];
            
            //!< 更新处于正在下载状态的cell 最后一个参数暂时没有用到，随便传
            [cell updateContentWithItem:item infoDictionary:stage contentInDownloading:YES];
        
        }
//        NSMutableArray *downloadItems = [downloadStages objectForKey:@"downloading"];
        
        
        
        
        
        
//        cell.nameLabel.text = item.name;
        return cell;
        
    }else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"secondCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"secondCell"];
        }
        cell.textLabel.text = self.secondSectionData[indexPath.row];
        cell.detailTextLabel.text = @"已安装";
        cell.textLabel.font = [UIFont systemFontOfSize:13];
         cell.textLabel.textColor = XMGrayColor;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
        cell.detailTextLabel.textColor = XMGrayColor;
        return cell;
    }
    
    
    
    
    
    



}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 30)];
    headerView.backgroundColor = XMColor(235, 235, 235);
    UILabel *message = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 30)];
    message.textColor = [UIColor brownColor];
    message.font = [UIFont systemFontOfSize:13];
    message.text = section == 0 ? @"正在下载" : @"下载完成";
    [headerView addSubview:message];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor blackColor];
    line.alpha = 0.2;
    [headerView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.equalTo(headerView);
        make.bottom.equalTo(headerView);
        make.centerX.equalTo(headerView);
        make.height.equalTo(1);
        
    }];
    
    return headerView;


}


#pragma mark --- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.tempSecondIndexPath = indexPath;  //!< 记录点击下标
    if (indexPath.section == 0)
    {
        
        if (self.firstSectionData.count < indexPath.row ) {
            return;
        }
        self.tempItem = self.firstSectionData[indexPath.row];
        
        if ([[MAOfflineMap sharedOfflineMap] isDownloadingForItem:self.tempItem])
        {
            //!< 正在下载
            UIActionSheet *sheet_first = [[UIActionSheet alloc]initWithTitle:_tempItem.name delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"暂停下载", nil];
            sheet_first.tag = 100;
            [sheet_first showInView:self.view];
        }else
        {
            //!< 暂停下载或者下载失败的情况
     
            UIActionSheet *sheet_first = [[UIActionSheet alloc]initWithTitle:_tempItem.name delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"开始下载", nil];
            sheet_first.tag = 99;
            [sheet_first showInView:self.view];
        
        }
        
        
        
        
        
        
    }else
    {
        
        self.tempSecondName = [self.secondSectionData objectAtIndex:indexPath.row];
        //!< 点击已经下载完成的项目，显示查看地图，删除地图，取消
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:self.secondSectionData[indexPath.row] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:@"查看地图", nil];
        sheet.tag = 101;
        [sheet showInView:self.view];
    
    }
    



}

#pragma mark --- UIActionSheetDelegate


// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(actionSheet.tag == 101) //!< 点击第二分区
    {
    
        //!<  0:删除 1:查看地图 2:取消
        if(buttonIndex == 0)
        {
            [self deleteItemInSecondSection]; //!< 删除操作
            
        }else if(buttonIndex == 1)
        {
            [self previewOfflineItem]; //!< 查看地图
        }
    
    }else if (actionSheet.tag == 99) //!< 点击第一分区
    {
        if(buttonIndex == 0) //!< 开始下载
        {
        
            if (![self.firstSectionData containsObject:_tempItem])
            {
                return;
            }
          
            
            [[XMDownLoadViewController sharedInstance] downloadItem:_tempItem];
            
            
            
        }
        
    }else if(actionSheet.tag == 100)
    {
        if(buttonIndex == 0) //!<暂停下载
        {
            
            if (![self.firstSectionData containsObject:_tempItem])
            {
                return;
            }
            
            [[MAOfflineMap sharedOfflineMap] pauseItem:_tempItem];
            
            
            
        }
    
    
    }
}

#pragma mark --- operateMap --- 一分区

//!< 删除离线地图数据
- (void)deleteItemInSecondSection
{
    
    if([self.tempSecondName isEqualToString:@"全国概要图"])
    {
    
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"全国基础包不能删除" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    
    }
    
    //!< 删除数据
     [self.secondSectionData removeObject:self.tempSecondName];
    
    //!< 刷新表格
    [self.tableView deleteRowsAtIndexPaths:@[_tempSecondIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //!< 写入数据到沙河
    [self.secondSectionData writeToFile:XIAOMI_offlineMapfinishedPath atomically:YES];
    
    
    //!< 删除离线地图数据
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name MATCHES %@",self.tempSecondName];
    NSArray *items = [[MAOfflineMap sharedOfflineMap].cities filteredArrayUsingPredicate:predicate];
    [[MAOfflineMap sharedOfflineMap] deleteItem:[items firstObject]];
    
}

//!< 查看离线地图数据
- (void)previewOfflineItem
{
    
    if([_tempSecondName isEqualToString:@"全国概要图"])
    {
    
        //!< 如果是全国基础图就显示首都
        _tempSecondName = @"北京";
    
    }
    
    //!< 地理编码，通知控制器展示响应省市
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPreviewOfflineMapNotification object:nil userInfo:@{@"info":_tempSecondName}];
    
    
}


#pragma mark --- operateMap --- 第二分区





#pragma mark --- XMDownLoadViewControllerDelegate


/**
 *  将要下载一个项目的时候调用代理方法
 *
 * para : 要下载的项目
 */

- (void)downloadViewController:(XMDownLoadViewController *)viewController willBeginDownloadItem:(MAOfflineItem *)item
{

     //!< 在点击开始下载某一个离线项目的时候，就要更新第一分区的数据，不然第二分区更新数据的时候会出问题
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.firstSectionData.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 

}

/**
 *  更新数据调用代理是代理更新数据
 *
 * para : 更新的项目
 */

- (void)downloadViewController:(XMDownLoadViewController *)viewController didUpdateInfoForItem:(MAOfflineItem *)item
{
 
    //!< 取出对应的cell下标进行数据更新
    NSInteger index = [self.firstSectionData indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    XMDownloadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell)
    {
        //!< 取出字典获取下载阶段
        NSMutableDictionary *downloadStages = [XMOfflineMapProgress shareInstance].downloadStages;
        NSMutableDictionary *stage  = [downloadStages objectForKey:item.adcode];//!< 取出存放的对应数据的字典
        [cell updateContentWithItem:item infoDictionary:stage contentInDownloading:NO];
    }
}


/**
 *  将要下载完成一个项目的时候调用代理方法
 *
 * para : 完成下载的项目
 */
- (void)downloadViewController:(XMDownLoadViewController *)viewController willFinishDownloadItem:(MAOfflineItem *)item
{
 
    
    
    //!< 更新第二分区数据
    //!< 修改数据源 将完成的数据添加到数据源
    //!< 进行判断，数组中是否有当前离线项目名称，没有添加，有就不执行操作
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self = %@",item.name];
    NSArray *arr = [self.secondSectionData  filteredArrayUsingPredicate:predicate];
    if (arr.count == 0)
    {
        [self.secondSectionData addObject:item.name];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.secondSectionData.count - 1 inSection:1];
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }

    
 
    
    
    //!< 更新第一分区数据（item还没有被删除）
    //!< 找出item对应的indexPath 删除数据源  删除cell
    NSInteger index = [self.firstSectionData indexOfObject:item];//!< 在数组中的位置，用来计算indexPath
    NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.firstSectionData removeObject:item];
    [self.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    
    //!< 更新tableview尾部存储容量
   UILabel *footer = (UILabel *)self.tableView.tableFooterView;
   footer.text = [NSString stringWithFormat:@"可用%.1fG,共%.1fG",[self freeDiskSpace],[self totalDiskSpace]];
    
}


/**
 *  点击已经下载完成的项目
 *
 * para : 完成下载的项目
 */
- (void)downloadViewController:(XMDownLoadViewController *)viewController didClickFinishedItem:(MAOfflineItem *)item
{
    //!< 取出index 滚到顶部
    NSInteger index = [self.secondSectionData indexOfObject:item.name];
    if (index == NSNotFound)
    {
        //!< 预防崩溃
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];



}

/**
 *  点击正在下载的项目
 *
 * para : 正在下载的项目
 */
- (void)downloadViewController:(XMDownLoadViewController *)viewController didClickDownloadingItem:(MAOfflineItem *)item
{
    //!< 取出index 滚到顶部
    NSInteger index = [self.firstSectionData indexOfObject:item];
    if (index == NSNotFound)
    {
        //!< 预防崩溃
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];



}

#pragma mark --- 按钮的点击事件

//!< 点击提示按钮
- (void)promptBtnDidClick
{
 
    XMSet_offLineMapViewController *vc = (XMSet_offLineMapViewController *)self.tabBarController;
    [vc jumpToCityList];
    
}


#pragma mark --- 获取手机容量

- (CGFloat )totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [[fattributes objectForKey:NSFileSystemSize] longLongValue] / GB;  //!< GB
}

- (CGFloat)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [[fattributes objectForKey:NSFileSystemFreeSize]longLongValue] / GB;  //!< GB
}



 @end
