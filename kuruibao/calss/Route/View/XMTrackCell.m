
//  XMTrackCell.m
//  kuruibao
//
//  Created by x on 16/11/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:自定义轨迹界面cell
 
 **********************************************************/

#import "XMTrackCell.h"
//#import <AMapFoundationKit/AMapFoundationKit.h>
#import "NSString+extention.h"
#import "AFNetworking.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "XMTrackLocationModel.h"
#import "NSDictionary+convert.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>


#import "XMUser.h"


@interface XMTrackCell()<MAMapViewDelegate,AMapSearchDelegate>

@property (strong, nonatomic) AMapSearchAPI *search;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (nonatomic,weak)MAMapView* mapView;

@property (nonatomic,weak)UILabel* startAddressLabel;//!< 起始点位置

@property (nonatomic,weak)UILabel* endAddressLabel;//!< 结束点位置

@property (nonatomic,weak)UILabel* comfortScoreLabel;//!< 舒适度得分

@property (nonatomic,weak)UILabel* plusSpeedTimeLabel;//!< 急加速次数

@property (nonatomic,weak)UILabel* brakeTimeLabel;//!< 急刹车次数

@property (nonatomic,weak)UILabel* daisuTimeLabel;//!< 怠速时长

@property (nonatomic,weak)UILabel* distanceLabel;//!< 行驶里程

@property (nonatomic,weak)UILabel* oilConsumptionLabel;//!< 油耗

@property (nonatomic,weak)UILabel* trackTimeLabel;//!< 行驶时长

//@property (nonatomic,weak)UILabel* trackStatusLabel;//!< 行程状态

//-----------------------------seperate line---------------------------------------//

//@property (nonatomic,weak)UIView* line;//!< 线条

@property (nonatomic,weak)UIImageView* startIV;//!< 起始点图标

@property (nonatomic,weak)UILabel* jiasuLabel;//!< 显示”急加油“

@property (nonatomic,weak)UILabel* shaCheLabel;//!<  显示“急刹车”

@property (nonatomic,weak)UILabel* daiSuLabel;//!<  显示“怠速”

@property (nonatomic,weak)UIImageView* distanceIV;//!< 显示行驶里程图片

@property (nonatomic,weak)UIImageView* oilConsumptionIV;//!< 显示油耗图片

@property (nonatomic,weak)UIImageView* trackTimeIV;//!< 显示行驶时间图片

@property (nonatomic,weak)UIImageView* endIV;//!< 显示结束地址的图片

@property (weak, nonatomic) UIButton *jumpBtn;//!< 地图上覆盖的按钮，点击进行页面跳转

@end

@implementation XMTrackCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (instancetype)dequeueReuseableCellWith:(UITableView *)tableView
{
    static NSString *identifier = @"TrackCell";
    
    XMTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    
    return cell;


}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubviews];
        
        
    }
    
    return self;

}

