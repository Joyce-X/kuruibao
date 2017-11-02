//
//  XMTrackCell_baidu.m
//  kuruibao
//
//  Created by x on 17/6/5.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMTrackCell_baidu.h"

#import "NSString+extention.h"
#import "AFNetworking.h"
#import "BMKSportNode.h"

#import "NSDictionary+convert.h"

#import "XMUser.h"

//!< baidu
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

#define pi 3.14159265358979323846

#define degreesToRadian(x) (pi * x / 180.0)

#define radiansToDegrees(x) (180.0 * x / pi)

#define animationTime 20

/**********************************************************
 class description:自定义轨迹界面cell 使用百度地图
 
 **********************************************************/

 

@interface XMTrackCell_baidu()<BMKMapViewDelegate, BMKGeoCodeSearchDelegate>
{
    
//    BMKMapView* _mapView;
    BMKGeoCodeSearch* _geocodesearch;
    
    BMKPolyline *pathPloyline;
    
    NSMutableArray *sportNodes;//轨迹点
    NSInteger sportNodeNum;//轨迹点数
   

    CLLocationCoordinate2D startCoor;
    CLLocationCoordinate2D endCoor;

}

@property (nonatomic) BMKCoordinateRegion regon;

@property (weak, nonatomic) BMKMapView *mapView;

@property (strong, nonatomic) AFHTTPSessionManager *session;

//@property (nonatomic,weak)MAMapView* mapView;

@property (nonatomic,weak)UILabel* startAddressLabel;//!< 起始点位置

@property (nonatomic,weak)UILabel* endAddressLabel;//!< 结束点位置

@property (nonatomic,weak)UILabel* comfortScoreLabel;//!< 舒适度得分

@property (nonatomic,weak)UILabel* plusSpeedTimeLabel;//!< 急加速次数

@property (nonatomic,weak)UILabel* brakeTimeLabel;//!< 急刹车次数

@property (nonatomic,weak)UILabel* daisuTimeLabel;//!< 怠速时长

@property (nonatomic,weak)UILabel* distanceLabel;//!< 行驶里程

@property (nonatomic,weak)UILabel* oilConsumptionLabel;//!< 油耗

@property (nonatomic,weak)UILabel* trackTimeLabel;//!< 行驶时长

@property (nonatomic,weak)UIImageView* startIV;//!< 起始点图标

@property (nonatomic,weak)UILabel* jiasuLabel;//!< 显示”急加油“

@property (nonatomic,weak)UILabel* shaCheLabel;//!<  显示“急刹车”

@property (nonatomic,weak)UILabel* daiSuLabel;//!<  显示“怠速”

@property (nonatomic,weak)UIImageView* distanceIV;//!< 显示行驶里程图片

@property (nonatomic,weak)UIImageView* oilConsumptionIV;//!< 显示油耗图片

@property (nonatomic,weak)UIImageView* trackTimeIV;//!< 显示行驶时间图片

@property (nonatomic,weak)UIImageView* endIV;//!< 显示结束地址的图片

@property (weak, nonatomic) UIButton *jumpBtn;//!< 地图上覆盖的按钮，点击进行页面跳转

@property (assign, nonatomic) BOOL isStart;//!< 区分逆地理编码 开始点还是结束点

@property (assign, nonatomic) double totalDistance;

@end

@implementation XMTrackCell_baidu

//!< 计算两点间距离
CGFloat distanceBetweenPoints (CGPoint first, CGPoint second) {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
}



//!< 计算两点之间角度
CGFloat angleBetweenPoints(CGPoint first, CGPoint second) {
    CGFloat height = second.y - first.y;
    CGFloat width = first.x - second.x;
    CGFloat rads = atan(height/width);
    return radiansToDegrees(rads);
    //degs = degrees(atan((top - bottom)/(right - left)))
}

