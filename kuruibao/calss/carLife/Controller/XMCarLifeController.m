//
//  XMCarLifeController.m
//  kuruibao
//
//  Created by x on 17/4/13.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLifeController.h"

#import "XMCarLifeTopView.h"

#import "XMFMView.h"

#import "XMSDK.h"

#import "XMColumnList_x.h"

#import "MJExtension.h"

#import "XMListenDetail.h"

#import "XMCarLifeController.h"

#import "XMNearbyPetrolsStationViewController.h"

#import "XMSearchBreakRulesViewController.h"

#import "XMCarSaveViewController.h"

#import "XMSearchPetrolPreiceViewController.h"

#import "XMCarlife_Cell_01.h"

#import "XMCarLife_showArticleViewController.h"

#import "XMCarlife_Cell_02.h"

#import "XMCarlife_Cell_03.h"
//#import "XMCarInsuranceViewController.h"

#import "XMCarMoreViewController.h"

#import "XMCarLifeBtn.h"

#import "AFNetworking.h"

#import "UMMobClick/MobClick.h"

#define FMViewHeight 65 + (mainSize.width-60)/3 // height for FMView

@interface XMCarLifeController ()<XMFMViewDelegate,XMTrackPlayerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) XMFMView *fmView;//!< bottomView of FM

@property (strong, nonatomic) NSMutableArray *columns;//!< save listen list

@property (strong, nonatomic) XMColumnList_x *currentColumnList;//!< current page data model

@property (strong, nonatomic) XMSDKPlayer *player;//!< player

@property (strong, nonatomic) NSArray *playList;//!< current Play List

@property (strong, nonatomic) NSArray *vcTitles;//!< title array of other viewController

@property (weak, nonatomic) UITableView *tableView;

@end

@implementation XMCarLifeController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setSubViews];
    
//    [self requestFMPageData];
    
     //!< monitor the navi notification
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(userWillStartNavi:) name:kXMNaviToPetrolStationNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWillStartNavi:) name:kXMNaviToParkingStationNotification object:nil];
    //!< 监听网络变化的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidChanged:) name:XMNetWorkDidChangedNotification object:nil];
    
 }

- (void)userWillStartNavi:(NSNotification *)noti
{
    //!< if is playing, stop play
    if([XMSDKPlayer sharedPlayer].playerState == XMSDKPlayerStatePlaying)
    {
    
        [self.fmView stopPlay];
    
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    /**
        pause state also belongs to Playing state,so,should judge depth
     */
    
    //!< if player is playing, imageView add anmation
    switch (self.player.playerState)
    {
        case XMSDKPlayerStatePlaying:
            
             [self.fmView addAnimation];
//            XMLOG(@"---------9999 正在播放---------");
            
            break;
            
        case XMSDKPlayerStatePaused:
            
//            XMLOG(@"---------9999 暂停状态---------");
            
            break;
            
        case XMSDKPlayerStateStop:
            
//            XMLOG(@"---------9999 停止或者其他状态---------");
        
            break;
            
        default:
            break;
    }

    
    
    MobClickBegain(@"车生活主界面");
    
}

- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    
    MobClickEnd(@"车生活主界面");

    

}

