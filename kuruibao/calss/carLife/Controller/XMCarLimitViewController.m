//
//  XMCarLimitViewController.m
//  kuruibao
//
//  Created by x on 17/4/19.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLimitViewController.h"

#import "XMCarLifeSetCarNumberViewController.h"

#import "XMCarLife_chooseCityView.h"

#import "AFNetworking.h"

#import "XMCarLife_limit_cityResultModel.h"

@import CoreLocation;


#define kViewHeight 24

@interface XMCarLimitViewController ()<XMSetCarNumberViewControllerDelegate,CLLocationManagerDelegate,XMCarLife_chooseCityViewDelegate>

@property (copy, nonatomic) NSString *carNumber;

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;

@property (weak, nonatomic) XMCarLife_chooseCityView *choosView;

@property (strong, nonatomic) CLLocationManager *manager;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (assign, nonatomic) BOOL isRequested;

@property (strong, nonatomic) XMCarLife_limit_cityModel *cityModel;

@property (strong, nonatomic) XMCarLife_limit_cityResultModel *resultModel;

@property (strong, nonatomic) NSArray *cityList;

@end

@implementation XMCarLimitViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.searchBtn setEnabled:NO];
    
    self.carNumberLabel.text = nil;
    
    //!< parse city code
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cityCodeList_carLife_limit.txt" ofType:nil];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    self.cityList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    
    if(![CLLocationManager locationServicesEnabled])
    {
        self.cityLabel.text = @"未开启定位服务";
        
    }
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        self.cityLabel.text = @"未授权";
    
        return;
    }
    
    [self.manager startUpdatingLocation];
    
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    
    paras[@"apikey"] = @"78270960-1685-0135-8674-0242c0a80007";
    
    [self.session POST:@"http://www.loopon.cn/api/v1/trafficlimit/number/getCityList" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         XMCarLife_limit_cityResultModel *resultModel = [XMCarLife_limit_cityResultModel mj_objectWithKeyValues:responseObject];
        
        self.resultModel = resultModel;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
       
        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"车辆限行查询页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"车辆限行查询页面");
    
}

#pragma mark ------- lazy

- (CLLocationManager *)manager
{
    if (!_manager)
    {
        _manager = [[CLLocationManager alloc]init];
        
        _manager.delegate = self;
    }
    
    return _manager;
    
}

- (AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _session.requestSerializer.timeoutInterval = 5;
    }
    
    return _session;
    
}

#pragma mark ------- btnclick

/**
 * @brief search btn click
 */
- (IBAction)searchBtnClick {
    
    //!< judge the network
    int state = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    if (state == 0)
    {
        //!< NotReachable
        
        [MBProgressHUD showError:@"无网络连接"];
        
        return;
        
    }
    
//    if (self.cityModel == nil)
//    {
//        [MBProgressHUD showError:@"请选择城市"];
//    }
    
    [MBProgressHUD showMessage:nil];
    
    
    //!< judge whether support current city
    BOOL support = NO;
    
    NSString *currentCity = self.cityLabel.text;
    
      XMLOG(@"***%@",_cityLabel.text);
    
    for (XMCarLife_limit_cityModel *model in self.resultModel.data)
    {
        XMLOG(@"%@",model.cityname);
        
        if ([currentCity containsString:model.cityname])
        {
            support = YES;
            
            self.cityModel = model;
            
            break;
        }
        
    }
    
    if (!support)
    {
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"暂不支持查询该城市"];
        XMLOG(@" un support");
        
        return;
        
    }
    
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    
    paras[@"apikey"] = @"78270960-1685-0135-8674-0242c0a80007";
    
    paras[@"city"] = self.cityModel.city;
    
    [self.session POST:@"http://www.loopon.cn/api/v1/trafficlimit/number/getCityLimit" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUD];
        
        //!< handle the data waring
        [self handleData:responseObject];
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"网络超时"];
        
    }];
    
    
    
}

