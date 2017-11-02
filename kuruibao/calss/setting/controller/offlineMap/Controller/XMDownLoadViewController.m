//
//  OfflineDetailViewController.m
//  OfficialDemo3D
//
//  Created by xiaoming han on 14-5-5.
//  Copyright (c) 2014年 songjian. All rights reserved.

#import "XMDownLoadViewController.h"

#import "MAHeaderView.h"
#import "XMDownloadCell.h"
#import "AFNetworking.h"
#import "XMOfflineMapProgress.h"
#import "XMSet_offLineMapViewController.h"


#define kDefaultSearchkey       @"bj" //默认的搜索关键字
#define kSectionHeaderMargin    15.f  //边距间隙
#define kSectionHeaderHeight    25.f  //前三个分区头部高度
#define kTableCellHeight        40.f  //cell高度（3之后分区头部高度）
#define kTagDownloadButton 0
#define kTagPauseButton 1
#define kTagDeleteButton 2
#define kButtonSize 30.f
#define kButtonCount 3

#define GB (1024 * 1024 * 1024.0)


typedef NS_ENUM(NSUInteger, XMNetState) {
    XMNetStateNone,//!< 没有网络
    XMNetState4G,//!< 4G网络
    XMNetStateWIFI//!< WiFi网络
};


static XMDownLoadViewController *downloadVC = nil;

@interface XMDownLoadViewController (SearchCity)

/* Returns a new array consisted of MAOfflineCity object for which match the key. */
- (NSArray *)citiesFilterWithKey:(NSString *)key;

@end

@interface XMDownLoadViewController ()< MAHeaderViewDelegate,UIAlertViewDelegate>
{
    char *_expandedSections;
    
}

@property (nonatomic,strong)NSMutableArray* sections;//!< 存放标记的数组

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, strong) NSPredicate *predicate;

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *municipalities;

//@property (nonatomic, strong) NSMutableSet *downloadingItems;
//@property (nonatomic, strong) NSMutableDictionary *downloadStages;//->>下载阶段

@property (nonatomic, assign) BOOL needReloadWhenDisappear;//->>是否需要重新加载

@property (nonatomic,strong)NSMutableArray* sectionHeaders;

@property (assign, nonatomic) XMNetState currentstate;//!< 当前网络状态

@property (strong, nonatomic) MAOfflineItem *temItem;//!< 暂时下载项
@property (strong, nonatomic) NSIndexPath *temIndexPath;//!< 临时下标
@property (strong, nonatomic) NSMutableDictionary *relationTab;//!< item 和 indexPath关系



//***********************下载省份记录数据
@property (strong, nonatomic) MAOfflineItem *temProvinceItem;
@property (strong, nonatomic) NSIndexPath *temProvinceIndexPath;


@end

@implementation XMDownLoadViewController




#pragma mark - Life Cycle


//!< 单例

+(instancetype)sharedInstance
{
    if (downloadVC == nil)
    {
        downloadVC = [[self alloc]init];
    }
    
    return downloadVC;
    
}

//->>初始化相关信息
- (id)init
{
    
    self = [super init];
    if (self)
    {
        [self setupCities];//->>初始化数组集合信息
        
        //[self setupPredicate];//->>初始化谓词
        
        [self checkNewestVersionAction];//->>检测新版本
        
        //!< 监控网络变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitorNetStatus:) name:XMNetWorkDidChangedNotification object:nil];
        
        self.relationTab = [NSMutableDictionary dictionary];
//        
//        NSMutableArray *arr = [[XMOfflineMapProgress shareInstance].downloadStages objectForKey:@"downloading"];
//        
//        for (MAOfflineItem * item in [MAOfflineMap sharedOfflineMap].cities)
//        {
//            if ([item isKindOfClass:[MAOfflineProvince class]])
//            {
//                continue;
//            }
//            if (item.itemStatus == MAOfflineItemStatusCached) {
//                [arr addObject:item];
//            }
//        }
        
        
    }
    
    return self;
}