- (void)setSubViews
{
    
    self.navigationController.navigationBar.hidden = YES;
    
    //!< background color
    UIImageView *backImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background_bottom"]];
    
    backImageView.frame = self.view.bounds;
    
    [self.view addSubview:backImageView];
    
    //-----------------------------seperate line---------------------------------------//
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //!< create table
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, mainSize.height - 49)];
    
    tableView.dataSource = self;
    
    tableView.delegate = self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview: tableView];
    
    self.tableView = tableView;
    
    
    //-----------------------------seperate line---------------------------------------//
    
    float btn_width = (mainSize.width - 58 - 83 - 41) / 4;
    
    float btn_height = 19 + btn_width + 10 + 13;
    
    float height_module1 = 200;
    
    float height_module2 = 62 + btn_width;
    
    float height_module3 = FMViewHeight;
    
    float totalHeight = height_module1 + height_module2 + height_module3 + 60;
    
    //!< header view
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, totalHeight)];
    
    tableView.tableHeaderView = headerView;
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    //-----------------------------seperate line---------------------------------------//
    
    //!< 轮播
    XMCarLifeTopView *topView = [XMCarLifeTopView new];
    
    topView.frame = CGRectMake(0, 0, mainSize.width, height_module1);
    
    topView.imageNames = @[@"ad_01",@"ad_02",@"ad_03"];
    
    [headerView addSubview:topView];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< add btn arrs
    
   
    
    UIScrollView *scrollView = [UIScrollView new];
    
    scrollView.alwaysBounceHorizontal = YES;
    
    scrollView.alwaysBounceVertical = NO;
    
    scrollView.showsHorizontalScrollIndicator = NO;
    
    scrollView.showsVerticalScrollIndicator = NO;

    scrollView.frame = CGRectMake(0, 200, mainSize.width, btn_height);
    
    scrollView.directionalLockEnabled = YES;
    
    scrollView.delegate = self;
    
    scrollView.tag = 998;
    
    scrollView.contentSize = CGSizeMake(41.5 * 5 + 58 + btn_width * 6, 0);
    
    [headerView addSubview:scrollView];
    
//    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//       
//        make.left.right.equalTo(headerView);
//        
//        make.top.equalTo(topView.mas_bottom);
//        
//        make.height.equalTo(90);
//        
//        
//    }];
    
    
    NSArray *btnTitles = @[@"车小米商城",@"违章查询",@"加油站",@"停车场",@"油价",@"限行"];
    
    NSArray *images = @[@"carLife_store",@"carLife_breakRules",@"carLife_petrolStation",
                        @"carLife_parkStation",@"carLife_petrolPrice",@"carLife_carLimit"];

    for (int i = 0; i < 6; i++)
    {
        
        XMCarLifeBtn *button = [XMCarLifeBtn buttonWithType:UIButtonTypeCustom];
        
        button.tag = i;
        
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        
        [button setTitle:btnTitles[i] forState:UIControlStateNormal];
        
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [button setTitleColor:XMColorFromRGB(0xcfcfcf) forState:UIControlStateNormal];
        
        button.frame = CGRectMake((29 + (btn_width + 41.5) * i), 0, btn_width,  btn_height);
        
        [button addTarget:self action:@selector(operationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollView addSubview:button];
        
    }
    
    //!< add line 01
    
    UIImageView *imageView_01 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_line"]];
    
    [headerView addSubview:imageView_01];
    
    [imageView_01 mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.equalTo(self.view);
        
        make.height.equalTo(1);
        
        make.top.equalTo(scrollView.mas_bottom).offset(20);
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< FMView
    XMFMView *fmView = [XMFMView new];
    
    fmView.delegate = self;
    
    [headerView addSubview:fmView];
    
    self.fmView = fmView;
    
    [fmView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(headerView);
        
        make.top.equalTo(imageView_01.mas_bottom);
        
        make.height.equalTo(FMViewHeight);
        
    }];
    
    [self requestFMPageData];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< add message
    UILabel *mesLabel = [UILabel new];
    
    mesLabel.textColor = [UIColor whiteColor];
    
    mesLabel.text = @"精选文章";
    
    mesLabel.textAlignment = NSTextAlignmentCenter;
    
    mesLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:21];
    
    mesLabel.userInteractionEnabled = YES;
    
//    mesLabel.backgroundColor = XMRandomColor;
    
    [headerView addSubview:mesLabel];
    
    [mesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.equalTo(headerView);
        
        make.top.equalTo(fmView.mas_bottom);
        
    }];
    
    //!< add more btn
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
//    moreBtn.backgroundColor = XMRandomColor;
    
    [moreBtn setImage:[UIImage imageNamed:@"careLife_more"] forState:UIControlStateNormal];
    
    [moreBtn addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    moreBtn.imageView.contentMode = UIViewContentModeScaleToFill;
    
    [mesLabel addSubview:moreBtn];
    
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(30, 30));
        
        make.centerY.equalTo(mesLabel);
        
        make.right.equalTo(mesLabel).offset(-16);
        
        
    }];
    
    
    
}