+ (instancetype)dequeueReuseableCellWith:(UITableView *)tableView
{
    static NSString *identifier = @"TrackCell_baidu";
    
    XMTrackCell_baidu *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        XMLOG(@"---------Joyce - create baidu map cell---------");
        
        
    }
    
    
    return cell;
    
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        //!< 构造搜索管理者
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        
        _geocodesearch.delegate = self;
        
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.isStart = YES;
        
        [self addSubviews];
        
        
    }
    
    return self;
    
}

- (void)addSubviews
{
    
    
    //!< 添加起始点图标
    UIImageView *startIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_ovalCircle"]];
    
    [self.contentView addSubview:startIV];
    
    self.startIV = startIV;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加起始点位置label
    UILabel *startAddress = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentLeft];
    
    startAddress.text = @"起点位置";
    
    startAddress.numberOfLines = 0;
    
    [self.contentView addSubview:startAddress];
    
    self.startAddressLabel = startAddress;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< t地图
    
    BMKMapView *mapView = [[BMKMapView alloc]init];
    
    mapView.delegate = self;
    
    mapView.showsUserLocation = NO;
    
    mapView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    mapView.layer.borderWidth = 1;
    
//    _mapView.logoPosition = 
    
    [self.contentView addSubview:mapView];
  
    self.mapView = mapView;
    
    
    //!< 在地图上添加按钮，点击时候进行页面跳转
    UIButton *jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [jumpBtn addTarget:self action:@selector(jumpBtnClick: event:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:jumpBtn];
    
    self.jumpBtn = jumpBtn;
  
    
    //!< 舒适度得分
    UILabel *comfortScore = [self labelWithFont:63 textColor:nil textAlignment:NSTextAlignmentCenter];
    
    comfortScore.text = @"00";
    
    comfortScore.adjustsFontSizeToFitWidth = YES;
    
    [self.contentView addSubview:comfortScore];
    
    self.comfortScoreLabel = comfortScore;
    
    //-----------------------------seperate line---------------------------------------//
    
    CGFloat fontSize;
    
    if (mainSize.width < 375)
    {
        fontSize = 11;
        
    }else
    {
        fontSize = 14;
        
    }
    
    //!< 急加速
    UILabel *jiasuLabel = [self labelWithFont:fontSize textColor:nil textAlignment:NSTextAlignmentLeft];
    
    jiasuLabel.text = @"急加油:";
    
    [self.contentView addSubview:jiasuLabel];
    
    self.jiasuLabel = jiasuLabel;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 急刹车
    UILabel *shaCheLabel = [self labelWithFont:fontSize textColor:nil textAlignment:NSTextAlignmentLeft];
    
    shaCheLabel.text = @"急刹车:";
    
    [self.contentView addSubview:shaCheLabel];
    
    self.shaCheLabel = shaCheLabel;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 怠速
    UILabel *daiSuLabel = [self labelWithFont:fontSize textColor:nil textAlignment:NSTextAlignmentLeft];
    
    daiSuLabel.text = @"怠   速:";
    
    [self.contentView addSubview:daiSuLabel];
    
    self.daiSuLabel = daiSuLabel;
    
    //-----------------------------seperate line---------------------------------------//
    
    
    
    //!< 显示急加油次数
    UILabel *plusSpeenLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentCenter];
    
    plusSpeenLabel.text = @"0";
    
    [self.contentView addSubview:plusSpeenLabel];
    
    self.plusSpeedTimeLabel = plusSpeenLabel;
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示急刹车次数
    UILabel *brakeLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentCenter];
    
    brakeLabel.text = @"0";
    
    [self.contentView addSubview:brakeLabel];
    
    self.brakeTimeLabel = brakeLabel;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示怠速时间
    UILabel *daisuTimeLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentCenter];
    
    daisuTimeLabel.text = @"0s";
    
    [self.contentView addSubview:daisuTimeLabel];
    
    self.daisuTimeLabel = daisuTimeLabel;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示行驶里程
    UIImageView *distanceIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_distance"]];
    
    [self.contentView addSubview:distanceIV];
    
    self.distanceIV = distanceIV;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示油耗图片
    UIImageView *oilConsumptionIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_averageOilConsumption"]];
    
    [self.contentView addSubview:oilConsumptionIV];
    
    self.oilConsumptionIV = oilConsumptionIV;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示行驶时间图片
    UIImageView *trackTimeIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_time"]];
    
    [self.contentView addSubview:trackTimeIV];
    
    self.trackTimeIV = trackTimeIV;
    
    
    //-----------------------------seperate line---------------------------------------//
    //!< 行驶距离的label
    UILabel *distanceLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentLeft];
    
    distanceLabel.text = @"00km";
    
    [self.contentView addSubview:distanceLabel];
    
    self.distanceLabel = distanceLabel;
    
    //-----------------------------seperate line---------------------------------------//
    //!< 油耗的label
    UILabel *oilConsumptionLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentLeft];
    
    oilConsumptionLabel.text = @"00.0L";
    
    [self.contentView addSubview:oilConsumptionLabel];
    
    self.oilConsumptionLabel = oilConsumptionLabel;
    
    
    //-----------------------------seperate line---------------------------------------//
    //!< 行驶时间的label
    UILabel *trackTimeLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentLeft];
    
    trackTimeLabel.text = @"01:02:03";
    
    [self.contentView addSubview:trackTimeLabel];
    
    self.trackTimeLabel = trackTimeLabel;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加显示结束图片的IV
    UIImageView *endIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_circle"]];
    
    [self.contentView addSubview:endIV];
    
    self.endIV = endIV;
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示结束地址的label
    UILabel *endAddressLabel = [self labelWithFont:14 textColor:nil textAlignment:NSTextAlignmentLeft];
    
    
    endAddressLabel.numberOfLines = 0;
    
    [self.contentView addSubview:endAddressLabel];
    
    self.endAddressLabel = endAddressLabel;
    
    //-----------------------------seperate line---------------------------------------//
    
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
 
    
    [_startAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.contentView).offset(2);
        
        make.left.equalTo(self.contentView).offset(43);
        
        make.height.equalTo(40);
        
        make.right.equalTo(self.contentView).offset(-17);
        
        
    }];
    
    
    [_startIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView).offset(18);
        
        make.size.equalTo(CGSizeMake(10, 10));
        
        make.centerY.equalTo(_startAddressLabel);
    }];
    
    
    
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(FITWIDTH(215), 100));
        
        make.right.equalTo(self.contentView).offset(-17);
        
        make.top.equalTo(_startAddressLabel.mas_bottom).offset(10);
        
    }];
    
    [_jumpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.top.bottom.equalTo(_mapView);
        
    }];
    
    
    //    CGSize size = [@"100" sizeWithFont:[UIFont systemFontOfSize:63]];
    
    [_comfortScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_mapView).offset(-7);
        
        make.left.equalTo(self.contentView).offset(10);
        
        make.height.equalTo(46);
        
        make.right.equalTo(_mapView.mas_left).offset(-13);
        
        
    }];
    
    
    CGFloat fontSize;
    
    if (mainSize.width < 375)
    {
        fontSize = 12;
        
    }else
    {
        fontSize = 14;
        
    }
    CGFloat width = [@"急加油:" getWidthWith:fontSize];
    
    [_jiasuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_comfortScoreLabel);
        
        make.top.equalTo(_comfortScoreLabel.mas_bottom).offset(13);
        
        make.size.equalTo(CGSizeMake(width, 12));
        
        
    }];
    
    [_shaCheLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_jiasuLabel);
        
        make.top.equalTo(_jiasuLabel.mas_bottom).offset(5);
        
        make.size.equalTo(_jiasuLabel);
        
    }];
    //
    [_daiSuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_shaCheLabel);
        
        make.top.equalTo(_shaCheLabel.mas_bottom).offset(5);
        
        make.size.equalTo(_shaCheLabel);
        
    }
     ];
    //
    [_plusSpeedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_jiasuLabel.mas_right);
        
        make.top.equalTo(_jiasuLabel);
        
        make.bottom.equalTo(_jiasuLabel);
        
        make.right.equalTo(_mapView.mas_left);
        
        
    }];
    //
    [_brakeTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_shaCheLabel.mas_right);
        
        make.top.equalTo(_shaCheLabel);
        
        make.bottom.equalTo(_shaCheLabel);
        
        make.right.equalTo(_mapView.mas_left);
        
        
    }];
    //
    [_daisuTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_daiSuLabel.mas_right);
        
        make.top.equalTo(_daiSuLabel);
        
        make.bottom.equalTo(_daiSuLabel);
        
        make.right.equalTo(_mapView.mas_left);
        
    }];
    
    [_distanceIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView).offset(10);
        
        make.top.equalTo(_mapView.mas_bottom).offset(7);
        
        make.size.equalTo(CGSizeMake(15, 15));
        
    }];
    
    [_oilConsumptionIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView).offset(FITWIDTH(125));
        
        make.top.equalTo(_distanceIV);
        
        make.size.equalTo(_distanceIV);
        
        
    }];
    
    [_trackTimeIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_distanceIV);
        
        make.size.equalTo(_distanceIV);
        
        make.right.equalTo(self.contentView).offset(-FITWIDTH(76));
        
        
    }];
    
    [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_distanceIV.mas_right).offset(10);
        
        make.bottom.equalTo(_distanceIV);
        
        make.height.equalTo(12);
        
        make.right.equalTo(_oilConsumptionIV.mas_left);
        
    }];
    
    
    [_oilConsumptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_oilConsumptionIV.mas_right).offset(10);
        
        make.height.equalTo(12);
        
        make.bottom.equalTo(_oilConsumptionIV);
        
        make.right.equalTo(_trackTimeIV.mas_left);
        
    }];
    
    [_trackTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(_trackTimeIV.mas_right).offset(10);
        
        make.bottom.equalTo(_trackTimeIV);
        
        make.height.equalTo(12);
        
        make.right.equalTo(self.contentView).offset(5);
        
        
    }];
    
    
    
    [_endAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView).offset(43);
        
        make.top.equalTo(_distanceIV.mas_bottom).offset(10);
        
        make.right.equalTo(_mapView);
        
        make.height.equalTo(40);
        
    }];
    
    
    [_endIV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(CGSizeMake(10, 10));
        
        make.left.equalTo(self.contentView).offset(18);
        
        make.centerY.equalTo(_endAddressLabel) ;
        
        
    }];
    
    
    
    
}

