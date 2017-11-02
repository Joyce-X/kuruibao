//
//  XMSearchPetrolPreiceViewController.m
//  kuruibao
//
//  Created by x on 17/4/19.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/*
  1 judege whether the location service is enable
 
  2 judege authorize state
 
  3 request data
 
 
 **/
#import "XMSearchPetrolPreiceViewController.h"

#import "AFNetworking.h"

#import "XMPriceResultModel.h"

@import CoreLocation;

@interface XMSearchPetrolPreiceViewController ()<CLLocationManagerDelegate>

@property (nonatomic,weak)UILabel* b92PriceLabel; //-- show 92 price

@property (nonatomic,weak)UILabel* b95PriceLabel; //-- show 95 price

@property (nonatomic,weak)UILabel* b0PriceLabel; //-- show 0 price

@property (nonatomic,strong)CLLocationManager* manager;

@property (nonatomic,weak)UILabel* locationLabel;//-- show address

@property (nonatomic,weak)UILabel* timeLabe; //-- show last update time

@property (nonatomic,assign)BOOL isRequested;//-- idetifier whether has send request

@end

@implementation XMSearchPetrolPreiceViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setSubviews];
    
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"油价查询页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"油价查询页面");
    
}

- (void)setSubviews
{
    
    
    //-- back image
    UIImageView *backIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_searchPetrolPrice_background"]];
    
    backIV.frame = self.view.bounds;
    
    [self.view addSubview:backIV];
    
    //----------------------------------seperate line---------------------------------------------/
    
    //-- back btn
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"carLife_searchPetrolPrice_backBtnImage"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(30, 30));
        
        make.left.equalTo(backIV).offset(20);
        
        make.top.equalTo(backIV).offset(28 + 20);
        
    }];
    
 
    
    //----------------------------------seperate line---------------------------------------------/
    
    //-- mes label
    UILabel *mesLabel = [self  creatLabelWithFontSize:27 text:@"油价查询"];
    
