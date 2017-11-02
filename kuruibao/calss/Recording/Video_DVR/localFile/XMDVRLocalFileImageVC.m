//
//  XMDVRLocalFileImageVC.m
//  GKDVR
//
//  Created by x on 16/10/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:
 
 
        本地图片列表展示
 
 **********************************************************/
#import "XMDVRLocalFileImageVC.h"
#import "XMDVR_LocalImageCell.h"
#import "XMDVR_LocalImage_collectionRuseView.h"

#import "XMDVRShowImageViewController.h"

#import "XMDVR_ShowLocalImageViewController.h" //展示图片


#define directoryPath_IMAGE [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/DVR/PIC"]

#define directoryPath_THUMBNAIL [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/DVR/Thumbnail_PIC"]


static NSString *reuseIdentifier = @"collectionCell";

@interface XMDVRLocalFileImageVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate>

@property (nonatomic,weak)UICollectionView* collectionView;

@property (strong, nonatomic) NSMutableDictionary *dataDictionary;//!< 数据源

@property (strong, nonatomic) NSArray *sectionTitles;//!< 分区标题

@property (strong, nonatomic) NSIndexPath *indexPath;//!< 点击下标



//@property (copy, nonatomic) NSString *imageName;//!< 点击图片名称

@end

@implementation XMDVRLocalFileImageVC


#pragma mark --- life cycle

- (void)viewDidLoad {
    

    [super viewDidLoad];
    
    [self setupInit];
    
    //!< judge the thumbnail directory whether exist
    
    [self judgeDirectoryWhetherExist];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.sectionTitles == nil || self.sectionTitles.count == 0)
    {
        [MBProgressHUD showError:@"没有图片文件"];
        
    }


}

- (void)setupInit
{
    
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

- (void)judgeDirectoryWhetherExist
{
    
    
    BOOL exist = NO;
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath_THUMBNAIL isDirectory:&exist];
    if (isExist && exist) {
        
        //!< exist
        return;
    }else
    {
    
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath_THUMBNAIL withIntermediateDirectories:YES attributes:nil error:nil];
    
    }
    
}

#pragma mark --- lazy

-(NSMutableDictionary *)dataDictionary
{
    if (!_dataDictionary)
    {
         //!< 过滤掉所有不是照片的文件
        NSArray * subPaths = [[NSFileManager defaultManager] subpathsAtPath:directoryPath_IMAGE];
        
        if (subPaths.count == 0)return nil;

         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS 'jpg'"];
        
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
    XMDVR_LocalImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
   
    NSString *fileName = [self getFileNameAtIndexPath:indexPath];
    
    cell.imageView.image = [self createThumbnailImageWithImageName:fileName];
    
    cell.timeLabel.text =  [self getCreateTimeWithFileName:fileName];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    XMDVR_LocalImage_collectionRuseView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
//        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
       
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
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"本地图片选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"预览",@"删除",@"全部删除", nil];
    
    [sheet showInView:self.view];


}


#pragma mark --- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            //!< 预览
            [self previewDidClick];
            
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


- (UIImage *)createThumbnailImageWithImageName:(NSString *)fileName
{
    
    NSString *thumbPath = [directoryPath_THUMBNAIL stringByAppendingPathComponent:fileName];
    
    //!< 判断缩略图是否存在，存在加载缩略图，不存在创造并保存
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:thumbPath])
    {
        //!< 存在
        return [UIImage imageWithContentsOfFile:thumbPath];
        
        
    }else
    {
         //!< 创建缩略图
        NSString *orginPath = [directoryPath_IMAGE stringByAppendingPathComponent:fileName];
        
        UIImage *orginImage = [UIImage imageWithContentsOfFile:orginPath];
        
        UIImage *thumbImage = [self setThumbnailFromImage:orginImage];
        
        NSData *imageData =  UIImageJPEGRepresentation(thumbImage, 1);
        
        [imageData writeToFile:thumbPath atomically:YES];
        
        return thumbImage;
    
    
    }
    
    
}

- (NSString *)getFileNameAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.sectionTitles[indexPath.section];
    
    NSArray *value = self.dataDictionary[key];
    
    return value[indexPath.item];

    
}