//->>检测新版本
- (void)checkNewestVersionAction
{
    
    [[MAOfflineMap sharedOfflineMap] checkNewestVersion:^(BOOL hasNewestVersion) {
        
        if (!hasNewestVersion)
        {
            //->>没有新版本
            return;
        }
        //->>在主线程操作用户界面
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [self setupCities];//->>设置数组信息等
            
            [self.tableView reloadData];//->>更新表格
        });
    }];
}



- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self initTableView];//->>初始化子控件
    
//    [[MAOfflineMap sharedOfflineMap] clearDisk];
}


//->>初始化tableview
- (void)initTableView
{
    
    //!< 创建tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, mainSize.width, mainSize.height - 44) style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    //    self.tableView.tableHeaderView = [UIView new];
    [self.view addSubview:self.tableView];
}


- (NSMutableArray *)sections
{
    
    if (!_sections)
    {
        _sections = [NSMutableArray array];
    }
    return _sections;
    
}


- (void)setupCities
{
    
    
    self.sectionTitles = @[@"全国基础图", @"热门城市", @"全部省市"];
    
    self.cities = [MAOfflineMap sharedOfflineMap].cities;//->>城市数组，包括直辖市和普通城市
    self.provinces = [MAOfflineMap sharedOfflineMap].provinces;//->>省份数组，包括所有省份
    self.municipalities = [MAOfflineMap sharedOfflineMap].municipalities;//->>直辖市数组
    
    //    self.downloadingItems = [NSMutableSet set];//->>正在下载的项目
    //    self.downloadStages = [NSMutableDictionary dictionary];//->>下载阶段
    //    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    self.downloadStages = appDelegate.downloadStages;
    
    if (_expandedSections != NULL)
    {
        free(_expandedSections);
        _expandedSections = NULL;
    }
    
    _expandedSections = (char *)malloc((self.sectionTitles.count + self.provinces.count) * sizeof(char));
    memset(_expandedSections, 0, (self.sectionTitles.count + self.provinces.count) * sizeof(char));
    
}



- (void)monitorNetStatus:(NSNotification *)noti
{
    int result = [noti.userInfo[@"info"] intValue];
    if (result != 2)
    {
        [[MAOfflineMap sharedOfflineMap] cancelAll];//!< 不是WiFi 取消所有下载
//        for (MAOfflineItem *item in self.downloadingItems)
//        {
//            
//            [[MAOfflineMap sharedOfflineMap] pauseItem:item];
//        }
        
    }
    switch (result) {
        case 0:
            
            //!< 没有连接到网络
            self.currentstate = XMNetStateNone;
            
            break;
        case 1:
            
            //!< 4G网络
            self.currentstate = XMNetState4G;
            
            break;
        case 2:
            
            //!< WiFi网络
            self.currentstate = XMNetStateWIFI;
            
            break;
        case -1:
            
            //!< 未知网络
            self.currentstate = XMNetStateNone;
            
            break;
            
        default:
            
            
            break;
    }
}




- (void)setupPredicate
{
    self.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] $KEY OR cityCode CONTAINS[cd] $KEY OR jianpin CONTAINS[cd] $KEY OR pinyin CONTAINS[cd] $KEY OR adcode CONTAINS[cd] $KEY"];
}


//->>使离线地图生效
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
        if (self.needReloadWhenDisappear)
        {
//            self.mapView = [[MAMapView alloc]init];
//            [self.mapView reloadMap];
    
//            self.needReloadWhenDisappear = NO;
        }
}

//->>清空野指针
- (void)dealloc
{
    free(_expandedSections);
    _expandedSections = NULL;
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}



#pragma mark --- lazy

//!< 分区头部
- (NSMutableArray *)sectionHeaders
{
    if (!_sectionHeaders)
    {
        _sectionHeaders = [NSMutableArray array];
    }
    return _sectionHeaders;
}


//!< 网络状态
- (XMNetState)currentstate
{
    if (!_currentstate)
    {
        _currentstate = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    }
    return _currentstate;
    
}


#pragma mark - UITableViewDataSource

//->>分区的总数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //!< 返回省份的数量（每个省份都是用一个分区来描述的） + 全国概要 + 直辖市 + “全部省市”
    return self.sectionTitles.count + self.provinces.count;
}