//    mesLabel.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:mesLabel];
    
    [mesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backIV).offset(25);
        
        make.top.equalTo(backBtn.mas_bottom).offset(17);
        
        make.width.equalTo(155);
        
        make.height.equalTo(25);
        
    }];
    
     //----------------------------------seperate line---------------------------------------------/
    
    //-- location image
    UIImageView *locationIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_searchPetrolPrice_location"]];
    
    [self.view addSubview:locationIV];
    
    [locationIV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(mesLabel);
        
        make.top.equalTo(mesLabel.mas_bottom).offset(56);
        
        make.height.equalTo(24);
        
        make.width.equalTo(18);
        
    }];
    
     //----------------------------------seperate line---------------------------------------------/
    
    //-- locationLabel
    UILabel *locationLabel = [self creatLabelWithFontSize:18 text:@""];
    
    [self.view addSubview:locationLabel];
    
    self.locationLabel = locationLabel;
    
    [locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(locationIV);
        
        make.left.equalTo(locationIV.mas_right).offset(7);
        
        make.size.equalTo(CGSizeMake(522/2 + 40, 35/2));
        
    }];
    
    
     //----------------------------------seperate line---------------------------------------------/
    
    //-- timeLabel
    UILabel *timeLabel = [self creatLabelWithFontSize:14 text:@"最近更新时间：2017-04-25 11:11:34"];
    
    timeLabel.textColor = XMColorFromRGB(0xc5c5c5);
    
    [self.view addSubview:timeLabel];
    
    self.timeLabe = timeLabel;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(locationIV);
        
        make.top.equalTo(locationIV.mas_bottom).offset(18);
        
        make.height.equalTo(13);
        
        make.width.equalTo(419/2 + 60);
        
    }];
    
     //----------------------------------seperate line---------------------------------------------/
    
    //-- price back
    UIImageView *priceIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_searchPetrolPrice_oilBackground"]];
    
    [self.view addSubview:priceIV];
    
    [priceIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(backIV).offset(25);
        
        make.top.equalTo(timeLabel.mas_bottom).offset(47);
        
        make.height.equalTo(201);
        
        make.right.equalTo(backIV).offset(-25);
        
    }];
    
    
    CGFloat average = 201 / 4;
    
    //-- 92
    UILabel *b92Label = [self creatLabelWithFontSize:18 text:@"92#汽油"];
    
    [priceIV addSubview:b92Label];
    
    [b92Label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(priceIV).offset(16);
        
        make.height.equalTo(17);
        
        make.width.equalTo(64 + 30);
        
        make.centerY.equalTo(priceIV.mas_centerY).offset(-average);

    }];
    
    UILabel *b92 = [self creatLabelWithFontSize:18 text:@"￥/L"];
    
    [priceIV addSubview:b92];
    
    self.b92PriceLabel = b92;
    
    [b92 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(priceIV).offset(-10);
        
        make.centerY.equalTo(b92Label);
        
        make.height.equalTo(19);
        
        make.width.equalTo(198/2 + 50);
        
    }];
    
    //-- 95
    UILabel *b95Label = [self creatLabelWithFontSize:18 text:@"95#汽油"];
    
    [priceIV addSubview:b95Label];
    
    [b95Label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(priceIV).offset(16);
        
        make.height.equalTo(17);
        
        make.width.equalTo(64+30);
        
        make.centerY.equalTo(priceIV.mas_centerY);
        
    }];
    
    UILabel *b95 = [self creatLabelWithFontSize:18 text:@"￥/L"];
    
    [priceIV addSubview:b95];
    
    self.b95PriceLabel = b95;
    
    [b95 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(priceIV).offset(-10);
        
        make.centerY.equalTo(b95Label);
        
        make.height.equalTo(19);
        
        make.width.equalTo(198/2 + 50);
        
    }];
    
    
    //-- 0
    UILabel *b0Label = [self creatLabelWithFontSize:18 text:@"0#柴油"];
    
    [priceIV addSubview:b0Label];
    
    [b0Label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(priceIV).offset(16);
        
        make.height.equalTo(17);
        
        make.width.equalTo(64 + 30);
        
        make.centerY.equalTo(priceIV.mas_centerY).offset(average);
        
    }];
    
    UILabel *b0 = [self creatLabelWithFontSize:18 text:@"￥/L"];
    
    [priceIV addSubview:b0];
    
    self.b0PriceLabel = b0;
    
    [b0 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(priceIV).offset(-10);
        
        make.centerY.equalTo(b0Label);
        
        make.height.equalTo(19);
        
        make.width.equalTo(198/2 + 50);
        
    }];
    
     //----------------------------------seperate line---------------------------------------------/
    
    //-- column image
    UIImageView *columnImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_searchPetrolPrice_columnImage"]];
    
    [self.view addSubview:columnImageView];
    
    [columnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(priceIV);
        
        make.top.equalTo(priceIV.mas_bottom).offset(41);
        
        make.height.equalTo(78);
        
        make.width.equalTo(2);
        
    }];
    
     //----------------------------------seperate line---------------------------------------------/
    
    //-- label1
    UILabel *label1 = [self creatLabelWithFontSize:12 text:@"油价信息来自网络，实际价格以当地加油站为准"];
    
    label1.textColor = XMColorFromRGB(0xc5c5c5);
    
    [self.view addSubview:label1];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(columnImageView.mas_right).offset(7);
        
        make.top.equalTo(columnImageView);
        
        make.height.equalTo(12);
        
        make.width.equalTo(330);
        
    }];
    
     //----------------------------------seperate line---------------------------------------------/
    
    //-- label2
    UILabel *label2 = [self creatLabelWithFontSize:12 text:@"调价期油价信息可能会滞后1至2日"];
    
    label2.textColor = XMColorFromRGB(0xc5c5c5);
    
    [self.view addSubview:label2];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(label1);
        
        make.top.equalTo(label1.mas_bottom).offset(10);
        
        make.height.equalTo(12);
        
        make.width.equalTo(330);
        
    }];
    
     //----------------------------------seperate line---------------------------------------------/
    
    //-- label1
    UILabel *label3 = [self creatLabelWithFontSize:12 text:@"部分省市92#、95#汽油价格与93#和97#分别对应"];
    
    label3.textColor = XMColorFromRGB(0xc5c5c5);
    
    [self.view addSubview:label3];
    
    [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(label1);
        
        make.top.equalTo(label2.mas_bottom).offset(10);
        
        make.height.equalTo(12);
        
        make.width.equalTo(330);
        
    }];
    
     //----------------------------------seperate line---------------------------------------------/
    
    //-- label1
    UILabel *label4 = [self creatLabelWithFontSize:12 text:@"仅提供中国大陆油价信息，不含港、澳、台地区"];
    
    label4.textColor = XMColorFromRGB(0xc5c5c5);
    
    [self.view addSubview:label4];
    
    [label4 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(label1);
        
        make.top.equalTo(label3.mas_bottom).offset(10);
        
        make.height.equalTo(12);
        
        make.width.equalTo(330);
        
    }];
    
}

- (void)requestData
{
    
//    [MBProgressHUD showMessage:nil];
    
    if (![CLLocationManager locationServicesEnabled]) {
        
        //-- location service disable
        [self locationServiceDisable];
        
        return;
    }
    
    //-- authorization state
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        [self locationServiceDisable];
        
        _locationLabel.text = @"定位失败，应用未获取权限";
    
    }
    
    //-- authorization state
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        
        [self.manager requestWhenInUseAuthorization];
        
        return;
        
    }
    
    //--  can use location service, start to locate user location
    [self.manager startUpdatingLocation];
    
}