- (void)handleData:(id)data
{
    
    //!< judge is local car or other city with carNumber
    NSString *carNumber = self.carNumberLabel.text;
    
    NSString *header = [carNumber substringWithRange:NSMakeRange(0, 2)];
    
    NSString *headerCity = nil;
    
    XMLOG(@"carnumber:%@  header:%@",carNumber,header);
    
    for (NSDictionary *dic in self.cityList)
    {
        if ([header isEqualToString:dic[@"code"]])
        {
            XMLOG(@"find right city %@",dic[@"city"]);
            
            headerCity = dic[@"city"];
            
             break;
        }
        
    }
   
    BOOL islocal = NO;
    
    XMLOG(@"showCity:%@  headerCity:%@",self.cityLabel.text,headerCity);
    
    if (headerCity == nil)
    {
        headerCity = @"NotFond";
    }
    
    if ([self.cityLabel.text containsString:headerCity])
    {
        islocal = YES;
        
    }
    
    if ([header isEqualToString:@"沪R"])
    {
        if ([self.cityLabel.text containsString:@"崇明"] || [self.cityLabel.text containsString:@"长兴"] || [self.cityLabel.text containsString:@"横沙"]) {
            
            islocal = YES;
            
        }
    }
    
   //!< detail data
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    
    //!< remove all subviews
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.scrollView.superview.hidden = NO;
    
    [self layoutSubViewsWithDic:result isLocal:islocal];
    
}


/**
 * @brief base islocal to caulate the scroll view content size
 */
- (void)layoutSubViewsWithDic:(NSDictionary *)dic isLocal:(BOOL)islocal
{
    
    CGFloat height = 0;
    
    int index = 1;
    
    UIView *tem;//!< tem View to certain location
    
    float width = mainSize.width - 49 -20 - 98;
//     [self.scrollView setContentSize:CGSizeMake(570, 0)];
    
    for (NSDictionary *dic_allCar in dic[@"allcars"]) {
        
        UIButton *indexL = [self createLabel:16 color:0xffffff text:[NSString stringWithFormat:@"政策%d",index++]];
        
        [self.scrollView addSubview:indexL];
        
        
        //!< index label
        if (tem == nil)
        {
            [indexL mas_makeConstraints:^(MASConstraintMaker *make) {
               
                make.top.equalTo(_scrollView).offset(17);
                
                make.left.equalTo(_scrollView).offset(15);
                
                make.size.equalTo(CGSizeMake(120, kViewHeight));
                
                
            }];
            
        }else
        {
        
            [indexL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(tem.mas_bottom).offset(17);
                
                make.left.equalTo(_scrollView).offset(15);
                
                make.size.equalTo(CGSizeMake(120, kViewHeight));
                
                
            }];
        
        }
        
        //!< limit time text
        UIButton *timeL = [self createLabel:15 color:0xc5c5c5 text:@"限行时间:"];
        
        [self.scrollView addSubview:timeL];
        
        [timeL mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(indexL);
            
            make.top.equalTo(indexL.mas_bottom).offset(17);
            
            make.width.equalTo(CGSizeMake(83, kViewHeight));
            
        }];
        
        
        //!< show limit time content
        UIButton *timeContentL = [self createLabel:15 color:0xc5c5c5 text:dic_allCar[@"time"]];
        
        timeContentL.titleLabel.numberOfLines = 0;
        
        [self.scrollView addSubview:timeContentL];
        
        [timeContentL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(_scrollView).offset(98);
            
            make.top.equalTo(timeL);
            
            make.width.equalTo(width);
            
            make.bottom.equalTo(timeL);
            
        }];
        
        //!< show area text label
        UIButton *areaL = [self createLabel:15 color:0xc5c5c5 text:@"限行区域:"];
        
        [self.scrollView addSubview:areaL];
        
        [areaL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(_scrollView).offset(15);
            
            make.top.equalTo(timeL.mas_bottom).offset(20);
            
            make.width.equalTo(CGSizeMake(83, kViewHeight));
            
        }];
        
        
        //!< show limit area content
        UIButton *areaContentL = [self createLabel:15 color:0xc5c5c5 text:dic_allCar[@"area"]];
        
        areaContentL.titleLabel.numberOfLines = 0;
        
        [self.scrollView addSubview:areaContentL];
        
        [areaContentL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(_scrollView).offset(98);
            
            make.top.equalTo(areaL);
            
            make.width.equalTo(width);
            
            make.height.equalTo([self heightForText:dic_allCar[@"area"]]);
            
        }];
                                
        //!< actionL
            
        UIButton *actionL = [self createLabel:15 color:0xc5c5c5 text:@"限行规定:"];
        
        [self.scrollView addSubview:actionL];
        
        [actionL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(_scrollView).offset(15);
            
            make.top.equalTo(areaContentL.mas_bottom).offset(20);
            
            make.width.equalTo(CGSizeMake(83, kViewHeight));
            
        }];
        
        //!< action content
        UIButton *actionContentL = [self createLabel:15 color:0xc5c5c5 text:dic_allCar[@"summary"]];
        
        actionContentL.titleLabel.numberOfLines = 0;
        
        [self.scrollView addSubview:actionContentL];
        
        [actionContentL mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(_scrollView).offset(98);
            
            make.top.equalTo(actionL);
            
            make.width.equalTo(width);
            
            make.height.equalTo([self heightForText:dic_allCar[@"summary"]]);
            
        }];
        
        tem =  actionContentL;
        
        int totalH = 17 + kViewHeight + 17 + kViewHeight + 20 + [self heightForText:dic_allCar[@"area"]]
        + 20 + [self heightForText:dic_allCar[@"summary"]] + 20;
        
        height += totalH;