-(void)setSegmentData:(XMTrackSegmentStateModel *)segmentData
{
    
//    [_mapView viewWillAppear];
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    [_mapView removeOverlays:_mapView.overlays];
    
    
    
    _segmentData = segmentData;
    
    self.comfortScoreLabel.text = segmentData.comfortscore;
    
    self.plusSpeedTimeLabel.text = segmentData.jijiayou;
    
    self.brakeTimeLabel.text = segmentData.jishache;
    
    self.daisuTimeLabel.text = [segmentData.daisuTime stringByAppendingString:@"s"];
    
    self.distanceLabel.text = [segmentData.licheng stringByAppendingString:@"km"];
    
    self.oilConsumptionLabel.text = [segmentData.penyou stringByAppendingString:@"L"];
    
    self.trackTimeLabel.text = segmentData.xingshiTime;
    
    self.startAddressLabel.text = @"正在定位...";
    
    self.endAddressLabel.text = @"正在定位...";
    
    self.isStart = YES;
    
    [self hideLogo];//!< 隐藏百度logo
    
    //!< 解析一段行程的GPS数据，在解析之前进行判断，可能会存在数据没有上到服务器的情况
    [self searchLocation];
    
    
    
}

- (void)searchLocation
{
    
    //!< 获取一段行程内的GPS数据
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_xc_gps_byxcid&qicheid=%@&Xingchengid=%@",_qicheid,self.segmentData.xingchengid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (result.length > 2)
        {
            //!< 获取GPS数据成功
             NSArray *locationArray = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            [self parserLocationData:locationArray];
            
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        self.startAddressLabel.text = @"定位失败";
        
        self.endAddressLabel.text = @"定位失败";
        
    }];
    
    
    
    
    
    
}