- (void)setSubViews_old
{
    
    
    //!< background color
    UIImageView *backImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background_bottom"]];
    
    backImageView.frame = self.view.bounds;
    
    [self.view addSubview:backImageView];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //!< 轮播
    XMCarLifeTopView *topView = [XMCarLifeTopView new];
    
    topView.frame = CGRectMake(0, 0, mainSize.width, 200);
    
    topView.imageNames = @[@"a1.jpg",@"a2.jpg",@"a3.jpg",@"a4.jpg"];
    
    [self.view addSubview:topView];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< FMView
    XMFMView *fmView = [XMFMView new];
    
    fmView.delegate = self;
    
    [self.view addSubview:fmView];
    
    self.fmView = fmView;
    
    [fmView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(self.view);
        
        make.bottom.equalTo(self.view).offset(-49 - 14);
        
        make.height.equalTo(FITHEIGHT(FMViewHeight));
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< btn arr
    UIView *middleView = [UIView new];
    
    [self.view addSubview:middleView];
    
    [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.equalTo(self.view);
        
        make.top.equalTo(topView.mas_bottom).offset(30);
        
        make.bottom.equalTo(fmView.mas_top).offset(-30);
        
     }];
    
    CGFloat width = (mainSize.width - 3)/4;
    
    UIButton *temBtn = nil;
    
    
    
    for (int i = 0; i<8; i++)
    {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        
        btn.tag = i;
        
        btn.backgroundColor = XMRandomColor;
        
        [btn addTarget:self action:@selector(operationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [middleView addSubview:btn];
        
        if (i < 4)
        {
            
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
               
                make.top.equalTo(middleView);
                
                make.width.equalTo(width);
                
                make.bottom.equalTo(middleView.mas_centerY).offset(-0.5);


                if (!temBtn)
                {
                    make.left.equalTo(middleView).offset(0);
                    
                }else
                {
                    make.left.equalTo(temBtn.mas_right).offset(1);
                }
                
            }];
            
           
            
        }else
        {
            if (i == 4) {
                
                temBtn = nil;
            }
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(middleView.mas_centerY).offset(0.5);
                
                make.width.equalTo(width);
                
                make.bottom.equalTo(middleView);
                
                if (!temBtn)
                {
                    make.left.equalTo(middleView).offset(0);
                    
                }else
                {
                    make.left.equalTo(temBtn.mas_right).offset(1);
                }
                
            }];
        
        }
        
        
        temBtn = btn;
        
    }
    
    
    
    
    //!< clear cache
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [[XMSDKPlayer sharedPlayer] clearCacheSafely];
        
    });
    
 }


/**
 * @brief request FM data(after view did load, should request for FMView)
 */
- (void)requestFMPageData
{
    
    //!< clear the array
    [self.columns removeAllObjects];
    
    int page;
    
    if (_currentColumnList)
    {
        
        page =  ++_currentColumnList.current_page;
        
    }else
    {
        
        page = 1;
        
    }
    //!< 开始刷新
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:@20 forKey:@"count"];
    
    [params setObject:@(page) forKey:@"page"];
    
    NSLog(@"%@",params);
    
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_ColumnList params:params withCompletionHander:^(id result, XMErrorModel *error) {
 
        [MBProgressHUD hideHUD];
        
        if (error)
        {
            [MBProgressHUD showError:@"网络好像有点问题哦~"];
            
        }else
        {
            
            XMLOG(@"request data success");
            
            //!< if the result has none items,reset the current page to one
            XMColumnList_x *pageModel = [XMColumnList_x mj_objectWithKeyValues:result];
            
        
            
            if (pageModel.columns.count == 0 || pageModel.columns.count == NSNotFound)
            {
                self.currentColumnList.current_page = 1;
                
            }else
            {
                //!< request seccess
                self.currentColumnList= pageModel;
            
            }
            
            //!< add obj to array
            [self.columns addObjectsFromArray:_currentColumnList.columns];
            
            if (self.columns.count < 6)
            {
                //!< continue to request data untill the count of array greater than six
                [self requestFMPageData];
                
                return;
                
            }else if(self.columns.count > 6)
            {
                
                //!< remove index which greater than 6
                [self.columns removeObjectsInRange:NSMakeRange(6, self.columns.count - 6)];
              
            }
            
            //!< the count of array is equal to six, set data for FMView
            self.fmView.items = self.columns;
            
            
        }
        
        
    }];

    
}

