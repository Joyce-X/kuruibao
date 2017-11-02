//
//  XMDVRLocalImageViewController.m
//  GKDVR
//
//  Created by x on 16/10/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:  show remote image 显示记录以上的照片
 
 **********************************************************/

#import "XMDVRRemoteImageViewController.h"
#import "XMDVRImageModel.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "XMDVRShowImageViewController.h"


//!< 本地图片存储地址
#define directoryPath_IMAGE [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/DVR/PIC"]

@interface XMDVRRemoteImageViewController ()<UICollectionViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *session;

@end


@implementation XMDVRRemoteImageViewController

#pragma mark --- life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupSubviews];
    
 }

- (void)setupSubviews
{
    __weak typeof(self) wSelf = self;
    
    
    
    //!< 刷新尾部分，在20条数据的基础上向后递增20
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
       
        [wSelf requestImageDataWithIndex:0];

     }];
    
    [self.collectionView.mj_footer beginRefreshing];
   
    //!< init
    //!< 标题数组
    self.sectionTitles = [NSMutableArray array];
    
    //!< 数据源信息
    self.dataDictionary = [NSMutableDictionary dictionary];
    
    
}

+ (void)initialize
{
    
    //!< 类加载的时候，判断文件夹是否存在，如果不存在的话就进行创建
    //!< 文件夹路径
    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/DVR/PIC"];
    
    //!< 判断文件夹是否存在，不存在就创建
    BOOL res;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&res])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }



}

#pragma mark --- UICollectionViewDelegate

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMDVR_LocalImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.timeLabel.text = [self getCreateTimeWithFileName:[self getFileNameAtIndexPath:indexPath]];
    
    cell.imageView.image = [UIImage imageNamed:@"DVR_defauleImage"];
    
    return cell;
    
 
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
//    !< pass the imageName to the controller will be presented
    

    self.indexPath = indexPath;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"远程图片选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"预览",@"下载",@"删除", nil];

    [sheet showInView:self.collectionView];

}


#pragma mark --- lazy

-(AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        _session.requestSerializer.timeoutInterval = 12;
    }
    
 
    
    return _session;
    
}


#pragma mark --- load new data

- (void)requestImageDataWithIndex:(NSInteger)index
{
    //!< get all images
    
    index = [self getIndex];
    
    NSString *urlStr = [DVRHost stringByAppendingFormat:@"type=image&action=searchimg&index=%ld",index];
    
//    (unsigned long)self.sectionTitles.count = index;
   
    NSLog(@"%@",urlStr);
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
         [self parseDictionary:dic];
        
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
         [self.collectionView.mj_header endRefreshing];
        
        
    }];
    
}


//!< 请求到数据 开始解析数据

- (void)parseDictionary:(NSDictionary *)dic
{
    
    if (dic == nil)return;
    
    [self.collectionView.mj_footer endRefreshing];
    
    //!< 对数据进行分组，按照时间进行分组
    
    //!< 存放所有数据
//    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    NSArray *images = dic[@"preimage"];
    
    if (images.count == 0)
    {
        [MBProgressHUD showError:@"没有更多数据了"];
        
        return;
    }
    
    for (NSDictionary *imageDic in images)
    {
        
        NSString *imageName = imageDic[@"imagetitle"];
        
        NSString *key = [imageName substringToIndex:8];
        
        NSMutableArray *arrM = [self.dataDictionary objectForKey:key];
        
        if (arrM)
        {
            //!< 存在，把文件加入数组
            
            [arrM addObject:imageName];
            
        }else
        {
            //!< 不存在，创建后，把文件加入数组
            
            arrM = [NSMutableArray array];
            
            [arrM addObject:imageName];
            
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
    
   

    
}

#pragma mark --- UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    switch (buttonIndex)
    {
        case 0:
            
            [self preViewDidClick];
            
            break;
            
        case 1:
            
            [self downloadDidClick];
            
            break;
            
        case 2:
            
            [self deleteDidClick];
            
            break;
            
        default:
            break;
    }



}

- (void)preViewDidClick
{
        XMDVRShowImageViewController *showImageVC = [XMDVRShowImageViewController new];
    
        showImageVC.imageName = [self getFileNameAtIndexPath:self.indexPath];
    
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:showImageVC];
    
    
        [self presentViewController:navi animated:YES completion:nil];

    
    
}

- (void)downloadDidClick
{
    
    //!< http://192.168.63.9/sdcard/DVR/PIC/xxxxx.jpg
    
    NSString *fileName = [self getFileNameAtIndexPath:self.indexPath];
    
    //!< 文件路径
    NSString *imageFilePath = [directoryPath_IMAGE stringByAppendingPathComponent:fileName];
    
    //!< 判断文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath])
    {
        
         //!< 存在就显示已经下载
        [MBProgressHUD showSuccess:@"文件已下载"];
        
        return;
    }
    
    
    
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.63.9/sdcard/DVR/PIC/%@",fileName]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:[NSURLRequest requestWithURL:url] progress:^(NSProgress * _Nonnull downloadProgress) {
        
        
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *path = [directoryPath_IMAGE stringByAppendingPathComponent:response.suggestedFilename];
        
        return [NSURL fileURLWithPath:path];
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        if (!error)
        {
            
            [MBProgressHUD showSuccess:@"下载成功"];
            
            
            
        }else
        {
            [MBProgressHUD showError:@"下载失败"];
            
        }
        
    }];
    
    [task resume];
    
}

- (void)deleteDidClick
{
   
    //http://192.168.63.9/cgi-bin/Control.cgi?type=image&action=deleteimg&name=20161105142253.jpg
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *fileName = [self getFileNameAtIndexPath:self.indexPath];
    
    NSString *urlStr = [@"http://192.168.63.9/cgi-bin/Control.cgi?type=image&action=deleteimg&name=" stringByAppendingString:fileName];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        NSString *key = self.sectionTitles[self.indexPath.section];
        
        NSMutableArray *images = [self.dataDictionary objectForKey:key];
        
        [images removeObject:fileName];
        
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.indexPath.section]];
        
        [MBProgressHUD showSuccess:@"删除成功"];
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showError:@"操作超时"];
        
    }];
    
   
    
} 

@end
