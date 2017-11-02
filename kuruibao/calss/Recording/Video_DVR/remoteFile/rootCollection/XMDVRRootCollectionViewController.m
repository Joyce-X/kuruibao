//
//  XMDVRRootCollectionViewController.m
//  kuruibao
//
//  Created by x on 16/11/5.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/**********************************************************
 class description:
 
    collectionView 父类
 
 **********************************************************/

#import "XMDVRRootCollectionViewController.h"
#import "XMDVR_LocalImageCell.h"
#import "XMDVR_LocalImage_collectionRuseView.h"


 
@interface XMDVRRootCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate>


@end

@implementation XMDVRRootCollectionViewController

#pragma mark --- life cycle

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    [self setupInit];
    
}



- (void)setupInit
{
    
    
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
    
    [collectionView registerClass:[XMDVR_LocalImageCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [collectionView registerClass:[XMDVR_LocalImage_collectionRuseView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifier];
    
    [self.view addSubview:collectionView];
    
    self.collectionView = collectionView;
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view);
        
        make.left.equalTo(self.view);
        
        make.right.equalTo(self.view);
        
        make.bottom.equalTo(self.view);
        
    }];
    
    
    
    
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
    XMDVR_LocalImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
//    NSString *fileName = [self getFileNameAtIndexPath:indexPath];
//    
//    cell.imageView.image = [self createThumbnailImageWithImageName:fileName];
//    
//    cell.timeLabel.text =  [self getCreateTimeWithFileName:fileName];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    
    XMDVR_LocalImage_collectionRuseView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
//        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        NSString *fileDate = [self.sectionTitles objectAtIndex:indexPath.section];
        if (fileDate.length == 8) {
            
            NSString *year = [fileDate substringToIndex:4];
            
            NSString *month = [fileDate substringWithRange:NSMakeRange(4, 2)];
            
            NSString *day = [fileDate substringWithRange:NSMakeRange(6, 2)];
            
            
            reusableView.time_title = [NSString stringWithFormat:@"%@.%@.%@",year,month,day];
            
        }
       
        
    }
    
    return reusableView;
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



- (NSInteger)getIndex
{
    
    NSInteger index = 0;
    
    NSArray *keys = [self.dataDictionary allKeys];
    
    for (NSString *key in keys)
    {
        NSMutableArray *arrM = self.dataDictionary[key];
        
        index += arrM.count;
    }
    
    return index;
}


@end