#pragma mark ------- lazy

- (NSMutableArray *)columns
{
    if (!_columns)
    {
        _columns = [NSMutableArray array];
    }
    
    return _columns;
    
}

-(XMSDKPlayer *)player
{
    if (!_player)
    {
        _player = [XMSDKPlayer sharedPlayer];
        
        [_player setPlayMode:XMSDKPlayModeTrack];
        
        [_player setAutoNexTrack:YES];
        
        [_player setTrackPlayMode:XMTrackPlayerModeList];
        
        _player.trackPlayDelegate = self;
    }

    return _player;

}

- (NSArray *)playList
{
    if (!_playList)
    {
        _playList = [NSArray array];
    }
    
    return _playList;
    
}

- (NSArray *)vcTitles
{
    if (!_vcTitles)
    {
        _vcTitles = @[@"",@"XMSearchBreakRulesViewController",@"XMNearbyPetrolsStationViewController",@"XMCarSaveViewController",@"XMSearchPetrolPreiceViewController",@"XMCarLimitViewController"];
  
    }
    
    return _vcTitles;
    
}

#pragma mark ------- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 3;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0)
    {
    
         cell = [[NSBundle mainBundle] loadNibNamed:@"XMCarlife_Cell_01" owner:nil options:nil].firstObject;
        
        
    
    }else if(indexPath.row == 1)
    {
         cell = [[NSBundle mainBundle] loadNibNamed:@"XMCarlife_Cell_02" owner:nil options:nil].firstObject;
        
      

    
    
    }else
    {
    
         cell = [[NSBundle mainBundle] loadNibNamed:@"XMCarlife_Cell_03" owner:nil options:nil].firstObject;
     
    
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    
    return cell;
    

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        return 105;
        
    }else if(indexPath.row == 1)
    {
    
        return 220;
        
    }else
    {
    
        return 150;
    
    }


}

#pragma mark ------- UITableviewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *address;
    
    switch (indexPath.row) {
            
        case 0:
            
            address = @"http://mp.weixin.qq.com/s/YDCWhXexiuCxcLFWSBAkeQ";
            
            break;
            
        case 1:
            
            address = @"http://mp.weixin.qq.com/s/1myqzSVme2L5p-Aa-ch9HA";
            
            break;
            
        case 2:
            
            address = @"http://mp.weixin.qq.com/s/tWPQWN_9pdnxonzKLVQGtg";
            
            break;
            
        default:
            break;
    }
    
        XMCarLife_showArticleViewController *vc = [XMCarLife_showArticleViewController new];
        
        vc.hidesBottomBarWhenPushed = YES;
    
        vc.address = address;
    
        [self.navigationController pushViewController:vc animated:YES];
        
    

}

#pragma mark ------- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
//    XMLOG(@"***%f",scrollView.contentOffset.x);
    
    if (scrollView.contentOffset.x >= 230)
    {
        
        [scrollView setContentOffset:CGPointMake(230, 0) animated:NO];
        
    }else if (scrollView.contentOffset.x <= - 40)
    {
        
        [scrollView setContentOffset:CGPointMake(-40, 0) animated:NO];
        
        
        
    }
    
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    XMLOG(@"***will end");
    if (scrollView.contentOffset.x >= 225)
    {
        [scrollView setContentOffset:CGPointMake(179, 0) animated:YES];
        
    }
    
    if (scrollView.contentOffset.x <= - 35)
    {
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    XMLOG(@"***did end");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.11 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    
    if (scrollView.contentOffset.x >= 225)
    {
        [scrollView setContentOffset:CGPointMake(179, 0) animated:YES];
        
    }
    
    if (scrollView.contentOffset.x <= - 35)
    {
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
        });
    
    
}


