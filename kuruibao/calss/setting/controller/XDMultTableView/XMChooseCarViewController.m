//
//  ViewController.h
//  TestE
//
//  Created by 王龙 on 16/8/2.
//  Copyright © 2016年 王龙. All rights reserved.
//

#import "XMChooseCarViewController.h"
//#import "FMDB.h"
#import "XMCarSerial.h"
#import "XMCarStyle.h"
#import "XMMultTableView.h"
#import "XMChooseCell.h"
#import "XMCarModel.h"
#import "AFNetworking.h"
#import "XMBrand.h"
#import "MJExtension.h"

#define backImageH FITHEIGHT(181)  //背景的高度
#define coverWidth 120  //蒙版左侧显示距离

@interface XMChooseCarViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSUInteger _lastBrandHash;

}

@property (nonatomic,weak)UIView* cover;//->>蒙版
@property (nonatomic,weak)UITableView* tab;//->> 车系列表
@property (nonatomic,weak)UITableView* tableView;//->>品牌列表
@property (strong, nonatomic) AFHTTPSessionManager *session;//!< 会话
@property (nonatomic,strong)NSArray* dataSourceArray;//->>品牌列表数据源
@property (strong, nonatomic) NSArray *seriesDataSource;//!< 车系列表数据源
@property (nonatomic,strong)NSArray* indexList;//->>索引数据
//@property (strong, nonatomic) NSArray *styleArray;//!< 款号数据
@property (strong, nonatomic) NSMutableArray *openArray;//!<打开数组
@property (strong, nonatomic) NSMutableDictionary *mutableDic;//!< 返回多少行
@property (copy, nonatomic) NSString *brandName;//!< 选择的品牌名称
@property (copy, nonatomic) NSString *serialName;//!< 选择的车系名称
@property (copy, nonatomic) NSString *styleName;//!< 选择的款式名称
@property (assign, nonatomic) NSInteger brandId;//!< 选择的品牌id
@property (assign, nonatomic) NSInteger serialId;//!< 选择的车系id
@property (assign, nonatomic) NSInteger styleId;//!< 选择的款式id


@end

@implementation XMChooseCarViewController


- (instancetype)init
{
    if (self = [super init])
    {
        [self requestData];
    }
    return self;
    
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    [self initData];
    
    //->>设置顶部视图
    [self setupTopView];
    
    //->>设置第二级别的tab
    [self creatSerialTableView];
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"选择车辆型号页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"选择车辆型号页面");
    
}




- (void)initData
{
    self.openArray = [NSMutableArray array];
    self.mutableDic = [NSMutableDictionary dictionary];

}



/**
 *  设置顶部视图
 */
- (void)setupTopView
{
    
    //!< 状态栏
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    statusBar.backgroundColor = XMTopColor;
    [self.view addSubview:statusBar];
    
    
    //->>背景
    UIImageView *topImageView = [UIImageView new];
    topImageView.userInteractionEnabled = YES;
    topImageView.image = [UIImage imageNamed:@"topbackImage"];
    [self.view addSubview:topImageView];
    topImageView.frame = CGRectMake(0, 20, mainSize.width, backImageH - 20);
    
    
    //->>返回按钮
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftItem setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
     leftItem.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [leftItem addTarget:self action:@selector(leftItemDidClick) forControlEvents:UIControlEventTouchUpInside];
    [topImageView addSubview:leftItem];
    [leftItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(topImageView).offset(20);
        make.top.equalTo(topImageView).offset(FITHEIGHT(28));
        make.size.equalTo(CGSizeMake(31, 31));
        
        
    }];
    
    //->>设置显示提示信息的label
    UILabel *message = [[UILabel alloc]init];
    message.text = @"车型选择";
    message.font = [UIFont systemFontOfSize:26];
    message.textAlignment = NSTextAlignmentLeft;
    message.textColor = XMColorFromRGB(0xF8F8F8);
    [topImageView addSubview:message];
    [message mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(leftItem);
        make.width.equalTo(200);
        make.height.equalTo(31);
        make.top.equalTo(leftItem.mas_bottom).offset(20);
        
        
    }];
    
    //->>tableview
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH)];
//    tableView.separatorColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionIndexColor = [UIColor blueColor];
    tableView.hidden = YES;
    [self.view addSubview:tableView];
    self.tableView = tableView;

    
    
}