- (void)addSubviews
{
     //!< 添加线条
    
//    UIView *line = [[UIView alloc]init];
//    
//    line.backgroundColor = [UIColor whiteColor];
//    
//    
//    [self.contentView addSubview:line];
//    
//    self.line = line;
    
    //-----------------------------seperate line---------------------------------------//
    
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
    
    MAMapView *mapView = [[MAMapView alloc]init];
    
    mapView.delegate = self;
    
    mapView.showsCompass = NO;
    
    mapView.showsScale = NO;
        
    mapView.scrollEnabled = NO;
    
    mapView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    mapView.layer.borderWidth = 1;
    
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
    
//    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
//       
//        make.top.equalTo(self.contentView).offset(3);
//        
//        make.left.equalTo(self.contentView).offset(14);
//        
//        make.right.equalTo(self.contentView).offset(-14);
//        
//        make.height.equalTo(3);
//        
//    }];

    
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

    _segmentData = segmentData;

    self.comfortScoreLabel.text = segmentData.comfortscore;
    
   
    
    self.plusSpeedTimeLabel.text = segmentData.jijiayou;
    
    self.brakeTimeLabel.text = segmentData.jishache;
    
    self.daisuTimeLabel.text = [segmentData.daisuTime stringByAppendingString:@"s"];
//
    self.distanceLabel.text = [segmentData.licheng stringByAppendingString:@"km"];
    
    self.oilConsumptionLabel.text = [segmentData.penyou stringByAppendingString:@"L"];
//
    self.trackTimeLabel.text = segmentData.xingshiTime;
    
    self.startAddressLabel.text = @"正在定位...";
    
    self.endAddressLabel.text = @"正在定位...";
    
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
            
            
        }else
        {
            //!< 获取GPS数据失败
            self.startAddressLabel.text = @"该行程未上报行程数据";
            
            self.endAddressLabel.text = @"该行程未上报行程数据";
            
            
           CGFloat latitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"TRACK_LATITUDE"];
            
           CGFloat longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"TRACK_LONGITUDE"];
            
            if (latitude > 0 && longitude > 0)
            {
                
                //!< 如果有定位信息就显示定位位置
                MAPointAnnotation *anno = [[MAPointAnnotation alloc]init];
                
                anno.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                
                 _mapView.zoomLevel = 5;
                
                [_mapView showAnnotations:@[anno] animated:YES];
                [_mapView removeAnnotations:@[anno]];
               
                
                
            }else
            {
                //!< 没有获取到定位信息的情况,就显示深圳位置
               
                MAPointAnnotation *anno_moLocation = [[MAPointAnnotation alloc]init];
                
                anno_moLocation.coordinate =  AMapCoordinateConvert(CLLocationCoordinate2DMake(22.329, 114.1), AMapCoordinateTypeGPS);
                
                _mapView.zoomLevel = 7;
                
                [_mapView showAnnotations:@[anno_moLocation] animated:YES];
            
            
            }
            
         
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        self.startAddressLabel.text = @"定位失败";
        
        self.endAddressLabel.text = @"定位失败";
        
    }];
    
    
    
    
    
    
}


//!< 解析请求来的位置数据
- (void)parserLocationData:(NSArray *)array
{
    
     NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:array.count];
    
    //-- 删除所有遮盖
    [_mapView removeOverlays:_mapView.overlays];
    
     //-- 取出路径所有形状点个数
    NSInteger count = array.count;
    
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++)
    {
        NSDictionary *dic = [NSDictionary nullDic:array[i]];
        //!< 返回的是百度的经纬度需要转换
        
        XMTrackLocationModel *model = [XMTrackLocationModel new];
        
        CLLocationCoordinate2D baiduLocation = CLLocationCoordinate2DMake([dic[@"locationy"] doubleValue], [dic[@"locationx"] doubleValue]);
        
        CLLocationCoordinate2D gaodeLocation = AMapCoordinateConvert(baiduLocation, AMapCoordinateTypeBaidu);
        
        //!< 近似转换
        
//        CLLocationCoordinate2D gaodeLocation  = CLLocationCoordinate2DMake(temLocation.latitude + 0.0060, temLocation.longitude += 0.0065);
//        gaodeLocation.longitude += 0.0065;
//        
//        gaodeLocation.latitude += 0.0060;
        
        model.locationx = gaodeLocation.longitude;
        
        model.locationy = gaodeLocation.latitude;
        
        [arrM addObject:model];
        
        coords[i].latitude = model.locationy;
        coords[i].longitude = model.locationx;
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:count];
    
    [_mapView addOverlay:polyline];
    
    //-- 释放内存
    free(coords);
   
    AMapReGeocodeSearchRequest *startRequest = [[AMapReGeocodeSearchRequest alloc]init];
    
    //!< 起点
    XMTrackLocationModel *startModel = [arrM firstObject];
    startRequest.location = [AMapGeoPoint locationWithLatitude:startModel.locationy longitude:startModel.locationx];
    
    startRequest.radius = 1000;
    
    [self.search AMapReGoecodeSearch:startRequest];
    
    AMapReGeocodeSearchRequest *endRequest = [[AMapReGeocodeSearchRequest alloc]init];
 
    XMTrackLocationModel *endModel = [arrM lastObject];
    
    endRequest.location = [AMapGeoPoint locationWithLatitude:endModel.locationy longitude:endModel.locationx];
    
    endRequest.radius = 1001;
    
    [self.search AMapReGoecodeSearch:endRequest];
    
    MAPointAnnotation *anno_start = [[MAPointAnnotation alloc]init];
    
    anno_start.title = @"start";
    
    anno_start.coordinate = CLLocationCoordinate2DMake(startModel.locationy, startModel.locationx);
    
    
    MAPointAnnotation *anno_end = [[MAPointAnnotation alloc]init];
    
    anno_end.title = @"end";
    
    anno_end.coordinate = CLLocationCoordinate2DMake(endModel.locationy, endModel.locationx);
    
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    [_mapView addAnnotations:@[anno_start,anno_end]];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
 
