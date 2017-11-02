//
//  XMDVR_ShowLocalImageViewController.m
//  kuruibao
//
//  Created by x on 16/11/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:
 
        轮播本地图片 的控制器
 
 **********************************************************/
#import "XMDVR_ShowLocalImageViewController.h"

#import "XMDVR_DisplayImageCell.h"


@interface XMDVR_ShowLocalImageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,weak)UICollectionView* collection;

@end


NSString * const identifier = @"displayImageCell";

@implementation XMDVR_ShowLocalImageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.curretIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];

}


- (void)setupInit
{
    self.view.backgroundColor = XMColor(56, 56, 56);

    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 64)];
    
    topView.backgroundColor  = XMColor(46, 46, 46);
    
    [self.view addSubview:topView];
    
    UILabel *titleLabel = [UILabel new];
    
    titleLabel.text = @"预览";
    
    titleLabel.font = [UIFont systemFontOfSize:17];
    
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [topView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(topView);
        
        make.width.equalTo(100);
        
        make.height.equalTo(30);
        
        make.bottom.equalTo(topView).offset(-8);
        
    }];
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"DVR_backButton"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backToLast) forControlEvents:UIControlEventTouchUpInside];
    
    [topView addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(topView).offset(20);
        make.centerY.equalTo(titleLabel);
        make.size.equalTo(CGSizeMake(25, 20));
        
        
    }];
    
         
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    layout.itemSize = CGSizeMake(mainSize.width, mainSize.height - 64);
    
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    layout.minimumLineSpacing = 0;
    
    layout.minimumInteritemSpacing = 0;
    
    UICollectionView *collection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, mainSize.width, mainSize.height - 64) collectionViewLayout:layout];
    
    [collection registerClass:[XMDVR_DisplayImageCell class] forCellWithReuseIdentifier:identifier];
    
    collection.pagingEnabled = YES;
    
    collection.showsHorizontalScrollIndicator = NO;
    
    collection.dataSource = self;
    
    collection.delegate = self;
    
    [self.view addSubview:collection];
    
    self.collection = collection;
 
}

#pragma mark --- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
   XMDVR_DisplayImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.name = _dataSource[indexPath.item];
    
    return cell;


}


- (void)backToLast
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