//->>创建显示车系的tableview
- (void)creatSerialTableView
{
    //->>创建蒙版
    UIView *cover = [[UIView alloc]initWithFrame:CGRectMake(-coverWidth, backImageH, coverWidth, mainSize.height - backImageH)];
    cover.hidden = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(coverClick)];
    [cover addGestureRecognizer:gesture];
    self.cover = cover;
    [self.view addSubview:cover];
    
    UIView *topView = [UIView new];
    topView.backgroundColor = [UIColor blackColor];
    topView.alpha = 0.15;
    topView.tag = 10;
    [cover addSubview:topView];
    
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor blackColor];
    bottomView.alpha = 0.15;
    bottomView.tag = 11;
    [cover addSubview:bottomView];
    
    
    //    创建tab
    UITableView *tab = [[UITableView alloc]initWithFrame:CGRectMake(mainSize.width, backImageH, mainSize.width - coverWidth, mainSize.height - backImageH)];
    tab.delegate = self;
    tab.dataSource = self;
    tab.backgroundColor = [UIColor whiteColor];
    tab.tag = 80;
    tab.tableFooterView = [UIView new];
    [self.view addSubview:tab];
    self.tab = tab;
    
    
    
}

//!< 请求网络数据
- (void)requestData
{
    NSString *urlStr = [mainAddress stringByAppendingString:@"Getcarbrand"];
    [self.session GET:urlStr parameters:nil progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         self.dataSourceArray = [[XMBrand mj_objectArrayWithKeyValuesArray:responseObject] mutableCopy];
//        [self initDataSource];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD showError:@"网络错误，请检查网络连接"];
        
    }];
    
    
}




#pragma mark 监听按钮的点击事件

- (void)leftItemDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark --- lazy
- (AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];

    }
    [_session.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    return _session;

}


- (void)setDataSourceArray:(NSArray *)objects
{
    if (objects.hash == _lastBrandHash)
    {
        return;
    }
    _lastBrandHash = objects.hash;
    _dataSourceArray = [self  arrayForSections:objects];

 
}

- (NSArray *)arrayForSections:(NSArray *)objects {
    
    // sectionTitlesCount 27 , A - Z + #
    SEL selector = @selector(initial);
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    // section number
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    
    // Create 27 sections' data
    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        [mutableSections addObject:[NSMutableArray array]];
    }
    
    // Insert records
    for (id object in objects) {
        NSInteger sectionNumber = [collation sectionForObject:object collationStringSelector:selector];
        [[mutableSections objectAtIndex:sectionNumber] addObject:object];
    }
    
    // sort in section
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
        [mutableSections replaceObjectAtIndex:idx withObject:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:objectsForSection collationStringSelector:selector]];
    }
    
    // Remove empty sections && insert table data
    NSMutableArray *existTitleSections = [NSMutableArray array];
    for (NSArray *section in mutableSections) {
        if ([section count] > 0) {
            [existTitleSections addObject:section];
        }
    }
    
    // Remove empty sections Index in indexList
    NSMutableArray *existTitles = [NSMutableArray array];
    NSArray *allSections = [collation sectionIndexTitles];
    
    for (NSUInteger i = 0; i < [allSections count]; i++) {
        if ([mutableSections[ i ] count] > 0) {
            [existTitles addObject:allSections[ i ]];
        }
    }
    
    //create indexlist data array
    self.indexList = existTitles;
    
    return existTitleSections;
}


/**
 *  点击蒙版
 */
- (void)coverClick
{
    [_openArray removeAllObjects];
    [_mutableDic removeAllObjects];
    [UIView animateWithDuration:0.3 animations:^{
        self.cover.transform = CGAffineTransformIdentity;
        self.tab.transform = CGAffineTransformIdentity;
    }];
     
}


#pragma mark --- 品牌列表数据源方法  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if(tableView.tag == 80)
    {
        
        return [self numberOfSectionsInMTableView:tableView];
    
    }
    
    return _dataSourceArray.count;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 80)
    {
        return [self mTableView:tableView numberOfRowsInSection:section];
    }
    return [_dataSourceArray[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 80)
    {
        return [self mTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    
    XMChooseCell *cell = [XMChooseCell dequeueResuableCellWithTableView:tableView];
    
 
    XMBrand *brand = _dataSourceArray[indexPath.section][indexPath.row] ;
    cell.brand.text = brand.brandname;
     UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",(long)brand.brandid]];
    if (image)
    {
        cell.picture.image = image;
    }else
    {
    
     cell.picture.image =  [UIImage imageNamed:@"88.jpg"];
    }
  
    return cell;




}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 80)
    {
        return [self mTableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 65;

}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 80)
    {
        return [self mTableView:tableView heightForHeaderInSection:section];
    }
    return 33;

}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    if (tableView.tag == 80)
    {
        return nil;
    }
    return self.indexList;

}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView.tag == 80)
    {
        return 0;
    }
    return index;

}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
 
    
    if (tableView.tag == 80)
    {
        return [self mtableView:tableView viewForHeaderInSection:section];
    }
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 33)];
    header.backgroundColor = XMColorFromRGB(0xF8F8F8);
    UILabel *label = [UILabel new];
    label.text = self.indexList[section];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = XMColorFromRGB(0x7F7F7F);
    label.frame = CGRectMake(25, (33 - 12)/2, 50, 12);
 
    [header addSubview:label];
 
    return header;

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 80)
    {
        return [self mtableView:tableView titleForHeaderInSection:section];
    }
    return @"";
}