//->>每个分区的cell数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    
    switch (section)
    {
        case 0:
        {
            number = 1;//->>第0个分区有一个cell显示概要图
            break;
        }
        case 1:
        {
            number = self.municipalities.count;//->>第一个分区cell显示直辖市
            break;
        }
        default:
        {
            if([self.sections containsObject:@(section)])
            {
                MAOfflineProvince *pro = self.provinces[section - self.sectionTitles.count];
                
                // 加1用以下载整个省份的数据 和对应省份全部市县信息
                number = pro.cities.count + 1;
            }
            break;
        }
    }
    
    return number;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMDownloadCell *cell = [XMDownloadCell dequeueResuableCellWithTableView:tableView];
    
    //!< 取出对用的离线地图对象
    MAOfflineItem *item = [self itemForCellAtIndexPath:indexPath];
    
    //!< 建立item 和 indexPath 映射关系
//    NSArray *keys = self.relationTab.allKeys;
//    if (![keys containsObject:item.adcode])
//    {
//        [self.relationTab setObject:indexPath forKey:item.adcode];
//    }
    
    
    //!< 更新地区的名称
    [cell updateTitleWithItem:item];
    
    
    //!< 设置点击事件的响应
    __weak typeof(self) wSelf = self;
    cell.startDownloadBlock = ^(UIButton *sender,UIEvent *event){
        [wSelf startDownloadWithBtn:sender event:event];
    };
    
     
    //!< 根据当前是否处于下载状态来更新子控件显示的内容
    
    NSMutableDictionary *downloadStages = [XMOfflineMapProgress shareInstance].downloadStages;
    NSMutableArray *downloadItems = [downloadStages objectForKey:@"downloading"];
    
    if([downloadItems containsObject:item])  //!< 处于正在下载状态
    {
   
        
        //!< 取出对应的下载项目的下载信息
        NSMutableDictionary *stage  = [downloadStages objectForKey:item.adcode];
        
        //!< 更新处于正在下载状态的cell 最后一个参数暂时没有用到，随便传
        [cell updateContentWithItem:item infoDictionary:stage contentInDownloading:YES];
        
    }else //!< 没有处于正在下载的状态
    {
        
        //!< 更新cell辅助视图区域子控件的显示与否 （根据item的状态来显示子控件内容）
        [cell updateAccessoryViewWithItem:item];
        
        
    }
    
    
    
    
    
    
    
    
    return cell;
}



//->>分区头部的视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *theTitle = nil;
    
    if (section < self.sectionTitles.count)//->>012分区返回全国，直辖市，省份文字信息
    {
        theTitle = self.sectionTitles[section];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), kSectionHeaderHeight)];
        headerView.backgroundColor = XMColor(239, 239, 239);
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(kSectionHeaderMargin, 0, CGRectGetWidth(headerView.bounds), CGRectGetHeight(headerView.bounds))];
        //        lb.backgroundColor = [UIColor colorWithRed:0.9 green:.9 blue:.9 alpha:1];
        lb.text = theTitle;
        lb.textColor = [UIColor grayColor];
        lb.font = [UIFont systemFontOfSize:13];
        [headerView addSubview:lb];
        
        return headerView;
    }
    else //->>省份信息对应的分区头部视图
    {
        
        //!< section = 3 开始执行 第一个数据下标为0
        if(self.sectionHeaders.count != 0)
        {
            NSUInteger index = section - self.sectionTitles.count;
            if (index < self.sectionHeaders.count)
            {
                return self.sectionHeaders[index];
            }
            
        }
        
        MAOfflineProvince *pro = self.provinces[section - self.sectionTitles.count];
        theTitle = pro.name;
        
        MAHeaderView *headerView = [[MAHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), kTableCellHeight) expanded:_expandedSections[section]];
        
        headerView.section = section;
        headerView.text = theTitle;
        headerView.delegate = self;
        [self.sectionHeaders addObject:headerView];
        return headerView;
    }
}



//->>每个分区头部的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section < self.sectionTitles.count ? kSectionHeaderHeight : kTableCellHeight;
}


/**
 *  对省份离线地图数据进行判断，如果正在下载，就关闭该分区cell点击事件
 *
 *  @param indexPath 下标
 *  @param item      数据
 */