//
    }
    
    if (islocal)
    {
        
        //!< 本地数据
        if ([dic[@"localcar"] count] == 0 && [dic[@"allcars"] count] ==0) {
            
            [MBProgressHUD showError:@"没有对应的数据"];
            
            return;
        }
        for (NSDictionary *dic_allCar in dic[@"localcar"]) {
            
            UIButton *indexL = [self createLabel:16 color:0xffffff text:[NSString stringWithFormat:@"政策%d",index++]];
            
            [self.scrollView addSubview:indexL];
            
            
            //!< index label
            if (tem == nil)
            {
                [indexL mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.top.equalTo(_scrollView).offset(17);
                    
                    make.left.equalTo(_scrollView).offset(15);
                    
                    make.size.equalTo(CGSizeMake(120, kViewHeight));
                    
                    
                }];
                
            }else
            {
                
                [indexL mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.top.equalTo(tem.mas_bottom).offset(17);
                    
                    make.left.equalTo(_scrollView).offset(15);
                    
                    make.size.equalTo(CGSizeMake(120, kViewHeight));
                    
                    
                }];
                
            }
            
            //!< limit time text
            UIButton *timeL = [self createLabel:15 color:0xc5c5c5 text:@"限行时间:"];
            
            [self.scrollView addSubview:timeL];
            
            [timeL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(indexL);
                
                make.top.equalTo(indexL.mas_bottom).offset(17);
                
                make.width.equalTo(CGSizeMake(83, kViewHeight));
                
            }];
            
            
            //!< show limit time content
            UIButton *timeContentL = [self createLabel:15 color:0xc5c5c5 text:dic_allCar[@"time"]];
            
            timeContentL.titleLabel.numberOfLines = 0;
            
            [self.scrollView addSubview:timeContentL];
            
            [timeContentL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(98);
                
                make.top.equalTo(timeL);
                
                make.width.equalTo(width);
                
                make.bottom.equalTo(timeL);
                
            }];
            
            //!< show area text label
            UIButton *areaL = [self createLabel:15 color:0xc5c5c5 text:@"限行区域:"];
            
            [self.scrollView addSubview:areaL];
            
            [areaL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(15);
                
                make.top.equalTo(timeL.mas_bottom).offset(20);
                
                make.width.equalTo(CGSizeMake(83, kViewHeight));
                
            }];
            
            
            //!< show limit area content
            UIButton *areaContentL = [self createLabel:15 color:0xc5c5c5 text:dic_allCar[@"area"]];
            
            areaContentL.titleLabel.numberOfLines = 0;
            
            [self.scrollView addSubview:areaContentL];
            
            [areaContentL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(98);
                
                make.top.equalTo(areaL);
                
                make.width.equalTo(width);
                
                make.height.equalTo([self heightForText:dic_allCar[@"area"]]);
                
            }];
            
            //!< actionL
            
            UIButton *actionL = [self createLabel:15 color:0xc5c5c5 text:@"限行规定:"];
            
            [self.scrollView addSubview:actionL];
            
            [actionL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(15);
                
                make.top.equalTo(areaContentL.mas_bottom).offset(20);
                
                make.width.equalTo(CGSizeMake(83, kViewHeight));
                
            }];
            
            //!< action content
            UIButton *actionContentL = [self createLabel:15 color:0xc5c5c5 text:dic_allCar[@"summary"]];
            
            actionContentL.titleLabel.numberOfLines = 0;
            
            [self.scrollView addSubview:actionContentL];
            
            [actionContentL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(98);
                
                make.top.equalTo(actionL);
                
                make.width.equalTo(width);
                
                make.height.equalTo([self heightForText:dic_allCar[@"summary"]]);
                
            }];
            
            tem =  actionContentL;
            
            int totalH = 17 + kViewHeight + 17 + kViewHeight + 20 + [self heightForText:dic_allCar[@"area"]]
            + 20 + [self heightForText:dic_allCar[@"summary"]] + 20;
            
            height += totalH;
            //
        }

    }else
    {
        
        //!< 外地数据
        if ([dic[@"foreigncar"] count] == 0 && [dic[@"allcars"] count] ==0) {
            
            [MBProgressHUD showError:@"没有对应的数据"];
            
            return;
        }
    
        for (NSDictionary *dic_allCar in dic[@"foreigncar"]) {
            
            UIButton *indexL = [self createLabel:16 color:0xffffff text:[NSString stringWithFormat:@"政策%d",index++]];
            
            [self.scrollView addSubview:indexL];
            
            
            //!< index label
            if (tem == nil)
            {
                [indexL mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.top.equalTo(_scrollView).offset(17);
                    
                    make.left.equalTo(_scrollView).offset(15);
                    
                    make.size.equalTo(CGSizeMake(120, kViewHeight));
                    
                    
                }];
                
            }else
            {
                
                [indexL mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.top.equalTo(tem.mas_bottom).offset(17);
                    
                    make.left.equalTo(_scrollView).offset(15);
                    
                    make.size.equalTo(CGSizeMake(120, kViewHeight));
                    
                    
                }];
                
            }
            
            //!< limit time text
            UIButton *timeL = [self createLabel:15 color:0xc5c5c5 text:@"限行时间:"];
            
            [self.scrollView addSubview:timeL];
            
            [timeL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(indexL);
                
                make.top.equalTo(indexL.mas_bottom).offset(17);
                
                make.width.equalTo(CGSizeMake(83, kViewHeight));
                
            }];
            
            
            //!< show limit time content
            UIButton *timeContentL = [self createLabel:15 color:0xc5c5c5 text:dic_allCar[@"time"]];
            
            timeContentL.titleLabel.numberOfLines = 0;
            
            [self.scrollView addSubview:timeContentL];
            
            [timeContentL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(98);
                
                make.top.equalTo(timeL);
                
                make.width.equalTo(width);
                
                make.bottom.equalTo(timeL);
                
            }];
            
            //!< show area text label
            UIButton *areaL = [self createLabel:15 color:0xc5c5c5 text:@"限行区域:"];
            
            [self.scrollView addSubview:areaL];
            
            [areaL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(15);
                
                make.top.equalTo(timeL.mas_bottom).offset(20);
                
                make.width.equalTo(CGSizeMake(83, kViewHeight));
                
            }];
            
            
            //!< show limit area content
            UIButton *areaContentL = [self createLabel:15 color:0xc5c5c5 text:dic_allCar[@"area"]];
            
            areaContentL.titleLabel.numberOfLines = 0;
            
            [self.scrollView addSubview:areaContentL];
            
            [areaContentL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(98);
                
                make.top.equalTo(areaL);
                
                make.width.equalTo(width);
                
                make.height.equalTo([self heightForText:dic_allCar[@"area"]]);
                
            }];
            
            //!< actionL
            
            UIButton *actionL = [self createLabel:15 color:0xc5c5c5 text:@"限行规定:"];
            
            [self.scrollView addSubview:actionL];
            
            [actionL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(15);
                
                make.top.equalTo(areaContentL.mas_bottom).offset(20);
                
                make.width.equalTo(CGSizeMake(83, kViewHeight));
                
            }];
            
            //!< action content
            UIButton *actionContentL = [self createLabel:15 color:0xc5c5c5 text:dic_allCar[@"summary"]];
            
            actionContentL.titleLabel.numberOfLines = 0;
            
            [self.scrollView addSubview:actionContentL];
            
            [actionContentL mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(_scrollView).offset(98);
                
                make.top.equalTo(actionL);
                
                make.width.equalTo(width);
                
                make.height.equalTo([self heightForText:dic_allCar[@"summary"]]);
                
            }];
            
            tem =  actionContentL;
            
            int totalH = 17 + kViewHeight + 17 + kViewHeight + 20 + [self heightForText:dic_allCar[@"area"]]
            + 20 + [self heightForText:dic_allCar[@"summary"]] + 20;
            
            height += totalH;
            //
        }

    
    }
   
    self.scrollView.contentSize = CGSizeMake(0, height);
    
    
    
    
}

