//
//  XMTrackScoreViewController.m
//  kuruibao
//
//  Created by x on 16/12/2.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/**********************************************************
 class description:显示驾驶评分的控制器
 
 **********************************************************/

#import "XMTrackScoreViewController.h"
#import "SXAnimateVIew.h"
#import "XMRankView.h"
#import "AFNetworking.h"
#import "NSDictionary+convert.h"
#import "XMTrackScoreModel.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

#import "WXApi.h"

@interface XMTrackScoreViewController ()<UITableViewDelegate>

@property (nonatomic,weak)SXAnimateVIew* fillView;//!< 填充显示平均值组成的View

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (nonatomic,weak)XMRankView* averageView;//!< 平均油耗

@property (nonatomic,weak)XMRankView* totalOil;//!< 总油耗

@property (nonatomic,weak)XMRankView* zhuanWan;//!< 急转弯

@property (nonatomic,weak)XMRankView* shaChe;//!< 急刹车

@property (nonatomic,weak)XMRankView* daiSu;//!< 怠速

@property (nonatomic,weak)XMRankView* jiayou;//!< 急加油

@property (nonatomic,weak)XMRankView* bianDao;//!< 变道

@property (nonatomic,weak)XMRankView* wanDao;//!< 弯道加速

@property (nonatomic,weak)UILabel* scoreLabel;//!< 显示平均分

@property (nonatomic,weak)UIView* shareView;

@property (strong, nonatomic) UIImage *shareImage;


@end

@implementation XMTrackScoreViewController




- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
    
    [self getNewData];
    
  }

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.shareImage = [self getShareImage];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"分数排名页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"分数排名页面");
    
}