- (void)isDownloadingProvinceMapIndexPath:(NSIndexPath *)indexPath item:(MAOfflineItem *)item
{
    if(item.itemStatus != MAOfflineItemStatusCached)
    {
        return;
    }
    
    NSInteger rows = [_tableView numberOfRowsInSection:indexPath.section];
    for (int i = 1; i < rows; i++)
    {
        XMDownloadCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        [cell turnOffUserInteraction];
    }
    
    
}


/**
 *  点击下载按钮
 *
 *  @param sender 按钮
 *  @param event  点击事件
 */
- (void)startDownloadWithBtn:(UIButton *)sender event:(UIEvent *)event
{
    
    
    //!< 通过点击的点获取在tab中的下标
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![sender pointInside:[touch locationInView:sender] withEvent:event])
    {
        return ;
    }
    CGPoint touchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPosition];
    
    
    MAOfflineItem *item = [self itemForCellAtIndexPath:indexPath];//!< 获取对应地图
    
    
    if (item == nil || item.itemStatus == MAOfflineItemStatusInstalled)//!< 如果点击的那个离线项目，为空或者已经安装好，不做任何操作
    {
        return;
    }
    
    //!< 判断容量是否够用
    CGFloat freeDisk = [self freeDiskSpace];
    
    if (freeDisk < (item.size / GB))
    {
        [MBProgressHUD showError:@"磁盘空间不足!"];
        
        return;
    }
    
    //!< 判断网络情况
    switch (self.currentstate)
    {
        case XMNetState4G:
        {
            self.temItem = item;
            self.temIndexPath = indexPath;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"非WiFi网络下载将消耗较多流量，是否继续下载" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 4;
            [alert show];
            
            
        }
            
            break;
        case XMNetStateNone:
            
            [MBProgressHUD showError:@"网络连接失败"];
            
            break;
        case XMNetStateWIFI:
            
            //!< wifi网络直接下载
            [self startToDownloadItem:item indexPath:indexPath];
            
            break;
            
        default:
            break;
    }
    
    
    
}