- (float)heightForText:(NSString *)text
{
    
    float width = mainSize.width - 49 -20 - 98;
    
     CGSize titleSize = [text boundingRectWithSize:CGSizeMake(width-16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    
    return titleSize.height + 16;
}

//- (UILabel *)createLabel:(int)font color:(int)color text:(NSString *)text
//{
//    UILabel *label = [UILabel new];
//    
//    label.font = [UIFont systemFontOfSize:font];
//    
//    label.textColor = XMColorFromRGB(color);
//    
//    label.text = text;
//    
//    label.backgroundColor = XMRandomColor;
//    
////    [label setContentMode:UIViewContentModeTop];
//    
//    return label;
//
//}


- (UIButton *)createLabel:(int)font color:(int)color text:(NSString *)text
{
    UIButton *btn = [UIButton new];
    
    [btn setTitle:text forState:UIControlStateNormal];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:font];
    
//    label.textColor = XMColorFromRGB(color);
    
    [btn setTitleColor:XMColorFromRGB(color) forState:UIControlStateNormal];
    
    btn.userInteractionEnabled = NO;
    
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
//    btn.backgroundColor = XMRandomColor;
    
    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    //    [label setContentMode:UIViewContentModeTop];
    
    return btn;
    
}

- (IBAction)backBtnClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark ------- gesturerecgnizer

- (IBAction)chooseCity:(id)sender {
    
    XMLOG(@"choose city did click");
    
    //!< judge the network
   int state = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    if (state == 0)
    {
        //!< NotReachable
        
        [MBProgressHUD showError:@"网络连接失败"];
        
        return;
        
    }
    
    //!< request city array
    
    [MBProgressHUD showMessage:nil];
    
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    
    paras[@"apikey"] = @"78270960-1685-0135-8674-0242c0a80007";
    
    [self.session POST:@"http://www.loopon.cn/api/v1/trafficlimit/number/getCityList" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUD];
        
        XMCarLife_limit_cityResultModel *resultModel = [XMCarLife_limit_cityResultModel mj_objectWithKeyValues:responseObject];
        
        self.resultModel = resultModel;
        
        if (resultModel.rspcode.intValue == 20000)
        {
            //!< success
            XMLOG(@" get city list success");
            [self showChooseView:resultModel];
            
            
        }else
        {
        
            [MBProgressHUD showError:@"获取数据失败"];
        
        }
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"网络超时"];
        
    }];
    
    
    
}