-(void)willDisappare
{

    [_mapView viewWillDisappear];

}

//!< 解析请求来的位置数据
- (void)parserLocationData:(NSArray *)array
{
    
    double maxLatitude = 0;
    
    double minLatitude = 91;
    
    double maxLongitude = 0;
    
    double minLongitude = 181;
    
   
    sportNodes = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dic in array)
    {
        NSDictionary * newDic = [NSDictionary nullDic:dic];
        
        
        double latitude = [newDic[@"locationy"] doubleValue];
        
        double longitude = [newDic[@"locationx"] doubleValue];
        
        //-- 求最大经度
        maxLongitude = MAX(maxLongitude, longitude);
        
        //-- 求最大纬度
        maxLatitude = MAX(maxLatitude, latitude);
        
        //-- 求最小经度
        minLongitude = MIN(minLongitude, longitude);
        
        //-- 求最小纬度
        minLatitude = MIN(minLatitude, latitude);
        
        BMKSportNode *node = [BMKSportNode new];
        
        node.coordinate = CLLocationCoordinate2DMake(latitude,longitude);
        
        
        [sportNodes addObject:node];
        
        
              
    }
    
    sportNodeNum = sportNodes.count;
    
    //-- 计算地图显示区域regon
    
    //-- 经度范围
    double longitudeScope = maxLongitude - minLongitude;
    
    //-- 纬度范围
    double latitudeScope = maxLatitude - minLatitude;
    
    BMKCoordinateSpan span;
    
    span.latitudeDelta = latitudeScope;
    
    span.longitudeDelta = longitudeScope;
    
    
    //-- 计算中心经纬度坐标点
    double centerX = minLongitude + longitudeScope/2;
    
    double centerY = minLatitude + latitudeScope/2;
    
    BMKCoordinateRegion regon;
    
    regon.span = span;
    
    regon.center = CLLocationCoordinate2DMake(centerY, centerX);
    
    self.regon = regon;
    
    CLLocationCoordinate2D  *paths = (CLLocationCoordinate2D *)malloc(sportNodeNum * sizeof(CLLocationCoordinate2D));;
    
    for (NSInteger i = 0; i < sportNodeNum; i++) {
        
        BMKSportNode *node = sportNodes[i];
        
        paths[i] = node.coordinate;
        
    }
    
    pathPloyline = [BMKPolyline polylineWithCoordinates:paths count:sportNodeNum];
    
    [_mapView addOverlay:pathPloyline];
    
    free(paths);//!< 释放内存
    