- (void)startToDownloadItem:(MAOfflineItem *)item indexPath:(NSIndexPath *)indexPath
{
    
    
    
    //!< 判断是否点击的是省份 如果是省份就用代码下载省份所在区域的，
    if([item isKindOfClass:[MAOfflineProvince class]])
    {
      MAOfflineProvince * province = (MAOfflineProvince*)item;
        //!< 进行判断如果有当前省份的部分城市已经下载，就⚠️用户将会覆盖点数据   没有直接下载
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemStatus = 1 or itemStatus = 2"];
        NSArray *tempArr =  [province.cities filteredArrayUsingPredicate:predicate];
        if (tempArr.count == 0)
        {
            //!< 没有缓存和已完成，直接下载
            [self provinceDownloadItem:item indexPath:indexPath];
        }else
        {
            self.temProvinceItem = item;
            self.temProvinceIndexPath = indexPath;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"全部下载将覆盖原有数据，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            alert.tag = 12;
            [alert show];
        
        }
        
        
        
    }else
    {
        //!< 点击的是普通城市 判断全国基础包是否下载，没有下载就先下载全国基础包
        if(![item isKindOfClass:[MAOfflineItemNationWide class]])
        {
            //!< 下载的不是全国基础包，进行判断
            MAOfflineItemStatus status = [MAOfflineMap sharedOfflineMap].nationWide.itemStatus;
            if (status != MAOfflineItemStatusInstalled)
            {
                //!< 基础包状态不是已完成就下载基础包
                MAOfflineItem *naviItem = [MAOfflineMap sharedOfflineMap].nationWide;
                [self downloadItem:naviItem indexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
        
        
        }
        
        
        //!< 下载数据
        [self downloadItem:item indexPath:indexPath];
        
        
    }
     
    
     
}

#pragma mark --- 如果是省份的话就加警告
- (void)provinceDownloadItem:(MAOfflineItem *)item indexPath:(NSIndexPath *)indexPath
{
    
    //!< 下载的不是全国基础包，进行判断
    MAOfflineItemStatus status = [MAOfflineMap sharedOfflineMap].nationWide.itemStatus;
    if (status != MAOfflineItemStatusInstalled)
    {
        //!< 基础包状态不是已完成就下载基础包
        MAOfflineItem *naviItem = [MAOfflineMap sharedOfflineMap].nationWide;
        [self downloadItem:naviItem indexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    XMDownloadCell *cell_province = [self.tableView cellForRowAtIndexPath:indexPath];
    cell_province.accessoryText = @"缓存中";
    
    //!< 点击的分区号码
    NSInteger section = indexPath.section;
    //!<cell数量
    NSInteger rows = [_tableView numberOfRowsInSection:section];
    
    //!< 循环下载cell对应的地图，下载完毕之后更新省份对应的cell
    for(int i = 1;i < rows;i++)
    {
        
        NSIndexPath *cityIndexPath = [NSIndexPath indexPathForRow:i inSection:section];
        
        //            XMDownloadCell *cell = [_tableView cellForRowAtIndexPath:cityIndexPath];
        //            cell.userInteractionEnabled = NO;
        //          [cell downloadAll];
        
        MAOfflineItem *cityItem = [self itemForCellAtIndexPath:cityIndexPath];//!< 获取对应地图
        [[MAOfflineMap sharedOfflineMap] deleteItem:cityItem];
        //!< 下载数据
        [self downloadItem:cityItem indexPath:cityIndexPath];
        
    }

    
    
}


- (void)downloadItem:(MAOfflineItem *)item indexPath:(NSIndexPath *)indexPath
{
    
    
    //!< 取出对应的cell辅助区域显示文字：等待下载
    XMDownloadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryText = @"等待下载";
    
    //!< 开始下载离线地图，下载回调里边处理相关信息
    [[MAOfflineMap sharedOfflineMap] downloadItem:item shouldContinueWhenAppEntersBackground:YES downloadBlock:^(MAOfflineItem * downloadItem, MAOfflineMapDownloadStatus downloadStatus, id info) {
        
        //!< 下载回调 处于子线程当中
        //!< 存放数据的字典
        NSMutableDictionary *downloadStages = [XMOfflineMapProgress shareInstance].downloadStages;
        //!< 存放下载项目的数组
        NSMutableArray *downloadingItems = [downloadStages objectForKey:@"downloading"];
//        NSMutableArray *caches = [downloadStages objectForKey:@"cache"];
        
        if (![downloadingItems containsObject:downloadItem])
        {
            [downloadingItems addObject:downloadItem]; //!< 将下载的项目添加到数组当中去
            [downloadStages setObject:[NSMutableDictionary dictionary] forKey:downloadItem.adcode];//!< 保存一个键值对
//            [caches addObject:downloadItem];
            //!< 通知下载管理控制器更新第一分区数据
            if(self.delegate && [self.delegate respondsToSelector:@selector(downloadViewController:willBeginDownloadItem:)])
            {
                
                [self.delegate downloadViewController:self willBeginDownloadItem:item];
                
            }

        }
        
        
        NSMutableDictionary *stage  = [downloadStages objectForKey:downloadItem.adcode];//!< 取出存放的对应数据的字典
        
        //!< 设置当前下载状态
        [stage setObject:[NSNumber numberWithInteger:downloadStatus] forKey:DownloadStageIsRunningKey2];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (downloadStatus)
            {
                case MAOfflineMapDownloadStatusWaiting: //!< 等待中
                    
                    [self updateUIForItem:downloadItem atIndexPath:indexPath];
                    
                    break;
                    
                case MAOfflineMapDownloadStatusStart: //!< 开始下载
                    [self updateUIForItem:downloadItem atIndexPath:indexPath];
                    
                    break;
                    
                case MAOfflineMapDownloadStatusProgress: //!< 正在下载
                    
                    //!< 设置键值  对应正在下载时候的信息
                    [stage setObject:info forKey:DownloadStageInfoKey2];
                    [self updateUIForItem:downloadItem atIndexPath:indexPath];
                    
                    if(self.delegate && [self.delegate respondsToSelector:@selector(downloadViewController:didUpdateInfoForItem:)])
                    {
                        
                        [self.delegate downloadViewController:self didUpdateInfoForItem:item];
                        
                    }
                    
                    
                    break;
                    
                case MAOfflineMapDownloadStatusCompleted: //!< 下载完成
                    
                    [self updateUIForItem:downloadItem atIndexPath:indexPath];
                    
                    break;
                    
                case MAOfflineMapDownloadStatusCancelled: //!< 下载取消
                    
                    [self updateUIForItem:downloadItem atIndexPath:indexPath];
                    
                    if(self.delegate && [self.delegate respondsToSelector:@selector(downloadViewController:didUpdateInfoForItem:)])
                    {
                        //!< 下载取消通知代理更新
                        [self.delegate downloadViewController:self didUpdateInfoForItem:item];
                        
                    }
                    // clear  可能会存在恢复下载
                    //                [self.downloadingItems removeObject:downloadItem];//!< 从集合中移除
                    //                [self.downloadStages removeObjectForKey:downloadItem.adcode];//!< 从字典中移除
                    
                    break;
                    
                case MAOfflineMapDownloadStatusUnzip: //!< 正在解压缩
                    [self updateUIForItem:downloadItem atIndexPath:indexPath];
                    
                    break;
                    
                case MAOfflineMapDownloadStatusFinished: //!< 全部顺利完成
                    
                {
                    [self updateUIForItem:downloadItem atIndexPath:indexPath];
                    
                    NSMutableArray *arrayM = [NSMutableArray arrayWithContentsOfFile:XIAOMI_offlineMapfinishedPath];
//                    XMLOG(@"%@",XIAOMI_offlineMapfinishedPath);
                    if (arrayM == nil)
                    {
                        arrayM = [NSMutableArray array];
                    }
                   
                    //!< 进行判断，数组中是否有当前离线项目名称，没有添加，有就不执行操作
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self = %@",item.name];
                    NSArray *arr = [arrayM filteredArrayUsingPredicate:predicate];
                    if (arr.count == 0)
                    {
                         [arrayM addObject:item.name];
                        [arrayM writeToFile:XIAOMI_offlineMapfinishedPath atomically:YES];
                    }
                    
                    // clear
                    
                    
                    //!< 从数组中移除
                    if(self.delegate && [self.delegate respondsToSelector:@selector(downloadViewController:willFinishDownloadItem:)])
                    {
                        
                        [self.delegate downloadViewController:self willFinishDownloadItem:item];
                        
                    }
                    
                    NSMutableDictionary *downloadStages = [XMOfflineMapProgress shareInstance].downloadStages;
                    NSMutableArray *downloadItems = [downloadStages objectForKey:@"downloading"];
                    
                    //!< 从正在下载的数组中移除
                    
                    if([downloadItems containsObject:downloadItem])
                    {
                    
                        [downloadItems removeObject:downloadItem];//!< 从集合中移除
                    }
                    [downloadStages removeObjectForKey:downloadItem.adcode];//!< 从字典中移除
                    
//                    //!< 添加到下载完成的数组当中
//                    NSMutableArray *finishArray = [downloadStages objectForKey:@"finish"];
//                    
//                    [finishArray addObject:downloadItem];
                    
                   
                    
                    
                    
                    //!< 每次下载完一个项目，判断所在省份是否处于完成状态 更新辅助区域文字
                    if (indexPath.section >2) //!< 过滤012分区
                    {
                        
                        NSIndexPath *provinceIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                        MAOfflineItem *item = [self itemForCellAtIndexPath:provinceIndexPath];
//                        NSString *accessoryTitle = nil;
                        if(item.itemStatus == MAOfflineItemStatusInstalled)
                        {
//                            accessoryTitle = @"已安装";
                            
                        }
 
                        
                    }
                    
                }
                    break;
                    
                case MAOfflineMapDownloadStatusError:  //!< 下载出现错误
                    
                {
                
                    [self updateUIForItem:downloadItem atIndexPath:indexPath];
                    if(self.delegate && [self.delegate respondsToSelector:@selector(downloadViewController:didUpdateInfoForItem:)])
                    {
                        
                        [self.delegate downloadViewController:self didUpdateInfoForItem:item];
                        
                    }
                     
                }
  
                    break;
                    
                default:
                    break;
            }
            
            
        

            
        });
        if (downloadStatus == MAOfflineMapDownloadStatusFinished)
        {
            self.needReloadWhenDisappear = YES;
        }
    }];
    
    
    
}


- (void)downloadItem:(MAOfflineItem *)item
{
 
    NSIndexPath *indexPath = [self  indexPathForItem:item];
    if (indexPath == nil)
        return;
    [self downloadItem:item indexPath:indexPath];

}


/**
 *    根据indexPath取出对应离线地图项
 */
- (MAOfflineItem *)itemForCellAtIndexPath:(NSIndexPath *)indexPath
{
    MAOfflineItem *item = nil;
    switch (indexPath.section)
    {
        case 0:
            
            //!< 返回全国基础包
            item = [MAOfflineMap sharedOfflineMap].nationWide;
            break;
            
        case 1:
            
            //!< 直辖市和特别行政区
            item = self.municipalities[indexPath.row];
            
            break;
        case 2:
            
            //!< 显示全部省市文字，没有对应地图
            break;
            
        default:
            
        {
            
            //!< 返回对应省份的地图
            MAOfflineProvince *province = self.provinces[indexPath.section - self.sectionTitles.count];
            if (indexPath.row == 0) {
                item = province;
            }else
            {
                item = province.cities[indexPath.row - 1];
            }
            
        }
            
            
            break;
    }
    
    return item;
}

#pragma mark --- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAOfflineItem *item = [self itemForCellAtIndexPath:indexPath];
    
    
    if ([item isKindOfClass:[MAOfflineProvince class]])
    {
        //!< 点击省份地图   直接返回
        return;
    }

    
    //!< 判断是否正在下载
    if([[MAOfflineMap sharedOfflineMap] isDownloadingForItem:item])
    {
        //!< 如果点击正在下载
        //!< 跳转到上一个控制器
        XMSet_offLineMapViewController *vc = (XMSet_offLineMapViewController *)self.tabBarController;
        [vc jumpToDownloadViewController];
        
        //!< 通知代理修改tableview偏移量
        if(self.delegate && [self.delegate respondsToSelector:@selector(downloadViewController:didClickDownloadingItem:)])
        {
            [self.delegate downloadViewController:self didClickDownloadingItem:item];
            
        }
    }else
    {
        //!< 不是正在下载
        //!< 如果点击已完成，根据名称通知代理显示
        if (item.itemStatus == MAOfflineItemStatusInstalled)
        {
            //!< 跳转到上一个控制器
            XMSet_offLineMapViewController *vc = (XMSet_offLineMapViewController *)self.tabBarController;
            [vc jumpToDownloadViewController];
            
            //!< 通知代理修改tableview偏移量
            if(self.delegate && [self.delegate respondsToSelector:@selector(downloadViewController:didClickFinishedItem:)])
            {
                [self.delegate downloadViewController:self didClickFinishedItem:item];
                
            }
            
        }else
        {
            //!< 下载失败情况
        
            XMSet_offLineMapViewController *vc = (XMSet_offLineMapViewController *)self.tabBarController;
            [vc jumpToDownloadViewController];
            
            //!< 通知代理修改tableview偏移量
            if(self.delegate && [self.delegate respondsToSelector:@selector(downloadViewController:didClickDownloadingItem:)])
            {
                [self.delegate downloadViewController:self didClickDownloadingItem:item];
                
            }
        }
    
    
    }
    
    
    
    
    




}


////!< 滚动时候缩回键盘
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    [self.view endEditing:YES];
//    
//}





#pragma mark - Utility




//!< 更新对应下标的离线地图数据
- (void)updateUIForItem:(MAOfflineItem *)item atIndexPath:(NSIndexPath *)indexPath
{
    
    XMDownloadCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        
        //        [self updateCell:cell forItem:item];  //!< 更新cell内容
        NSMutableDictionary *downloadStages = [XMOfflineMapProgress shareInstance].downloadStages;
        NSMutableDictionary *stage  = [downloadStages objectForKey:item.adcode];
        [cell updateContentWithItem:item infoDictionary:stage contentInDownloading:NO];
        
    }
    
    
    
}


