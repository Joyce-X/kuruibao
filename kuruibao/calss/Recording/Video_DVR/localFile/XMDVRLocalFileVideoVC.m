//
//  XMLocalFileVideoVC.m
//  GKDVR
//
//  Created by x on 16/10/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/**********************************************************
 class description:
 
        展示本地视频列表
 
 **********************************************************/

#import "XMDVRLocalFileVideoVC.h"

#import "XMDVR_LocalImageCell.h"
#import "XMDVR_LocalImage_collectionRuseView.h"
#import <AVFoundation/AVFoundation.h>
#import "KxMovieViewController.h"



//!< 视频存放文件夹
#define directoryPath_VIDEO [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/DVR/VIDEO"]


#define identifier @"localVideo_reuseIdentifier"

@interface XMDVRLocalFileVideoVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate>


@property (nonatomic,weak)UICollectionView* collectionView;

@property (strong, nonatomic) NSMutableDictionary *dataDictionary;//!< 数据源

@property (strong, nonatomic) NSArray *sectionTitles;//!< 分区标题

@property (strong, nonatomic) NSIndexPath *indexPath;//!< 点击下标

//@property (copy, nonatomic) NSString *videoName;

@end


@implementation XMDVRLocalFileVideoVC


#pragma mark --- life cycle

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    [self setupInit];
    
   
}


- (void)setupInit
{
    
    
    //!< 日期进行排序显示
    
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
    
    
    //!< layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    layout.itemSize = CGSizeMake(59, 48 + 25);
    
    layout.sectionInset = UIEdgeInsetsMake(10, 15, 12, 15);
    
    layout.minimumLineSpacing = 8;
    
    layout.minimumInteritemSpacing = 12;
    
    layout.headerReferenceSize = CGSizeMake(mainSize.width, 30);
    
    
    //!< collection
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    
    
    collectionView.delegate = self;
    
    collectionView.dataSource = self;
    
    collectionView.backgroundColor = [UIColor whiteColor];
    
    collectionView.alwaysBounceVertical = YES;
    
    [collectionView registerClass:[XMDVR_LocalImageCell class] forCellWithReuseIdentifier:identifier];
    
    [collectionView registerClass:[XMDVR_LocalImage_collectionRuseView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifier];
    
    [self.view addSubview:collectionView];
    
    self.collectionView = collectionView;
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view);
        
        make.left.equalTo(self.view);
        
        make.right.equalTo(self.view);
        
        make.bottom.equalTo(self.view);
        
    }];
    
    
    
    
}

#pragma mark --- lazy

-(NSMutableDictionary *)dataDictionary
{
    //!< key 为当天时间  value 为当天时间的所有视频文件
     if (!_dataDictionary)
    {
        
        //!< 过滤掉所有不是视频的文件
        NSArray * subPaths = [[NSFileManager defaultManager] subpathsAtPath:directoryPath_VIDEO];
        
        if (subPaths.count == 0)return nil;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS 'mkv'"];
        
        subPaths = [subPaths filteredArrayUsingPredicate:predicate];
        
        //!< 对数据进行分组，按照时间进行分组
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        for (NSString *fileName in subPaths) {
            
            
            NSString *key = [fileName substringToIndex:8];
            
            NSMutableArray *arrM = [dic objectForKey:key];
            
            if (arrM)
            {
                //!< 存在，把文件加入数组
                
                [arrM addObject:fileName];
                
            }else
            {
                //!< 不存在，创建后，把文件加入数组
                
                arrM = [NSMutableArray array];
                
                [arrM addObject:fileName];
                
                [dic setObject:arrM forKey:key];
                
            }
            
        }
        
        
        _dataDictionary = dic;
        
    }
    
    return _dataDictionary;
    
}


#pragma mark --- UITableViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sectionTitles.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    NSString *key = self.sectionTitles[section];
    
    NSArray *value = [self.dataDictionary objectForKey:key];
    
    return value.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMDVR_LocalImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    
    NSString *fileName = [self getFileNameAtIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:@"DVR_defauleVideo"];
    
    cell.timeLabel.text =  [self getCreateTimeWithFileName:fileName];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    XMDVR_LocalImage_collectionRuseView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
//        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifier forIndexPath:indexPath];
        
        NSString *fileDate = [self.sectionTitles objectAtIndex:indexPath.section];
        
        NSString *year = [fileDate substringToIndex:4];
        
        NSString *month = [fileDate substringWithRange:NSMakeRange(4, 2)];
        
        NSString *day = [fileDate substringWithRange:NSMakeRange(6, 2)];
        
        
        reusableView.time_title = [NSString stringWithFormat:@"%@.%@.%@",year,month,day];
        
    }
    
    return reusableView;
}


#pragma mark --- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.indexPath = indexPath;
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"本地视频选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"播放",@"删除",@"全部删除", nil];
    
    [sheet showInView:self.view];
    
    
}


#pragma mark --- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            //!< 播放
            [self playVideo];
            
            break;
            
        case 1:
            
            //!< 删除
            [self deleteDidClick];
            
            break;
            
        case 2:
            
            //!< 全部删除
            [self deleteAllDidClick];
            
            break;
            
            
        default:
            //!< 点击取消
            break;
    }
    
    
    
}



- (NSString *)getFileNameAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.sectionTitles[indexPath.section];
    
    NSArray *value = self.dataDictionary[key];
    
    return value[indexPath.item];
    
    
}




- (NSString *)getCreateTimeWithFileName:(NSString *)fileName
{
    //    @"2016 11 04 12 09 12";
    
    NSString *hour = [fileName substringWithRange:NSMakeRange(8, 2)];
    
    NSString *minute = [fileName substringWithRange:NSMakeRange(10, 2)];
    
    NSString *second = [fileName substringWithRange:NSMakeRange(12, 2)];
    
    return [NSString stringWithFormat:@"%@:%@:%@",hour,minute,second];
    
}

#pragma mark --- sheet click action

- (void)playVideo
{
    
    NSString *fileName = [self getFileNameAtIndexPath:self.indexPath];
    
    NSString *filePath = [directoryPath_VIDEO stringByAppendingPathComponent:fileName];
    
//    KxMovieViewController *playVc = [KxMovieViewController movieViewControllerWithContentPath:filePath parameters:nil];
//    
//    [self presentViewController:playVc animated:YES completion:nil];
   
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//            parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
        
        KxMovieViewController *playerViewController =[KxMovieViewController movieViewControllerWithContentPath:
                                                      filePath parameters:parameters];
        [self presentViewController:playerViewController animated:YES completion:nil];
    
    
}

- (void)deleteDidClick
{
    NSString *key = self.sectionTitles[_indexPath.section];
    
    NSMutableArray *videos = _dataDictionary[key];
    
    NSString *fileName = [self getFileNameAtIndexPath:_indexPath];
    
    [videos removeObject:fileName];
    
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:_indexPath.section]];
    
    [[NSFileManager defaultManager] removeItemAtPath:[directoryPath_VIDEO stringByAppendingPathComponent:fileName] error:nil];
    
    
}

- (void)deleteAllDidClick
{
    
    //!< 删除clooectionView 删除文件夹 然后创建folder
    
    [self.collectionView removeFromSuperview];
    
     
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath_VIDEO error:nil];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath_VIDEO withIntermediateDirectories:YES attributes:nil error:nil];
    
}



@end