//    //!< 添加起点
    BMKPointAnnotation *startAnno = [[BMKPointAnnotation alloc]init];
    
    CLLocationCoordinate2D coorS = [sportNodes.firstObject coordinate];
    
    startAnno.coordinate = coorS;
    
    startAnno.title = @"start";
    
    //!< 添加终点
    BMKPointAnnotation *endAnno = [[BMKPointAnnotation alloc]init];
    
    CLLocationCoordinate2D coorE = [sportNodes.lastObject coordinate];
    
    endAnno.coordinate = coorE;
    
    endAnno.title = @"end";
    
    [_mapView addAnnotations:@[startAnno,endAnno]];
    
    //!< 对起点和终点进行逆地理编码
    
    BMKReverseGeoCodeOption *startRequest = [[BMKReverseGeoCodeOption alloc]init];
    
    startRequest.reverseGeoPoint = coorS;
    
    
    
    startCoor = coorS;
    
    endCoor = coorE;
    
    XMLOG(@"---------sx:%f  sy:%f---------",coorS.longitude,coorS.latitude);
    
    XMLOG(@"---------ex:%f  ey:%f---------",coorE.longitude,coorE.latitude);
    
    [_geocodesearch reverseGeoCode:startRequest];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
         [_mapView setRegion:self.regon animated:YES];
        
        
        
    });
   

}