- (void)setupInit
{
    
    
    //!< 背景
    UIImageView *backIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, mainSize.height)];
    
    backIV.image = [UIImage imageNamed:@"monitor_background"];
    
    [self.view addSubview:backIV];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 状态栏
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    statusBar.backgroundColor = XMTopColor;
    
    [self.view addSubview:statusBar];
    
    //-----------------------------seperate line---------------------------------------//
    
    //->>返回按钮
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftItem.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    [leftItem setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    [leftItem addTarget:self action:@selector(backToLast) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:leftItem];
    
    [leftItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(20);
        
        make.top.equalTo(self.view).offset(FITHEIGHT(48));
        
        make.size.equalTo(CGSizeMake(31, 31));
        
        
    }];
    
    //->>设置显示提示信息的label
    UILabel *message = [[UILabel alloc]init];
    
     message.textAlignment = NSTextAlignmentLeft;
    
    [message setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26]];//->>加粗
    
    message.textColor = XMColorFromRGB(0xF8F8F8);
    
    message.text = @"驾驶评分";
    
    [self.view addSubview:message];
    
    [message mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(25);
        
        make.width.equalTo(200);
        
        make.height.equalTo(31);
        
        make.top.equalTo(leftItem.mas_bottom).offset( FITHEIGHT(20));
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加分享按钮
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [shareBtn setImage:[UIImage imageNamed:@"Track_share"] forState:UIControlStateNormal];
    
    [shareBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    [shareBtn addTarget:self action:@selector(shareBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:shareBtn];
    
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(leftItem);
        
        make.centerY.equalTo(leftItem);
        
        make.right.equalTo(backIV).offset(-20);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加紫色五边形边框
    
    SXAnimateVIew *borderView = [SXAnimateVIew new];
    
    borderView.backgroundColor = [UIColor clearColor];
    
    borderView.subScore1 = 5;
    borderView.subScore2 = 5;
    borderView.subScore3 = 5;
    borderView.subScore4 = 5;
    borderView.subScore5 = 5;
    
    borderView.showColor = XMPurpleColor;
    
    borderView.showType = 2;
    
    borderView.showWidtn = 1;
    
    [self.view addSubview:borderView];
    
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(FITHEIGHT(170), FITHEIGHT(170)));
        
        make.centerX.equalTo(backIV);
        
        make.top.equalTo(statusBar.mas_bottom).offset(FITHEIGHT(150));
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加填充的颜色
    
    SXAnimateVIew *fillView = [SXAnimateVIew new];
    
    fillView.backgroundColor = [UIColor clearColor];
    
    fillView.showType = 1;
    
    fillView.showWidtn = 1;
    
    fillView.isGradient = YES;
    
    fillView.alpha = 0.5;
    
    fillView.subScore1 = 2.5;
    
    fillView.subScore2 = 2.5;
    
    fillView.subScore3 = 2.5;
    
    fillView.subScore4 = 2.5;
    
    fillView.subScore5 = 2.5;
    
 
    
    [self.view addSubview:fillView];
    
    self.fillView = fillView;
    
     [fillView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.equalTo(borderView);
        
        make.size.equalTo(borderView);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加白色五边形边框
    
    SXAnimateVIew *halfView = [SXAnimateVIew new];
    
    halfView.backgroundColor = [UIColor clearColor];
    
    halfView.subScore1 = 2.5;
    halfView.subScore2 = 2.5;
    halfView.subScore3 = 2.5;
    halfView.subScore4 = 2.5;
    halfView.subScore5 = 2.5;
    
    halfView.showColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    
    halfView.showType = 2;
    
    halfView.showWidtn = 1;
    
    [self.view addSubview:halfView];
    
    [halfView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(borderView);
        
        make.center.equalTo(borderView);
        
        
    }];
    
    //!< 添加分数
    
    UILabel *label = [[UILabel alloc]init];
    
    label.text = @"0";
    
    label.textColor = [UIColor whiteColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    label.font = [UIFont fontWithName:@"Helvetica" size:48];
    
    [self.view addSubview:label];
    
    self.scoreLabel = label;
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(90, 90));
        
        make.center.equalTo(borderView);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加label
    //!<  驾驶习惯
    UILabel *customLabel = [UILabel new];
    
    customLabel.font = [UIFont systemFontOfSize:12];
    
    customLabel.text = @"驾驶习惯";
    
    customLabel.textAlignment = NSTextAlignmentCenter;
    
    customLabel.textColor = XMPurpleColor;
    
    [self.view addSubview:customLabel];
    
    [customLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(borderView);
        
        make.height.equalTo(10);
        
        make.bottom.equalTo(borderView.mas_top).offset(-10);
        
        make.width.equalTo(150);
        
    }];
    
    //!<  行车安全
    UILabel *safeLabel = [UILabel new];
    
    safeLabel.font = [UIFont systemFontOfSize:12];
    
    safeLabel.text = @"行车安全";
    
    safeLabel.textAlignment = NSTextAlignmentRight;
    
    safeLabel.textColor = XMPurpleColor;
    
    [self.view addSubview:safeLabel];
    
    [safeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(borderView).offset(-20);
        
        make.height.equalTo(10);
        
        make.right.equalTo(borderView.mas_left).offset(-10);
        
        make.width.equalTo(150);
        
    }];
    
    //!<  行车速度
    UILabel *speedLabel = [UILabel new];
    
    speedLabel.font = [UIFont systemFontOfSize:12];
    
    speedLabel.text = @"行车速度";
    
    speedLabel.textAlignment = NSTextAlignmentRight;
    
    speedLabel.textColor = XMPurpleColor;
    
    [self.view addSubview:speedLabel];
    
    [speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(borderView.left).offset(43);
        
        make.height.equalTo(10);
        
        make.top.equalTo(borderView.mas_bottom).offset(3);
        
        make.width.equalTo(150);
        
    }];
    
    //!<  环保出行
    UILabel *footLabel = [UILabel new];
    
    footLabel.font = [UIFont systemFontOfSize:12];
    
    footLabel.text = @"环保出行";
    
    footLabel.textAlignment = NSTextAlignmentLeft;
    
    footLabel.textColor = XMPurpleColor;
    
    [self.view addSubview:footLabel];
    
    [footLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(borderView.mas_right).offset(-40);
        
        make.height.equalTo(10);
        
        make.top.equalTo(speedLabel);
        
        make.width.equalTo(150);
        
    }];
    
    //!<  低碳生活
    UILabel *lifeLabel = [UILabel new];
    
    lifeLabel.font = [UIFont systemFontOfSize:12];
    
    lifeLabel.text = @"低碳生活";
    
    lifeLabel.textAlignment = NSTextAlignmentLeft;
    
    lifeLabel.textColor = XMPurpleColor;
    
    [self.view addSubview:lifeLabel];
    
    [lifeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(borderView.mas_right).offset(10);
        
        make.height.equalTo(10);
        
        make.top.equalTo(safeLabel);
        
        make.width.equalTo(150);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    CGFloat width = mainSize.width - FITWIDTH(23) * 2;
    
    UITableView *tableView = [UITableView new];
    
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.alwaysBounceVertical = YES;
    
    tableView.showsVerticalScrollIndicator = NO;
    
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(borderView.mas_bottom).offset(FITHEIGHT(44));
        
        make.left.equalTo(backIV).offset(FITWIDTH(23));
        
         make.width.equalTo(width);
        
        make.height.equalTo(106 * 2 +16);
        
    }];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 106 * 4 + 33)];
    
    headerView.backgroundColor = [UIColor clearColor];
    
    tableView.tableHeaderView = headerView;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加排名 View
    
    //!< 1 百公里油耗排名
    
     width = (width-1) * 0.5;
    
    XMRankView *average = [XMRankView new];
    
    average.typeName = @"平均油耗";
    
    average.text2 = @"百公里";
    
    average.text3 = nil;
    
    [headerView addSubview:average];
    
    self.averageView = average;
    
    [average mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(headerView).offset(15);
        
        make.left.equalTo(headerView);
        
        make.height.equalTo(106);
        
        make.width.equalTo(width);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 2 总油耗排名
    
    XMRankView *totalOil = [XMRankView new];
    
    totalOil.typeName = @"总油耗";
 
    totalOil.text2 = @"总油耗";
    
    totalOil.text3 = nil;
    
    [headerView addSubview:totalOil];
    
    self.totalOil = totalOil;
    
    [totalOil mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(average);
        
        make.left.equalTo(average.mas_right).offset(1);
        
        make.top.equalTo(average);
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 3急转弯排名
    
    XMRankView *zhuanWan = [XMRankView new];
    
    zhuanWan.typeName = @"急转弯";
    
     [headerView addSubview:zhuanWan];
    
    self.zhuanWan = zhuanWan;
    
    [zhuanWan mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(average);
        
        make.top.equalTo(average.mas_bottom).offset(1);
        
        make.left.equalTo(headerView);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 4急刹车排名
    XMRankView *shaChe = [XMRankView new];
    
    shaChe.typeName = @"急刹车";
    
    [headerView addSubview:shaChe];
    
    self.shaChe = shaChe;
    
    [shaChe mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(average);
        
        make.top.equalTo(zhuanWan);
        
        make.right.equalTo(headerView);
        
    }];
    
    //--------------------------------------------------------------------------------------
    //-----------------------------seperate line---------------------------------------//
    
    //!< 5怠速排名
    XMRankView *daiSu = [XMRankView new];
    
    daiSu.typeName = @"怠速";
    
    daiSu.text2 = @"时长";
    
    [headerView addSubview:daiSu];
    
    self.daiSu = daiSu;
    
    [daiSu mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(average);
        
        make.top.equalTo(zhuanWan.mas_bottom).offset(1);
        
        make.left.equalTo(headerView);
        
    }];
    //-----------------------------seperate line---------------------------------------//
    
    //!< 6急加油排名
    XMRankView *jiayou = [XMRankView new];
    
    jiayou.typeName = @"急加油";
    
    [headerView addSubview:jiayou];
    
    self.jiayou = jiayou;
    
    [jiayou mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(average);
        
        make.top.equalTo(daiSu);
        
        make.right.equalTo(headerView);
        
    }];
    //-----------------------------seperate line---------------------------------------//
    
    //!< 7变道排名
    XMRankView *bianDao = [XMRankView new];
    
    bianDao.typeName = @"变道";
    
    [headerView addSubview:bianDao];
    
    self.bianDao = bianDao;
    
    [bianDao mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(average);
        
        make.top.equalTo(daiSu.mas_bottom).offset(1);
        
        make.left.equalTo(headerView);
        
    }];
    //-----------------------------seperate line---------------------------------------//
    
    //!<8弯道加速排名
    XMRankView *wanDao = [XMRankView new];
    
    wanDao.typeName = @"弯道加速";
    
    [headerView addSubview:wanDao];
    
    self.wanDao = wanDao;
    
    [wanDao mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(average);
        
        make.top.equalTo(bianDao);
        
        make.right.equalTo(headerView);
        
    }];
    
}