#pragma mark  品牌列表代理方法 UITableVIewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == 80)
    {
        [self mTableView:tableView didSelectRowAtIndexPath:indexPath];
        return ;
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    XMBrand *brand = _dataSourceArray[indexPath.section][indexPath.row];
    self.brandName = brand.brandname;//!< 记录品牌
    self.brandId = brand.brandid;//!< 记录品牌编号
    NSString *urlString = [mainAddress stringByAppendingFormat:@"getcarseries&brandid=%ld",(long)brand.brandid];
    [self.session GET:urlString parameters:nil  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         self.seriesDataSource = [XMCarSerial mj_objectArrayWithKeyValuesArray:responseObject];
        [self pushCoverWithData:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //!< 获取失败
        [MBProgressHUD showError:@"网络错误，请检查网络连接"];
     }];
    
    
    UITableViewCell *cell =  [tableView cellForRowAtIndexPath:indexPath];
    CGRect rect = [tableView convertRect:cell.frame toView:self.cover];
     UIView *topView = [self.cover viewWithTag:10];
    topView.frame = CGRectMake(0, 0, coverWidth, rect.origin.y);
    UIView *bottomView = [self.cover viewWithTag:11];
     bottomView.frame = CGRectMake(0, rect.origin.y + rect.size.height, coverWidth, mainSize.height - backImageH - (rect.origin.y + rect.size.height));
    
    

}




- (void)pushCoverWithData:(NSArray *)arr
{
    self.cover.hidden = NO;
    self.tab.hidden = NO;
    [self.tab reloadData];
    [UIView animateWithDuration:.2 animations:^{
        self.cover.transform = CGAffineTransformMakeTranslation(coverWidth, 0);
        self.tab.transform = CGAffineTransformMakeTranslation(-(mainSize.width - coverWidth), 0);
    }];
    
}



#pragma mark --- 车系列表数据源方法   XMMultTableViewDatasource

- (NSInteger)numberOfSectionsInMTableView:(UITableView *)mTableView
{
    
    return self.seriesDataSource.count;
}


- (NSInteger)mTableView:(UITableView *)mTableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.openArray containsObject:@(section)])
    {
        NSString *key = [NSString stringWithFormat:@"%ld",(long)section];
        NSArray *styles = [self.mutableDic objectForKey:key];
        return styles.count;
    }else
    {
        return 0;
    }
    
}

- (NSString *)mtableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    XMCarSerial *serial = self.seriesDataSource[section];
    return serial.seriesname;
}



- (UIView *)mtableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 
     UIView *view =  [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"titleView"];
    if (view == nil) {
         view = [[UIView alloc] init];
        CGFloat height = 50;
        CGFloat width = mainSize.width;
        
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
        view.layer.borderWidth = 0.25;
        view.backgroundColor = XMWhiteColor;
        NSString *title = [self mtableView:tableView titleForHeaderInSection:section];
        view.frame = CGRectMake(0, 0, mainSize.width, 0);
        CGFloat labelW = 200;
        CGFloat labelH = 20;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, (50 - labelH)/2, labelW, labelH)];
        label.text = title;
        label.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8];
        label.font = [UIFont systemFontOfSize:14];
        [view addSubview:label];
        
        view.tag = section;
        CGFloat imgH = height-40;
        CGFloat imgW = imgH;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width - coverWidth-imgW-10, (height-imgH)/2, imgW, imgH)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:@"arrow"];
        
        imageView.tag = 100;
        [view addSubview:imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeader:)];
        [view addGestureRecognizer:tap];
        
        //->>添加分割线
        UIView *line = [UIView new];
        line.frame = CGRectMake(0, height-0.5, width, 0.5);
        line.backgroundColor = [UIColor grayColor];
        line.alpha = 0.3;
        [view addSubview:line];

    }
    
    if ([_openArray containsObject:@(section)])
    {
        UIImageView *IV = [view viewWithTag:100];
        IV.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    

    return view;
}