#pragma mark -------------- AMapSearchAPIDelegate

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
     XMLOG(@"---------rx:%f  ry:%f---------",result.location.longitude,result.location.latitude);
    
    if (self.isStart)
    {
        self.isStart = NO;
        
        if (error)
        {
            self.startAddressLabel.text = @"定位失败";
        }else
        {
        
            //!< 起点位置
            self.startAddressLabel.text = result.address;
        
        }
        
        //!< 逆地理编码起点后， 编码终点
        BMKReverseGeoCodeOption *endRequest = [[BMKReverseGeoCodeOption alloc]init];
        
        endRequest.reverseGeoPoint = endCoor;
        
        [_geocodesearch reverseGeoCode:endRequest];

        
        
    }else
    {
    
        if (error)
        {
            self.endAddressLabel.text = @"定位失败";
        }else
        {
            
            //!< 起点位置
            self.endAddressLabel.text = result.address;
            
        }

    
    
    }
    
    
}




#pragma mark ---------- lazy
-(AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        _session.requestSerializer.timeoutInterval = 10;
    }
    return _session;
    
}



#pragma mark -------------- tool method

//!< 创建label

- (UILabel *)labelWithFont:(float)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [UILabel new];
    
    label.backgroundColor = [UIColor clearColor];
    
    label.textAlignment = textAlignment;
    
    label.textColor = [UIColor whiteColor];
    
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    
    label.font = [UIFont systemFontOfSize:font];
    
    return label;
}

#pragma mark -------------- MAMapViewDelegate



//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    
        BMKPolylineView *view = [[BMKPolylineView alloc]initWithPolyline:overlay];
        
        view.strokeColor = XMColor(100, 170, 216);
    
        view.lineWidth = 2;
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [_mapView zoomOut];
            
        });
        
        return view;
    
}


// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    
        //-- 起点终点对应的标注
        
        BMKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"point"];
        
        if (view == nil)
        {
            view = [[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"point"];
            
        }
        
    if ([annotation.title isEqualToString:@"start"])
    {
        view.image = [UIImage imageNamed:@"annotation_start"];
        
        NSLog(@"开始标注");
        
        
    }else
    {
        NSLog(@"结束标注");
        view.image = [UIImage imageNamed:@"annotation_end"];
        
        
    }
    
        view.centerOffset = CGPointMake(0, -12);
    
        view.canShowCallout = NO;
    
        return view;
        
   
}


- (void)jumpBtnClick:(UIButton *)sender event:(UIEvent *)event
{
    if (_clickEnlarge)
    {
        _clickEnlarge(sender,event);//!< 回调通知控制器
    }
    
    [MobClick event:@"Map_Thumbnail"];
    XMLOG(@"---------youmeng--点击缩略图---------");
    
}

/**
 隐藏logo
 */
- (void)hideLogo
{
    
    for (UIView *subview in _mapView.subviews)
    {
        if (subview.subviews.count > 0)
        {
            for (UIView *s in subview.subviews)
            {
                
                XMLOG(@"Joyce-----ss----%@---------",s);
                
                if ([s isKindOfClass:[UIImageView class]])
                {
                    s.hidden = YES;
                }
                
            }
        }
        
    }
    
    

    
}


- (void)dealloc
{
    
    if (_mapView)
    {
        _mapView = nil;
        
        _mapView.delegate = nil;
    }

    XMLOG(@"---------Joyce dealloc---------");

}


@end
