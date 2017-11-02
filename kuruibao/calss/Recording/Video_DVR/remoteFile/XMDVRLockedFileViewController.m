//
//  XMDVRLockViewController.m
//  GKDVR
//
//  Created by x on 16/10/27.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMDVRLockedFileViewController.h"
#import "MJRefresh.h"
#import "XMVideoModel.h"
#import "AFNetworking.h"
#import "XMDVRProgressView.h"
#import "XMLDictionary.h"
#import "KxMovieViewController.h"
#import "XMDVRImageViewController.h"



//!< 视频存放文件夹
#define directoryPath_EVENT [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/DVR/EVENT"]

@interface XMDVRLockedFileViewController ()<UICollectionViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (strong, nonatomic) NSURLSessionDownloadTask *task;

@property (nonatomic,weak)XMDVRProgressView* progressView;

@end

@implementation XMDVRLockedFileViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupSubViews];
    
}

- (void)setupSubViews
{
    __weak typeof(self) wSelf = self;
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        [wSelf requestVideoData];
        
    }];
    
    
    [self.collectionView.mj_footer beginRefreshing];
        
    
    self.sectionTitles = [NSMutableArray array];
    self.dataDictionary = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelDownloadBtnDidClick) name:kXMDVRImageViewControllerCancelBtnClickNotification object:nil];

    
}

+(void)initialize
{
    //!< judge directory whether exist
    
    BOOL isExist;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath_EVENT isDirectory:&isExist])
    {
        
        //!< create directory
        
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath_EVENT withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    
    
}

#pragma mark --- UICollectionViewDelegate

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMDVR_LocalImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.timeLabel.text = [self getCreateTimeWithFileName:[self getFileNameAtIndexPath:indexPath]];
    
    cell.imageView.image = [UIImage imageNamed:@"DVR_defauleVideo"];
    
    return cell;
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.indexPath = indexPath;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"远程视频选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"在线播放",@"下载",@"解锁", nil];
    
    [sheet showInView:self.collectionView];
}

#pragma mark --- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            [self playVideo];
            
            break;
            
        case 1:
            
            //!< download
            
            [self downloadVideo];
            
            
            break;
            
        case 2:
            
            //!< lock
            
            [self unLockVideo];
            
            break;
            
            
        default://!< cancel
            
            
            
            break;
    }
    
    
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

- (void)requestVideoData
{
    //!< get all images
    
       
    NSString *urlStr = [DVRHost stringByAppendingFormat:@"type=file&action=searchevent&index=%ld",[self getIndex]];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        
        [self parseDictionary:dic];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.collectionView.mj_header endRefreshing];
        
        [MBProgressHUD showError:@"网络错误"];
        
        
    }];
    
}

//!< 请求到数据 开始解析数据

- (void)parseDictionary:(NSDictionary *)dic
{
    
    if (dic == nil)return;
    
    [self.collectionView.mj_footer endRefreshing];
    
    //!< 对数据进行分组，按照时间进行分组
    
    //!< 存放所有数据
    
    NSArray *videos = dic[@"prevideo"];
    
    if (videos.count == 0)
    {
        [MBProgressHUD showError:@"没有更多信息"];
        return;
    }
    
    for (NSDictionary *videoDic in videos)
    {
        
        NSString *videoName = videoDic[@"videotitle"];
        
        NSString *key = [videoName substringToIndex:8];
        
        NSMutableArray *arrM = [self.dataDictionary objectForKey:key];
        
        if (arrM)
        {
            //!< 存在，把文件加入数组
            
            [arrM addObject:videoName];
            
        }else
        {
            //!< 不存在，创建后，把文件加入数组
            
            arrM = [NSMutableArray array];
            
            [arrM addObject:videoName];
            
            [self.dataDictionary setObject:arrM forKey:key];
            
        }
        
    }
    
    
    
    self.sectionTitles = [[self.dataDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        if ([obj1 integerValue] < [obj2 integerValue])
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedAscending;
        }
    }];
    
    
    
    [self.collectionView reloadData];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        self.collectionView.mj_footer =  [MJRefreshAutoNormalFooter
                                          footerWithRefreshingBlock:^{
                                              [self requestVideoData];
                                              
                                          }];
    });
    
    
}


#pragma mark --- operate video

- (void)playVideo
{
    
    NSString *fileName = [self getFileNameAtIndexPath:self.indexPath];
    
//    NSString *videoPath = [@"rtsp://192.168.63.9:554/playback/udp/file" stringByAppendingString:fileName];
//    
//    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:videoPath parameters:nil];
//    
//    [self presentViewController:vc animated:YES completion:nil];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
        
    
    KxMovieViewController *playerViewController =[KxMovieViewController movieViewControllerWithContentPath:
                                                  [NSString stringWithFormat:@"http://192.168.63.9/sdcard/DVR/EVENT/%@",fileName] parameters:parameters];
    [self presentViewController:playerViewController animated:YES completion:nil];
    
}

- (void)downloadVideo
{
    
    NSString *fileName = [self getFileNameAtIndexPath:self.indexPath];
    
    NSString *videoPath = [directoryPath_EVENT stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath])
    {
        [MBProgressHUD showError:@"文件已下载"];
        
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    
    
    XMDVRImageViewController *vc =  (XMDVRImageViewController *)self.parentViewController;
    
    [vc showCancelBtn];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.63.9/sdcard/DVR/EVENT/%@",fileName];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        double pro = downloadProgress.completedUnitCount * 1.0 /downloadProgress.totalUnitCount;
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            hud.labelText = [NSString stringWithFormat:@"  %d%%     ",(int)(pro * 100)];
            
            
        });
        
        
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:[directoryPath_EVENT stringByAppendingPathComponent:response.suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
       
        
        if (!error)
        {
             [vc showCancelBtn];
            [MBProgressHUD showSuccess:@"下载成功"];
            
        }else
        {
            //
            
        }
        
    }];
    
    [task resume];
    
    self.task = task;
    
}



- (void)unLockVideo
{
    //!< http://192.168.63.9/cgi-bin/Control.cgi?type=file&action=unlockfile&name=20161104184112.mkv
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *fileName = [self getFileNameAtIndexPath:self.indexPath];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=file&action=unlockfile&name=%@",fileName];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        
        NSString *key = self.sectionTitles[self.indexPath.section];
        
        NSMutableArray *videos = [self.dataDictionary objectForKey:key];
        
        [videos removeObject:fileName];
        
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.indexPath.section]];
        
        [MBProgressHUD showSuccess:@"解锁成功"];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"请求超时"];
    }];
}


#pragma mark --- monitor notification

- (void)cancelDownloadBtnDidClick
{
    [MBProgressHUD hideHUDForView:self.view];
    
    if (self.task)
    {
        [self.task cancel];
        
        self.task = nil;
    }
    
    
}




- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     
}



@end