/**
 * @brief show choose city view
 */
- (void)showChooseView:(XMCarLife_limit_cityResultModel *)model
{
    
    
    XMCarLife_chooseCityView *choosView = [XMCarLife_chooseCityView new];
    
    choosView.delegate = self;
    
    choosView.cityLabel.text = self.cityLabel.text;
    
   
    
    [self.view addSubview:choosView];
    
    self.choosView = choosView;
    
    
    [choosView mas_makeConstraints:^(MASConstraintMaker *make) {
        
//        make.top.equalTo(self.view).offset(180);
        make.centerY.mas_equalTo(self.view);
        
        make.left.equalTo(self.view).offset(45);
        
        make.right.equalTo(self.view).offset(-45);
        
        make.height.equalTo(310);
        
        
    }];
    
     choosView.citys = model.data;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        choosView.transform = CGAffineTransformIdentity;
        
    }];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [self.choosView removeFromSuperview];

}

- (IBAction)chooseCarNumber:(UITapGestureRecognizer *)sender {
    
    XMCarLifeSetCarNumberViewController *setNumberVC = [XMCarLifeSetCarNumberViewController new];
    
    setNumberVC.delegate = self;
    
    [self.navigationController pushViewController:setNumberVC animated:YES];
}

#pragma mark ------- XMCarLife_chooseCityViewDelegate