#pragma mark ------- middle btn click

- (void)operationBtnClick:(UIButton *)sender
{
    XMLOG(@"%ld",sender.tag);
    
    switch (sender.tag)
    {
        case 0:
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cesiumai.com"]];
            
            break;
            
        default:
        {
            NSString *className = self.vcTitles[sender.tag];
            
            Class destinationClass = NSClassFromString(className);
            
            UIViewController * vc = [[destinationClass alloc]init];
            
//             self.navigationController.navigationBar.hidden = NO;
            
//            vc.navigationItem.title = className;
            
            vc.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
            
         }
            
            break;
    }
    
}


/**
 * @brief more brn click
 */
- (void)moreBtnClick
{
//    [MBProgressHUD showSuccess:@"waiting program"];
    
    XMCarMoreViewController *vc = [XMCarMoreViewController new];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark ------- XMFMViewDelegate

/**
 * @brief 通知代理刷新数据
 */
- (void)fmViewShouldRefreshItem:(XMFMView *)fmView
{
    
    [MBProgressHUD showMessage:nil];

    [self requestFMPageData];

    

}

/**
 * @brief 点击某一个元素，通知控制器播放
 */
- (void)fmView:(XMFMView *)fmView itemClick:(UIView *)customView;
{
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showError:@"网络未连接"];
        
        return;
        
    }
    if (self.columns.count == 0)
    {
        [MBProgressHUD showError:@"无网络"];
        
        return;
    }
    
    //!< play
    [self chooseItemWithTag:customView.tag];
    
    
}


//!< 点击上一首
- (void)fmViewDidClickLastItem;
{

    [_player playPrevTrack];

}

//!< 点击播放或暂停
- (void)fmViewDidClickPlayButton:(BOOL)isPlay
{
    
    if (isPlay)
    {
        [_player resumeTrackPlay];
        
    }else
    {
    
        [_player pauseTrackPlay];
    
    }
    
}

//!< 点击下一首
- (void)fmViewDidClickNextItem
{

    [_player playNextTrack];

}


#pragma mark ------- paly module

- (void)chooseItemWithTag:(NSUInteger)tag
{
    
    [MBProgressHUD showMessage:nil];
   
    //!< current model
    XMColumn_x *column = _columns[tag];
    
    //!< request detail model
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:@(column.ID) forKey:@"id"];
    
    [[XMReqMgr sharedInstance] requestXMData:XMReqType_ColumnDetail params:params withCompletionHander:^(id result, XMErrorModel *error) {
        
        
        
        if (error)
        {
            [MBProgressHUD hideHUD];
            
            [MBProgressHUD showError:@"网络好像有点问题哦~"];
            
        }else
        {
            
            
            XMListenDetail *detailModel = [XMListenDetail mj_objectWithKeyValues:result];
            
        XMLOG(@"the item count of the current album :%lu",detailModel.column_items.count);
            
            if(detailModel.column_items.count == 0)
            {
                [MBProgressHUD hideHUD];
                
                [MBProgressHUD showError:@"亲，换个专辑试试吧"];
                
                XMLOG(@"当前专辑没有内容");
                
                return ;
            
            }
            
            NSArray *trackArr = [self changeModelWithArray:detailModel.column_items];
            
            NSString *firstUrl = detailModel.column_items.firstObject.play_url_32;
            
            if (firstUrl == nil || firstUrl.length == 0 || firstUrl.length == NSNotFound)
            {
                [MBProgressHUD hideHUD];
                
                [MBProgressHUD showError:@"当前专辑无法播放"];
                
                return;
            }
            
            [self.player playWithTrack:trackArr.firstObject playlist:trackArr];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
                if (_player.playerState != XMSDKPlayerStatePlaying) {
                    
                    [_player stopTrackPlay];
                    
                    [MBProgressHUD hideHUD];
                    
                    [MBProgressHUD showError:@"亲，换个专辑试试吧~"];
                    
                }
                
                
            });
        
        }
        
    }];
    
    
}