#pragma mark --- 根据itemcode 判断属于哪个省 返回下标

- (NSIndexPath *)indexPathForItem:(MAOfflineItem *)item
{
    NSIndexPath *indexPath = nil;

    if ([item isKindOfClass:[MAOfflineItemNationWide class]])
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }else if ([item isKindOfClass:[MAOfflineItemMunicipality class]])
    {
        
        NSInteger index = 0;
        
        
        for(int j = 0;j<self.municipalities.count;j++)
        {
        
            MAOfflineItem *itemM = self.municipalities[j];
            if (![item.adcode isEqualToString:itemM.adcode])
            {
                continue;
            }
            index = j;
            break;
        
        }
        indexPath = [NSIndexPath indexPathForRow:index inSection:1];
        
        
    }else if ([item isKindOfClass:[MAOfflineItemCommonCity class]])
    {
        
        NSInteger section = 0,index = 0;
        BOOL mark = NO;
        
        for (int i = 0; i < self.provinces.count; i++)
        {
           

            MAOfflineProvince *province = self.provinces[i];
            for(int k = 0;k < province.cities.count;k++)
            {
                MAOfflineCity *city = province.cities[k];
                if (![city.adcode isEqualToString:item.adcode]) {
                    continue;
                }else
                {
                    section = i + 3;
                    index = k + 1;//!< 第一行有省份信息
                    mark = YES;//!< 跳出外层循环
                    break;//!< 跳出内层循环
                }
            
            }
            if (mark)
            {
                break;
            }
            
        }
        
        
        indexPath = [NSIndexPath indexPathForRow:index inSection:section];
    }









    return indexPath;

}