/**
 * @brief click refresh button,to refresh the user location
 */
-(void)XMCarLife_chooseCityViewRefreshLocationDidClick:(XMCarLife_chooseCityView*)chooseView
{
    
    
    if(![CLLocationManager locationServicesEnabled])
    {
        
        [chooseView setLocationCity:@"未开启定位"];
       
        return;
        
    }
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
         [chooseView setLocationCity:@"未授权"];
        
        return;
    }

     [chooseView setLocationCity:@"正在定位"];
    
    self.isRequested = NO;
    
    [self.manager startUpdatingLocation];

}


/**
 * @brief did choose city
 */
-(void)XMCarLife_chooseCityViewDidSelectedCity:(XMCarLife_limit_cityModel *)cityModel
{
    self.cityLabel.text = cityModel.cityname;


    self.cityModel = cityModel;
    
}



#pragma mark ------- XMSetCarNumberViewControllerDelegate

- (void)setCarNumberVCDidFinish:(NSString *)carNumber
{
    
    self.carNumberLabel.text = carNumber;
    
    if(carNumber.length > 5)
    {
        
    [self.searchBtn setEnabled:YES];
        
    }
    

}


#pragma mark -- CLLocationManagerDelegate


/*
 *  locationManager:didUpdateToLocation:fromLocation:
 *
 *  Discussion:
 *    Invoked when a new location is available. oldLocation may be nil if there is no previous location
 *    available.
 *
 *    This method is deprecated. If locationManager:didUpdateLocations: is
 *    implemented, this method will not be called.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_6, __MAC_NA, __IPHONE_2_0, __IPHONE_6_0) __TVOS_PROHIBITED __WATCHOS_PROHIBITED
{
    
    XMLOG(@"location did update");
    
    if(!self.isRequested)
    {
        
        //-- encode current location
        
        _cityLabel.text = @"正在定位";
        
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        
//        [MBProgressHUD showMessage:nil];
        
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            if(error)
            {
                
                _cityLabel.text = @"定位失败";
                
                XMLOG(@"reverse failed error description: %@",error.description);
                
                return;
                
            }else
            {
                
                CLPlacemark *placemark = placemarks.firstObject;
                
                _cityLabel.text = placemark.addressDictionary[@"City"];
          
                [self.choosView setLocationCity:placemark.addressDictionary[@"City"]];
            }
            
        }];
        
        /*
         placemark.addressDictionary:
         
         City = "深圳市";
         Country = "中国";
         CountryCode = CN;
         FormattedAddressLines =     (
         "中国广东省深圳市南山区粤海街道粤兴三道6号"
         );
         Name = "中山大学深圳产学研大楼-中大产研基地";
         State = "广东省";
         Street = "粤兴三道6号";
         SubLocality = "南山区";
         Thoroughfare = "粤兴三道6号";
         **/
        
        
        //-- request data
        
        
        self.isRequested = YES;
        
        [manager stopUpdatingLocation];
    }
    
    
    
}

/*
 *  locationManager:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    
    XMLOG(@" error happened");
   
    
    _cityLabel.text = @"定位失败";
    
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    
    return UIStatusBarStyleLightContent;
    
}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
////    if (self.choosView)
////    {
////        [self.choosView removeFromSuperview];
////        
////    }
//
//
//}



@end