- (void)getNewData
{
    
 
    if (self.Qicheid.intValue == 0)
    {
        return;
    }
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_score_get&Userid=%@&Qicheid=%@",_userid,_Qicheid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *resultStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([resultStr isEqualToString:@"0"])
        {
            
             [MBProgressHUD showError:@"没有数据"];
            
        }else if([resultStr isEqualToString:@"1"])
        {
            [MBProgressHUD showError:@"网络连接超时"];
        
        }else
        {
            //!< 获取数据成功之后 在界面进行展示
        
            NSArray *resultArr = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            NSDictionary *dic = [NSDictionary nullDic:[resultArr firstObject]];
            
            [self setDataWithDictionary:dic];
            
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
         [MBProgressHUD showError:@"网络连接超时"];
        
    }];
    
    
}


//!< 获取成功之后进行数据展示
- (void)setDataWithDictionary:(NSDictionary *)dic
{
    
    XMTrackScoreModel *model = [[XMTrackScoreModel alloc]initWithDic:dic];
    
    //!< 总油耗
    self.totalOil.value2 = model.penyou;
    
    self.totalOil.value1 = model.penyouscore;
    
    _totalOil.rank = model.penyouno;

    //!< 急刹车
    
    _shaChe.value2 = model.jishache;
    
    _shaChe.value3 = model.jishache100;
    
    _shaChe.rank = model.jishacheno;
    
    _shaChe.value1 = model.jishachescore;
    
    //!< 急加油
    _jiayou.value2 = model.jijiayou;
    
    _jiayou.value3 = model.jijiayou100;
    
    _jiayou.rank = model.jijiayouno;
    
    _jiayou.value1 = model.jijiayouscore;
    
    //!< 变道
    _bianDao.value2 = model.pinfanbiandao;
    
    _bianDao.value3 = model.pinfanbiandao100;
    
    _bianDao.rank = model.pinfanbiandaono;
    
    _bianDao.value1 = model.pinfanbiandaoscore;


    //!< 弯道加速
    _wanDao.value2 = model.wandaojiasu;
    
    _wanDao.value3 = model.wandaojiasu100;
    
    _wanDao.rank = model.wandaojiasuno;
    
    _wanDao.value1 = model.wandaojiasuscore;
    
    //!< 油耗
    _averageView.value2 = model.youhao100;
    
    _averageView.value1 = model.youhao100score;
    
    _averageView.rank = model.youhao100no;
    
    //!< 怠速
    _daiSu.value2 = model.daisutime;
    
    _daiSu.value3 = model.daisu100;
    
    _daiSu.value1 = model.daisuscore;
    
    _daiSu.rank = model.daisuno;
    
    //!< 急转弯
    _zhuanWan.value2 = model.jizhuanwan;
    
    _zhuanWan.value3 = model.jizhuanwan100;
    
    _zhuanWan.rank = model.jizhuanwanno;
    
    _zhuanWan.value3 = model.jizhuanscore;
    
    float score1 = model.xiguanscore.floatValue;
    float score2 = model.anquanscore.floatValue;
    float score3 = model.speedscore.floatValue;
    float score4 = model.huanbaoscore.floatValue;
    float score5 = model.ditanscore.floatValue;
    
    int average = (score1 + score2 + score3 + score4 + score5)/5;

    _scoreLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",average];
    
    _fillView.subScore1 = score1/40.0 + 2.5;
    _fillView.subScore2 = score2/40.0 + 2.5;
    _fillView.subScore3 = score3/40.0 + 2.5;
    _fillView.subScore4 = score4/40.0 + 2.5;
    _fillView.subScore5 = score5/40.0 + 2.5;

    _fillView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [_fillView setNeedsDisplay];
    
    [UIView animateWithDuration:0.7 animations:^{
       
        _fillView.transform = CGAffineTransformIdentity;
        
        _scoreLabel.transform = CGAffineTransformIdentity;
        
    }];
    
}

