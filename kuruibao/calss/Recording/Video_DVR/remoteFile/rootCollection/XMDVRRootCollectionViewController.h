//
//  XMDVRRootCollectionViewController.h
//  kuruibao
//
//  Created by x on 16/11/5.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMDVR_LocalImageCell.h"

static NSString *reuseIdentifier  =@"XMDVRRootCollectionViewControllerCell";

@interface XMDVRRootCollectionViewController : UIViewController


//
@property (strong, nonatomic) NSMutableDictionary *dataDictionary;//!< 数据源

@property (strong, nonatomic) NSArray *sectionTitles;//!< 分区标题数组

@property (strong, nonatomic) NSIndexPath *indexPath;//!< 记录点击下标

@property (nonatomic,weak)UICollectionView* collectionView;

- (NSString *)getFileNameAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)getCreateTimeWithFileName:(NSString *)fileName;
- (NSInteger)getIndex;
@end
