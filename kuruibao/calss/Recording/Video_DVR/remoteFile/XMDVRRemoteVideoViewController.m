//
//  XMDVRLocalVideoViewController.m
//  GKDVR
//
//  Created by x on 16/10/28.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMDVRRemoteVideoViewController.h"
#import "AFNetworking.h"
#import "XMVideoModel.h"
#import "MJRefresh.h"
#import "XMLDictionary.h"
#import "XMDVRProgressView.h"
#import "KxMovieViewController.h"
#import "XMDVRImageViewController.h"



//!< 视频存放文件夹
#define directoryPath_VIDEO [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/DVR/VIDEO"]

@interface XMDVRRemoteVideoViewController ()<UICollectionViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (strong, nonatomic) NSURLSessionDownloadTask *task;

@property (nonatomic,weak)XMDVRProgressView* progressView;

@property (copy, nonatomic) NSString *videoName;



@end

@implementation XMDVRRemoteVideoViewController

#pragma mark --- life cycle



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
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath_VIDEO isDirectory:&isExist])
    {
        
        //!< create directory
        
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath_VIDEO withIntermediateDirectories:YES attributes:nil error:nil];
        
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
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"远程视频选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"在线播放",@"下载",@"删除",@"加锁", nil];
    
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
            
            //!< delete
            
            [self deleteVideo];
            
            
            break;
        case 3:
            
            //!< lock
            
            [self lockVideo];
            
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
    
    
    NSString *urlStr = [DVRHost stringByAppendingFormat:@"type=file&action=searchfile&index=%ld",[self getIndex]];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        
        [self parseDictionary:dic];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.collectionView.mj_header endRefreshing];
        
        [MBProgressHUD showError:@"请求超时"];
        
        
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
        [MBProgressHUD showError:@"没有获取到更多信息"];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.collectionView reloadData];
    });
    
    
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
//    //!<  use rtsp player to play imageb
//    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:videoPath parameters:nil];
//    
//    [self presentViewController:vc animated:YES completion:nil];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
    KxMovieViewController *playerViewController =[KxMovieViewController movieViewControllerWithContentPath:
                                                  [NSString stringWithFormat:@"http://192.168.63.9/sdcard/DVR/VIDEO/%@",fileName] parameters:parameters];
    [self presentViewController:playerViewController animated:YES completion:nil];

    
}

- (void)downloadVideo
{
    //http://192.168.63.9/sdcard/DVR/VIDEO/20161028204858.mkv
     
    NSString *fileName = [self getFileNameAtIndexPath:self.indexPath];
    
    NSString *videoPath = [directoryPath_VIDEO stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath])
    {
        [MBProgressHUD showError:@"文件已下载"];
        
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    
    hud.width = hud.height;
    
    
    XMDVRImageViewController *vc =  (XMDVRImageViewController *)self.parentViewController;
    
    [vc showCancelBtn];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.63.9/sdcard/DVR/VIDEO/%@",fileName];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        double pro = downloadProgress.completedUnitCount * 1.0 /downloadProgress.totalUnitCount;
        
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
           hud.labelText = [NSString stringWithFormat:@"  %d%%     ",(int)(pro * 100)];
            
            
        });
        
        
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:[directoryPath_VIDEO stringByAppendingPathComponent:response.suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
      
        
        if (!error)
        {
              [vc showCancelBtn];
            [MBProgressHUD showSuccess:@"下载成功"];
            
        }else
        {
//            [MBProgressHUD showError:@"下载失败"];
        
        }
        
    }];
    
    [task resume];
    
    self.task = task;
    
}

- (void)deleteVideo
{
    //http://192.168.63.9/cgi-bin/Control.cgi?type=file&action=deletefile&name=20161028204812
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *fileName = [self getFileNameAtIndexPath:self.indexPath];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=file&action=deletefile&name=%@",fileName];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        NSString *result = [NSString stringWithCString:[responseObject bytes] encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:result];
        
        if ([dic[@"Result"] isEqualToString:@"OK"])
        {
            
            NSString *key = self.sectionTitles[self.indexPath.section];
            
            NSMutableArray *videos = [self.dataDictionary objectForKey:key];
            
            [videos removeObject:fileName];
            
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.indexPath.section]];
            
            
            
            
            
            [MBProgressHUD showSuccess:@"删除成功"];
            
        }else
        {
            
            [MBProgressHUD showError:@"请求超时，请稍后再试"];
            
            
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"请求超时，请稍后再试"];
    }];
    
    
    
}

- (void)lockVideo
{
    //!< http://192.168.63.9/cgi-bin/Control.cgi?type=file&action=lockfile&name=20161028204312.mkv
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *fileName = [self getFileNameAtIndexPath:self.indexPath];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=file&action=lockfile&name=%@",fileName];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        
            NSString *key = self.sectionTitles[self.indexPath.section];
            
            NSMutableArray *videos = [self.dataDictionary objectForKey:key];
            
            [videos removeObject:fileName];
            
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.indexPath.section]];
            
            [MBProgressHUD showSuccess:@"加锁成功"];
            
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"请求超时，请稍后再试"];
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