- (UITableViewCell *)mTableView:(UITableView *)mTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    UITableViewCell *cell = [mTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }

    NSInteger section = indexPath.section;
    NSArray *styles = [_mutableDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    XMCarStyle *style = styles[indexPath.row];
    cell.textLabel.text = style.stylename;
   
    return cell;
}

 

- (CGFloat)mTableView:(UITableView *)mTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 33;
    
}

- (CGFloat)mTableView:(UITableView *)mTableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}



#pragma mark --- 车系列表代理方法 delegate

- (void)mTableView:(UITableView *)mTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *styles = [_mutableDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
    XMCarStyle *style = styles[indexPath.row];
    
    //
    //->>创建车辆模型
    XMCarModel *car = [XMCarModel new];
    car.brand = self.brandName;
    car.brandNumber = [NSString stringWithFormat:@"%ld",(long)self.brandId];
    car.serial = self.serialName;
    car.serialNumber = [NSString stringWithFormat:@"%ld",(long)self.serialId];
    car.style = style.stylename;
    car.styleNumber = [NSString stringWithFormat:@"%ld",(long)style.styleid];
    car.carImageName = [NSString stringWithFormat:@"%ld.jpg",(long)self.brandId];
    //->>发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kCHEXIAOMISETTINGDIDCHOOSECARNOTIFICATION object:self userInfo:@{@"info" : car}];
    //
    //->>返回上一页
    [self leftItemDidClick];
    
}

- (void)tapHeader:(UITapGestureRecognizer *)tap
{
    
      UIView *view = tap.view;
     UIImageView *imageView = [view viewWithTag:100];
     NSInteger section = view.tag;
     XMCarSerial *serial = self.seriesDataSource[section];
     self.serialName = serial.seriesname;//!< 记录系列名称
     self.serialId  = serial.seriesid;//!< 记录系列id
    NSNumber *num = [NSNumber numberWithInteger:section];
    
    
    //!< 判断字典中是否有请求过数据，有数据直接刷新 没有数据再请求数据
    NSArray *styles = [self.mutableDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];
    if (styles)
    {
        //!< 数据存在，判断打开还是关闭
        if ([_openArray containsObject:num])
        {
            //!< 处于打开状态  准备删除操作
            
            [_openArray removeObject:num];//!< 从标记数组中删除
            [self deleteRowsWithArray:styles section:section];
            [UIView animateWithDuration:.2f animations:^{
                
                imageView.transform = CGAffineTransformIdentity;
                
            }];
   
            
        }else
        {
            //!< 处于关闭状态  准备插入操作
            [_openArray addObject: num];//!< 添加到标记数组
            [self inserRowsWithArray:styles section:section];
            [UIView animateWithDuration:.2f animations:^{
                
                imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
                
            }];
            
        
        }
        
        return;
        
        
        
    }
    
    
    
    
    //!< 没有数据就请求数据并添加到字典中
    
    //!< 请求款号信息
     NSString *urlStr = [mainAddress stringByAppendingFormat:@"getcarstyle&seriesid=%@",[NSString stringWithFormat:@"%ld",(long)serial.seriesid]];
    
     [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     
     NSArray *styles = [XMCarStyle mj_objectArrayWithKeyValuesArray:responseObject];
         
         //!< 进行添加操作，所以删除cell时候上边数组很定有值，这里不用进行考虑删除情况
    [_mutableDic setObject:styles forKey:[NSString stringWithFormat:@"%ld",(long)section]];
        
         
         //!< 判断点击分区是否打开
             if (![_openArray containsObject:@(section)])
             {
                 //!< 当前分区处于关闭状态，执行打开操作
                 [_openArray addObject:@(section)];
                 
                 [self inserRowsWithArray:styles section:section];
                 
                 [UIView animateWithDuration:.2f animations:^{
                    
                     imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
                     
                 }];
            
             
             }
     
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     
      [MBProgressHUD showError:@"网络错误，请检查网络连接"];
     
     }];
     
    
    
}

- (void)inserRowsWithArray:(NSArray *)styles section:(NSInteger)section
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < styles.count; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPaths addObject:indexPath];
    }
    
    [self.tab insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}


- (void)deleteRowsWithArray:(NSArray *)styles section:(NSInteger)section
{
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < styles.count; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPaths addObject:indexPath];
    }
    [self.tab deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;


}






@end