#pragma mark - MAHeaderViewDelegate

- (void)headerView:(MAHeaderView *)headerView section:(NSInteger)section expanded:(BOOL)expanded
{
    if ([_sections containsObject:@(section)])
    {
        //!< 已经打开，执行关闭
        
        NSInteger rows = [self tableView:_tableView numberOfRowsInSection:section];//!< rwo数量
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i = 0; i < rows; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            [indexPaths addObject:indexPath];
        }
        
        //!< 从数组中删除标记
        [_sections removeObject:@(section)];
        
        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        
        
        
        
        
        
    }else
    {
        //!< 没有打开，打开
        [_sections addObject:@(section)]; //!< 下标添加进属组
        NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:section];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i = 0; i < rows; i++)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            [indexPaths addObject:indexPath];
        }
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
    
    
}



////!< 搜索操作
//- (void)searchAction
//{
//    /* 搜索关键字支持 {城市中文名称, 拼音(不区分大小写), 拼音简写, cityCode, adCode}五种类型. */
//    NSString *key = @"西";
//
//    NSArray *result = [self citiesFilterWithKey:key];
//
//    NSLog(@"key = %@, result count = %d", key, (int)result.count);
//    [result enumerateObjectsUsingBlock:^(MAOfflineCity *obj, NSUInteger idx, BOOL *stop) {
//        NSLog(@"idx = %d, cityName = %@, cityCode = %@, adCode = %@, pinyin = %@, jianpin = %@, size = %lld", (int)idx, obj.name, obj.cityCode,obj.adcode, obj.pinyin, obj.jianpin, obj.size);
//    }];
//
//
//}



#pragma mark --- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 4 && buttonIndex == 1)
    {
        //!<准备下载
        [self startToDownloadItem:_temItem indexPath:_temIndexPath];
        
    }
    
    if (alertView.tag == 12)
    {
        //!< 下载省份数据有部分城市已经下载进行警告
        if (buttonIndex == 1)
        {
            //!< 点击继续 开始下载
            [self provinceDownloadItem:self.temProvinceItem indexPath:self.temProvinceIndexPath];
            
        }
        
        
    }
    
    
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
    return [[fattributes objectForKey:NSFileSystemFreeSize] longLongValue] / GB;  //!< GB
}




@end

//->>分类的实现
@implementation XMDownLoadViewController (SearchCity)

/* Returns a new array consisted of MAOfflineCity object for which match the key. */
- (NSArray *)citiesFilterWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return nil;
    }
    
    NSPredicate *keyPredicate = [self.predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:key forKey:@"KEY"]];
    
    return [self.cities filteredArrayUsingPredicate:keyPredicate];
}

@end