//        [_mapView showOverlays:@[polyline] animated:YES];
        
        [_mapView showOverlays:@[polyline] edgePadding:UIEdgeInsetsMake(30, 30, 30, 20) animated:YES];
        

    });
 
    
    
    
}


#pragma mark -------------- AMapSearchAPIDelegate

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    if (response.regeocode.formattedAddress.length == 0)
    {
        self.startAddressLabel.text = @"定位失败";
        
         //!< 终点位置
        self.endAddressLabel.text = @"定位失败";
        
        [_mapView removeAnnotations:_mapView.annotations];
                 
        [_mapView removeOverlays:_mapView.overlays];
        
        return;
    }
    
    if (request.radius == 1000)
    {
        
        //!< 起点位置
        self.startAddressLabel.text = response.regeocode.formattedAddress;
        
    }else
    {
        //!< 终点位置
        self.endAddressLabel.text = response.regeocode.formattedAddress;
    
    }
    

  

}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{

    if([request isKindOfClass:[AMapReGeocodeSearchRequest class]])
    {
         AMapReGeocodeSearchRequest * newRequest = request;
        
        if (newRequest.radius == 1000)
        {
             
            //!< 起点位置
            self.startAddressLabel.text = @"定位失败";
            
        }else
        {
            //!< 终点位置
            self.endAddressLabel.text = @"定位失败";
            
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


-(AMapSearchAPI *)search
{
    if (!_search)
    {
        _search = [[AMapSearchAPI alloc]init];
        
        _search.delegate = self;
    }

    return _search;
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



- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
    static NSString*identifier_AnnoView = @"identifier_AnnoView";
    
    MAAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier_AnnoView];

    if (view == nil) {
        
        view = [[MAAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier_AnnoView];
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
        
        view.centerOffset = CGPointMake(0, -15);
        
        view.canShowCallout = NO;
    
     return view;
    
}

/**
 *  添加遮盖返回遮盖样式
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    //    if ([overlay isKindOfClass:[SelectableOverlay class]])
    //    {
    //        SelectableOverlay * selectableOverlay = (SelectableOverlay *)overlay;
    //        id<MAOverlay> actualOverlay = selectableOverlay.overlay;
    //
    //        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:actualOverlay];
    //
    //        polylineRenderer.lineWidth = 3.f;
    //        //        polylineRenderer.strokeColor = selectableOverlay.isSelected ? selectableOverlay.selectedColor : selectableOverlay.regularColor;
    //        polylineRenderer.strokeColor = [UIColor redColor];
    //        return polylineRenderer;
    //    }
    //
    //    return nil;
    MAPolylineRenderer *render  =[[MAPolylineRenderer alloc]initWithOverlay:overlay];
    
    render.lineWidth  = 4;
    
    render.fillColor = [UIColor greenColor];
    
    return render;
    
}

- (void)jumpBtnClick:(UIButton *)sender event:(UIEvent *)event
{
    if (_clickEnlarge)
    {
         
        _clickEnlarge(sender,event);//!< 回调通知控制器
    }
    
}


@end