#pragma mark -------------- lazy
- (AFHTTPSessionManager *)session
{
    
    if(!_session)
    {
    
        _session = [AFHTTPSessionManager manager];
        
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _session.requestSerializer.timeoutInterval = 12;
    
    
    }

    return _session;
}

#pragma mark -------------- 按钮点击事件

//!< 点击返回按钮
- (void)backToLast
{
    [self.navigationController popViewControllerAnimated:YES];
    
    
    
}

//!< 点击分享按钮
- (void)shareBtnDidClick
{
    
    if(_shareView)
    {
        //!< 取消
        [UIView animateWithDuration:0.2 animations:^{
            
            _shareView.transform = CGAffineTransformIdentity;
            
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [_shareView removeFromSuperview];

        });
        return;
    }
    
    UIView *shareView = [UIView new];
    
    shareView.backgroundColor = XMColorFromRGB(0x1a1a1a);
    
    [self.view addSubview:shareView];
    
    _shareView = shareView;
    
    [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(mainSize.width, 135));
        
        make.top.equalTo(self.view.mas_bottom);
        
        
    }];
    
    //!< 判断用户有没有装微信，没有装微信就只显示新浪微博
    if (![WXApi isWXAppInstalled])
    {
        //!<没有 安装微信
        
        //!< sina
        UIButton *sina = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [sina setImage:[UIImage imageNamed:@"Track_share_sina"] forState:UIControlStateNormal];
        
        sina.tag = 2;
        
        [sina addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [shareView addSubview:sina];
        
        
        [sina mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(shareView);
            
            make.top.equalTo(shareView).offset(20);
            
            make.size.equalTo(CGSizeMake(41, 41));
            
        }];
        
        UILabel *sLabel = [UILabel new];
        
        sLabel.text = @"新浪微博";
        
        sLabel.textColor = [UIColor whiteColor];
        
        sLabel.font = [UIFont systemFontOfSize:12];
        
        sLabel.textAlignment = NSTextAlignmentCenter;
        
        [shareView addSubview:sLabel];
        
        [sLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(sina.mas_bottom).offset(6);
            
            make.height.equalTo(10);
            
            make.centerX.equalTo(sina);
            
            make.width.equalTo(80);
            
        }];
        
        
        //-----------------------------seperate line---------------------------------------//
        
        UIView *sline = [UIView new];
        
        sline.backgroundColor = XMGrayColor;
        
        [shareView addSubview:sline];
        
        [sline mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(shareView);
            
            make.right.equalTo(shareView);
            
            make.top.equalTo(sLabel.mas_bottom).offset(12);
            
            make.height.equalTo(1);
            
        }];
        
        //-----------------------------seperate line---------------------------------------//
        //!< 取消按钮
        
        UIButton *ScancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [ScancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        
        [ScancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        ScancelBtn.tag = 3;
        
        [ScancelBtn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [shareView addSubview:ScancelBtn];
        
        
        [ScancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(shareView);
            
            make.top.equalTo(sline);
            
            make.bottom.equalTo(shareView);
            
            make.right.equalTo(shareView);
            
        }];

        
        [UIView animateWithDuration:0.2 animations:^{
            
            shareView.transform = CGAffineTransformMakeTranslation(0, -135);
            
        }];
        
        return;
    }
    
    
    
    
    //-----------------------------seperate line---------------------------------------//
    //!< 微信朋友圈
    UIButton *wechatFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [wechatFriendBtn setImage:[UIImage imageNamed:@"Track_share_friend"] forState:UIControlStateNormal];
    
    wechatFriendBtn.tag = 1;
    
    [wechatFriendBtn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [shareView addSubview:wechatFriendBtn];
    
    
    [wechatFriendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(shareView);
        
        make.top.equalTo(shareView).offset(20);
        
        make.size.equalTo(CGSizeMake(41, 41));
        
    }];
    
    UILabel *wechatFriendLabel = [UILabel new];
    
    wechatFriendLabel.text = @"微信朋友圈";
    
    wechatFriendLabel.textColor = [UIColor whiteColor];
    
    wechatFriendLabel.font = [UIFont systemFontOfSize:12];
    
    wechatFriendLabel.textAlignment = NSTextAlignmentCenter;
    
    [shareView addSubview:wechatFriendLabel];
    
    [wechatFriendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(wechatFriendBtn.mas_bottom).offset(6);
        
        make.height.equalTo(10);
        
        make.centerX.equalTo(wechatFriendBtn);
        
        make.width.equalTo(80);
        
    }];
    //-----------------------------seperate line---------------------------------------//
    //!< 微信好友
    UIButton *wechatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [wechatBtn setImage:[UIImage imageNamed:@"Track_share_wechat"] forState:UIControlStateNormal];
    
    [wechatBtn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [shareView addSubview:wechatBtn];
    
    
    [wechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(wechatFriendBtn.mas_left).offset(-FITWIDTH(50));
        
        make.top.equalTo(shareView).offset(20);
        
        make.size.equalTo(CGSizeMake(41, 41));
        
    }];
    
    UILabel *wechatLabel = [UILabel new];
    
    wechatLabel.text = @"微信好友";
    
    wechatLabel.textColor = [UIColor whiteColor];
    
    wechatLabel.font = [UIFont systemFontOfSize:12];
    
    wechatLabel.textAlignment = NSTextAlignmentCenter;
    
    [shareView addSubview:wechatLabel];
    
    [wechatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(wechatBtn.mas_bottom).offset(6);
        
        make.height.equalTo(10);
        
        make.centerX.equalTo(wechatBtn);
        
        make.width.equalTo(80);
        
    }];
   
    
    //-----------------------------seperate line---------------------------------------//
    //!< sina
    UIButton *sinaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [sinaBtn setImage:[UIImage imageNamed:@"Track_share_sina"] forState:UIControlStateNormal];
    
    sinaBtn.tag = 2;
    
    [sinaBtn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [shareView addSubview:sinaBtn];
    
    
    [sinaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(wechatFriendBtn.mas_right).offset(FITWIDTH(50));
        
        make.top.equalTo(shareView).offset(20);
        
        make.size.equalTo(CGSizeMake(41, 41));
        
    }];
    
    UILabel *sinaLabel = [UILabel new];
    
    sinaLabel.text = @"新浪微博";
    
    sinaLabel.textColor = [UIColor whiteColor];
    
    sinaLabel.font = [UIFont systemFontOfSize:12];
    
    sinaLabel.textAlignment = NSTextAlignmentCenter;
    
    [shareView addSubview:sinaLabel];
    
    [sinaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(wechatBtn.mas_bottom).offset(6);
        
        make.height.equalTo(10);
        
        make.centerX.equalTo(sinaBtn);
        
        make.width.equalTo(80);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    UIView *line = [UIView new];
    
    line.backgroundColor = XMGrayColor;
    
    [shareView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(shareView);
        
        make.right.equalTo(shareView);
        
        make.top.equalTo(sinaLabel.mas_bottom).offset(12);
        
        make.height.equalTo(1);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 取消按钮
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    cancelBtn.tag = 3;
    
    [cancelBtn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [shareView addSubview:cancelBtn];
    
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(shareView);
        
        make.top.equalTo(line);
        
        make.bottom.equalTo(shareView);
        
        make.right.equalTo(shareView);
        
    }];
 
    [UIView animateWithDuration:0.2 animations:^{
       
        shareView.transform = CGAffineTransformMakeTranslation(0, -135);
        
    }];
    
    
}