- (UIImage *)setThumbnailFromImage:(UIImage*)image {
    
    CGSize originImageSize = image.size;
    
    CGRect newRect =CGRectMake(0,0,40,40);
    
    //根据当前屏幕scaling factor创建一个透明的位图图形上下文(此处不能直接从UIGraphicsGetCurrentContext获取,原因是UIGraphicsGetCurrentContext获取的是上下文栈的顶,在drawRect:方法里栈顶才有数据,其他地方只能获取一个nil.详情看文档)
    
    UIGraphicsBeginImageContextWithOptions(newRect.size,NO,0.0);
    
    //保持宽高比例,确定缩放倍数
    
    //(原图的宽高做分母,导致大的结果比例更小,做MAX后,ratio*原图长宽得到的值最小是40,最大则比40大,这样的好处是可以让原图在画进40*40的缩略矩形画布时,origin可以取=(缩略矩形长宽减原图长宽*ratio)/2 ,这样可以得到一个可能包含负数的origin,结合缩放的原图长宽size之后,最终原图缩小后的缩略图中央刚好可以对准缩略矩形画布中央)
    
    float ratio =MAX(newRect.size.width/ originImageSize.width, newRect.size.height/ originImageSize.height);
    
    //创建一个圆角的矩形UIBezierPath对象
    
    UIBezierPath*path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:0];
    
    //用Bezier对象裁剪上下文
    
    [path addClip];
    
    //让image在缩略图范围内居中()
    
    CGRect projectRect;
    
    projectRect.size.width= originImageSize.width* ratio;
    
    projectRect.size.height= originImageSize.height* ratio;
    
    projectRect.origin.x= (newRect.size.width- projectRect.size.width) /2;
    
    projectRect.origin.y= (newRect.size.height- projectRect.size.height) /2;
    
    //在上下文中画图
    
    [image drawInRect:projectRect];
    
    //从图形上下文获取到UIImage对象,赋值给thumbnai属性
    
    UIImage*smallImg =UIGraphicsGetImageFromCurrentImageContext();
    
    UIImage *thumbnail= smallImg;
    
    //清理图形上下文(用了UIGraphicsBeginImageContext需要清理)
    
    UIGraphicsEndImageContext();
    
    return thumbnail;
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

- (void)previewDidClick
{
    
    //!< 传一个数组过去，并且标注当前位置
    
    NSMutableArray *passArr = [NSMutableArray array];
    
    NSInteger selectIndex = self.indexPath.section;
    
    for (int i = 0; i < self.sectionTitles.count; i++)
    {
        NSArray *images = [self.dataDictionary objectForKey:self.sectionTitles[i]];
        
        [passArr addObjectsFromArray:images];
        
    }
    
    NSInteger passIndex = 0;
    
    if (selectIndex == 0)
    {
        passIndex = self.indexPath.item;
    }else
    {
    
        for (int k = 0; k<self.sectionTitles.count; k++)
        {
            if (k == selectIndex)break;
            
            NSString *tempKey = self.sectionTitles[k];
            
            NSArray *arr = self.dataDictionary[tempKey];
            
            passIndex += arr.count;
        }
        
        passIndex += self.indexPath.item;
    }
    
    
    
    XMDVR_ShowLocalImageViewController *vc = [[XMDVR_ShowLocalImageViewController alloc]init];
    
    
    NSString *key = self.sectionTitles[_indexPath.section];
    
    NSArray *value = self.dataDictionary[key];
    
    vc.imageName = value[_indexPath.item];
    
    vc.dataSource = passArr;
    
    vc.curretIndex = passIndex;
  
    
    [self presentViewController:vc animated:YES completion:nil];
    
    
    
}

- (void)deleteDidClick
{
    NSString *key = self.sectionTitles[_indexPath.section];
    
    NSMutableArray *images = _dataDictionary[key];
    
    NSString *fileName = [self getFileNameAtIndexPath:_indexPath];
    
    [images removeObject:fileName];
    
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:_indexPath.section]];
    
    [[NSFileManager defaultManager] removeItemAtPath:[directoryPath_IMAGE stringByAppendingPathComponent:fileName] error:nil];
    
    
}

- (void)deleteAllDidClick
{
    
    [self.collectionView removeFromSuperview];
    
    
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath_IMAGE error:nil];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath_IMAGE withIntermediateDirectories:YES attributes:nil error:nil];
    
}



@end