- (void)locationServiceDisable
{
    [MBProgressHUD hideHUD];
    
    _locationLabel.text = @"定位失败，定位服务不可用";
    
    _timeLabe.text = @"";
    
    _b92PriceLabel.text = @"获取失败";
    
    _b95PriceLabel.text = @"获取失败";
    
    _b0PriceLabel.text = @"获取失败";

    
    
}

#pragma mark --lazy

-(CLLocationManager *)manager
{
    if (!_manager)
    {
        _manager = [[CLLocationManager alloc]init];
        
        _manager.delegate = self;
    }
    
    return _manager;


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

        _locationLabel.text = @"正在定位";
                               
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        
        [MBProgressHUD showMessage:nil];
        
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            if(error)
            {
                [MBProgressHUD hideHUD];
                
                [MBProgressHUD showError:@"获取位置信息失败"];
                
                [self locationServiceDisable];
                
                _locationLabel.text = @"定位失败";
                
                XMLOG(@"reverse failed error description: %@",error.description);
                
                return;
            
            }else
            {
                
                CLPlacemark *placemark = placemarks.firstObject;
                
                _locationLabel.text = [placemark.addressDictionary[@"FormattedAddressLines"] firstObject];
                
                [self requestPriceWithProvinceName:placemark.addressDictionary[@"State"]];
                
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
    
    [self locationServiceDisable];
    
    _locationLabel.text = @"定位失败";


}



- (void)requestPriceWithProvinceName:(NSString *)name
{

    //-- request oil price
    NSString *urlStr = @"http://apis.juhe.cn/cnoil/oil_city";
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.requestSerializer.timeoutInterval = 8;
    
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    
    paras[@"key"] = @"4feeb4e9056fa26a9074e099e2cb2447";
    
    [manager POST:urlStr parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUD];
        
        _timeLabe.text = [@"最近更新时间：" stringByAppendingString:[self getCurrentTimeString]];
        
 
        XMPriceResultModel *model = [XMPriceResultModel mj_objectWithKeyValues:responseObject];
        
        XMPriceModel *priceModel = nil;
        
        for (XMPriceModel *pModel in model.result)
        {
            if ([name containsString:pModel.city])
            {
                priceModel = pModel;
                
                break;
            }
        }
        
    
        if ([priceModel.b93 containsString:@":"])
        {
            NSArray *arr = [priceModel.b93 componentsSeparatedByString:@":"];
            
            priceModel.b93 = [NSString stringWithFormat:@"(%@)%.2f",arr[0],[arr[1] floatValue]];
        }
        
        if ([priceModel.b97 containsString:@":"])
        {
            NSArray *arr = [priceModel.b97 componentsSeparatedByString:@":"];
            
            priceModel.b97 = [NSString stringWithFormat:@"(%@)%.2f",arr[0],[arr[1] floatValue]];
        }
        
        if ([priceModel.b0 containsString:@":"])
        {
            NSArray *arr = [priceModel.b0 componentsSeparatedByString:@":"];
            
            priceModel.b0 = [NSString stringWithFormat:@"(%@)%.2f",arr[0],[arr[1] floatValue]];
        }
        
        _b92PriceLabel.text = [NSString stringWithFormat:@"￥%.2f/L",[priceModel.b93 floatValue]];
        
        _b95PriceLabel.text = [NSString stringWithFormat:@"￥%.2f/L",[priceModel.b97 floatValue]];
        
        _b0PriceLabel.text = [NSString stringWithFormat:@"￥%.2f/L",[priceModel.b0 floatValue]];
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showError:@"获取油价信息失败"];
        
        XMLOG(@"获取油价信息失败 err des:%@",error);
        
        _b95PriceLabel.text = @"获取数据失败";
        
        _b92PriceLabel.text = @"获取数据失败";
        
        _b0PriceLabel.text = @"获取数据失败";


    }];

}


#pragma mark -- btn click

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark -- tool

//-- creat label
- (UILabel *)creatLabelWithFontSize:(CGFloat)size text:(NSString *)text
{
    UILabel *label = [UILabel new];
    
    label.textColor = [UIColor whiteColor];
    
    label.font = [UIFont systemFontOfSize:size];
    
    label.text = text;
    
    label.adjustsFontSizeToFitWidth = YES;
    
    return label;
    
}


- (NSString *)getCurrentTimeString
{
   
     NSDate *currentDate = [NSDate date];

    NSDateFormatter *fm = [[NSDateFormatter alloc]init];
    
    fm.dateFormat = @"yy-MM-dd HH:mm:ss";
    
    return [@" " stringByAppendingString:[fm stringFromDate:currentDate]] ;
    
    
}

@end