#pragma mark -------------- share

- (void)shareClick:(UIButton *)sender
{
    
    switch (sender.tag)
    {
        case 0:
            
            [_shareView removeFromSuperview];
            [self shareToweChatFriend];
            break;
            
        case 1:
            [_shareView removeFromSuperview];
            [self shareToFriendCricle];
            break;
            
        case 2:
            
            [_shareView removeFromSuperview];
            [self shareToSina];
            break;
            
        case 3:
            
            {
             //!< 取消
            [UIView animateWithDuration:0.2 animations:^{
               
                _shareView.transform = CGAffineTransformIdentity;
                
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [_shareView removeFromSuperview];
                
            
            });
          }
            break;
            
        default:
            
            break;
    }
    
    
}

- (void)shareToweChatFriend
{
    
   
    //-- 配置分享参数
     NSMutableDictionary *shareParameterDic = [NSMutableDictionary dictionary];
    
//    [shareParameterDic SSDKSetupWeChatParamsByText:nil title: url:nil thumbImage:nil image:nil musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeWechatSession];
//
    [shareParameterDic SSDKSetupShareParamsByText:nil images:@[self.shareImage] url:nil title:nil type:SSDKContentTypeAuto];
    //-- 使用客户端进行分享
    [shareParameterDic SSDKEnableUseClientShare];
    
    //-- 开始分享  这个是分享给好友或者群聊
    [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:shareParameterDic onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
              
                
                break;
            case SSDKResponseStateFail:
                
                
            case SSDKResponseStateCancel:
                
                
            default:
                break;
        }
        
        
        
    }];
    
    
}
- (void)shareToFriendCricle
{
    //-- 配置分享参数
    
    NSMutableDictionary *shareParameterDic = [NSMutableDictionary dictionary];
    
    [shareParameterDic SSDKSetupShareParamsByText:nil images:@[self.shareImage] url:nil title:nil type:SSDKContentTypeAuto];
    //-- 使用客户端进行分享
    [shareParameterDic SSDKEnableUseClientShare];
    
    //-- 开始分享分享到朋友圈
    [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:shareParameterDic onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
                
                
                break;
            case SSDKResponseStateFail:
                
                
            case SSDKResponseStateCancel:
                
                
            default:
                break;
        }
        
        
        
    }];
    
    
}
- (void)shareToSina
{
    
    
    NSMutableDictionary *shareParameterDic = [NSMutableDictionary dictionary];
    
    [shareParameterDic SSDKSetupShareParamsByText:nil images:@[self.shareImage] url:nil title:nil type:SSDKContentTypeImage];
    
    [shareParameterDic SSDKEnableUseClientShare];
    
    [ShareSDK share:SSDKPlatformTypeSinaWeibo parameters:shareParameterDic onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        switch (state) {
            case SSDKResponseStateSuccess:
                
                
                break;
            case SSDKResponseStateFail:
                
                
            case SSDKResponseStateCancel:
                
                
            default:
                break;
        }
        
    }];
    
    
}


//!< 获取截屏
- (UIImage *)getShareImage
{
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
//    float x = 0;
//    float y = 80 * [UIScreen mainScreen].scale;
//    float w = image.size.width * [UIScreen mainScreen].scale;
//    float h = image.size.height  * [UIScreen mainScreen].scale - y;
//    CGImageRef cut = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(x, y, w, h));
//    
//    UIImage *result = [UIImage imageWithCGImage:cut];
//    
//    CFRelease(cut);
    
    return image;



}

#pragma mark -------------- UITableVIewDelegate


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat tranlateY = scrollView.contentOffset.y;
    
    if (tranlateY > 106)
    {
         [scrollView setContentOffset:CGPointMake(0, 229) animated:YES];
            
    }else
    {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    }
    
 }

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat tranlateY = scrollView.contentOffset.y;
    
    if (tranlateY > 106)
    {
        
        [scrollView setContentOffset:CGPointMake(0, 229) animated:YES];
            
     }else
    {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
 
}

#pragma mark -------------- system

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;

}

@end