- (NSArray *)changeModelWithArray:(NSArray *)arr
{
    
    NSMutableArray *tem = [NSMutableArray arrayWithCapacity:arr.count];
    
    for (XMColumn_itemModel *model in arr)
    {
        XMTrack *track = [XMTrack new];
        
        track.trackId = model.ID;
        
        track.kind = model.kind;
        
        track.trackTitle = model.subordinated_album.album_title;
        
        track.duration = model.duration;
        
        track.playUrl32 = model.play_url_32;
        
        track.playCount = model.play_count;
        
        track.playUrl64 = model.play_url_64;
        
        track.coverUrlSmall = model.cover_url_small;
        
        track.trackIntro = model.track_title;
        
        [tem addObject:track];
    }
    
    return [tem copy];

}


#pragma mark ------- XMTrackPlayerDelegate

#pragma mark - process notification
//播放时被调用，频率为1s，告知当前播放进度和播放时间
- (void)XMTrackPlayNotifyProcess:(CGFloat)percent currentSecond:(NSUInteger)currentSecond
{

    if (currentSecond % 40 == 0)
    {
        XMLOG(@"当前播放进度：%ld",currentSecond);

    }
    
}
//播放时被调用，告知当前播放器的缓冲进度
- (void)XMTrackPlayNotifyCacheProcess:(CGFloat)percent
{

    XMLOG(@"当前缓冲进度：%f",percent);
}

#pragma mark - player state change
//播放列表结束时被调用
- (void)XMTrackPlayerDidPlaylistEnd
{

    XMLOG(@"播放列表结束");
    
}
//将要播放时被调用
- (void)XMTrackPlayerWillPlaying
{
    
    XMLOG(@"将要播放");
    
  

}
//已经播放时被调用
- (void)XMTrackPlayerDidPlaying
{

    [MBProgressHUD hideHUD];
    
    XMTrack *track = [_player currentTrack];
    
    _fmView.track = track;
    
    [_fmView showPlayView];
    
    XMLOG(@"已经播放");
    
}
//暂停时调用
- (void)XMTrackPlayerDidPaused
{

    XMLOG(@"暂停播放");
    
    
}
//停止时调用
- (void)XMTrackPlayerDidStopped
{

    XMLOG(@"停止播放");

}
//结束播放时调用
- (void)XMTrackPlayerDidEnd
{

    XMLOG(@"结束播放");

}
//播放失败时调用
- (void)XMTrackPlayerDidFailedToPlayTrack:(XMTrack *)track withError:(NSError *)error
{

    [MBProgressHUD showError:@"亲，网络好像有点问题哦~"];
    XMLOG(@"播放失败");

}
//播放失败时是否继续播放下一首
- (BOOL)XMTrackPlayerShouldContinueNextTrackWhenFailed:(XMTrack *)track
{

    return YES;

}

//播放数据请求失败时调用，data.description是错误信息
- (void)XMTrackPlayerDidErrorWithType:(NSString *)type withData:(NSDictionary*)data
{
    XMLOG(@"播放数据失败原因：type:%@,data:%@",type,data);


}

#pragma mark ------- 网络变化

//!< 网络发生变化
- (void)networkDidChanged:(NSNotification *)noti
{
         
    int statusCode = [noti.userInfo[@"info"] intValue];
    
    if (statusCode == 0 || statusCode == -1)
    {
        [MBProgressHUD showError:@"网络已断开"];
        
        
    }else
    {
        
        [self requestFMPageData];
        
        
    }
    
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
    
}


@end
