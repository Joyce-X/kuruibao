//
//  XMShowCarDataViewController.m
//  kuruibao
//
//  Created by x on 16/8/31.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 如果有添加过车辆，点击车辆显示车辆信息
 如果没有添加过车辆，点击加号显示添加新的车辆
 ************************************************************************************************/
#import "XMShowCarDataViewController.h"
#import "XMCarInfoSettingModel.h"
#import "XMCarInfoCell.h"
#import "AFNetworking.h"
#import "XMCarModel.h"
#import "XMQRCodeViewController.h"
#import "XMQRCodeWriteInfoViewController.h"
#import "XMUser.h"

#define kCheXiaoMiUserAllCarDidUpdateNotification @"kCheXiaoMiUserAllCarDidUpdateNotification"

@interface XMShowCarDataViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy)NSString* carNumber;//!<车牌号

@property (nonatomic,copy)NSString* ID;//!<硬件编号

@property (nonatomic,strong)NSArray* dataSource;//->>数据源
@property (nonatomic,weak)UITableView* tableView;//->>展示列表
@property (nonatomic,strong)NSIndexPath * indexPath;//->>记录最后一次点击下标
//@property (nonatomic,weak)UIButton* save;//->>保存按钮

//@property (nonatomic,assign)BOOL isSaved;//->>是否已经保存

@property (strong, nonatomic) XMCarModel *carModel;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (copy, nonatomic) NSString *userid;//!<用户id


@property (nonatomic,weak)UIButton* defaultBtn;//!< 设置默认按钮


@property (nonatomic,weak)UIButton* updateBtn;//!< 更新按钮

//!< 刚进来显示的汽车数据，判断是否使更新按钮可以点击
@property (strong, nonatomic) XMCarModel *oldCarInfo;

@end

@implementation XMShowCarDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //->>设置子控件
    [self setupSubViews];

    //->>监听通知
    [self monitorNotification];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"详细车辆信息页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"详细车辆信息页面");
    
}



//->>设置子控件
- (void)setupSubViews
{
    
    //->>设置tableView
    UITableView *tableView = [UITableView new];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.frame = CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH);
    
    tableView.tableFooterView = [UIView new];
 
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
  
        //->>点解车辆跳转到当前界面，有设置为默认按钮  更新按钮
        self.message = self.car.chepaino;
        
        //->>添加设置默认按钮
         UIButton *defaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (self.car.isfirst)
        {
            //!< 当前车辆是默认车辆就显示灰色不可点击
             defaultBtn.backgroundColor = XMGrayColor;
            
             defaultBtn.enabled = NO;
            
        }else
        {
            //!< 否则显示绿色
             defaultBtn.backgroundColor = XMGreenColor;
        }
       
        
        [defaultBtn setTitle:@"设置默认" forState:UIControlStateNormal];
        [defaultBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
         defaultBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
         [defaultBtn addTarget:self action:@selector(defaultBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat default_w = mainSize.width / 2 - 1;
        CGFloat default_h = 60;
        CGFloat default_x = default_w + 2;
        CGFloat default_y = mainSize.height - backImageH - default_h;
        
        defaultBtn.frame = CGRectMake(default_x, default_y,default_w, default_h);
        
        [tableView addSubview:defaultBtn];
        
        self.defaultBtn = defaultBtn;

        //->>添加更新按钮
        UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         updateBtn.backgroundColor = XMGrayColor;
    
        updateBtn.enabled = NO;
    
        [updateBtn setTitle:@"保存车辆" forState:UIControlStateNormal];
    
        [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        updateBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        

         [updateBtn addTarget:self action:@selector(updateBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
        CGFloat delete_w = default_w;
        CGFloat delete_h = 60;
        CGFloat delete_x = 0;
        CGFloat delete_y = default_y;
    
        updateBtn.frame = CGRectMake(delete_x, delete_y, delete_w, delete_h);
        
        [tableView addSubview:updateBtn];

         self.updateBtn = updateBtn;
    
    
    self.oldCarInfo = [[XMCarModel alloc]init];
  
    
    _oldCarInfo.brandNumber = [NSString stringWithFormat:@"%ld",(long)_car.carbrandid];
    
    _oldCarInfo.serialNumber = [NSString stringWithFormat:@"%ld",(long)_car.carseriesid];
    
    _oldCarInfo.styleNumber = [NSString stringWithFormat:@"%ld",(long)_car.carstyleid];
    
    _oldCarInfo.ID = _car.imei;
    
    _oldCarInfo.carNumber = _car.chepaino;
    
    self.ID = _car.imei;
    
    //!< 给默认模型赋值
    self.carModel = [XMCarModel new];
    
    _carModel.brandNumber = [NSString stringWithFormat:@"%ld",(long)_car.carbrandid];
    
    _carModel.serialNumber = [NSString stringWithFormat:@"%ld",(long)_car.carseriesid];
    
    _carModel.styleNumber = [NSString stringWithFormat:@"%ld",(long)_car.carstyleid];
    
    _carModel.ID = _car.imei;
    
    _carModel.carNumber = _car.chepaino;
    
    self.carNumber = _car.chepaino;
 }


#pragma mark --- lazy

- (AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        _session.requestSerializer.timeoutInterval = 10;//!< 设置请求超时10秒
    }
    return _session;

}

- (NSString *)userid
{
    if (!_userid)
    {
        XMUser *user = [XMUser user];
        
        _userid = [NSString stringWithFormat:@"%ld",(long)user.userid];
        
    }
    
    return _userid;
}
#pragma mark --- 监听通知

//->>监听通知
- (void)monitorNotification
{
    //->>监听选择车辆的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChooseCar:) name:kCHEXIAOMISETTINGDIDCHOOSECARNOTIFICATION object:nil];
    
    //->>监听二维码扫描完成的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(QRCodeDidFinishScan:) name:kCHEXIAOMISETTINGQRCODIDIDFINISHSCANNOTIFICATION object:nil];
    
    //->>监听填写车牌完成的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWriteCarNumber:) name:kCHEXIAOMISETTINGDIDWRITECARNUMBERNOTIFICATION object:nil];
    
}

#pragma mark --- 响应通知

//->>选择车辆
- (void)didChooseCar:(NSNotification *)noti
{
    self.carModel = noti.userInfo[@"info"];
    
    if (self.car == nil)
    {
        self.car = [XMCar new];
    }
    
    //!< 将传回的carmodel数据转换成car数据，方便tableview展示
    _car.carbrandid = [_carModel.brandNumber integerValue];
    
    _car.brandname = _carModel.brand;
    
    _car.seriesname = _carModel.serial;
    
    _car.carseriesid = [_carModel.serialNumber integerValue];
    
    _car.stylename = _carModel.style;
    
    _car.carstyleid = [_carModel.styleNumber integerValue];
    
     [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    if (![_carModel.brandNumber isEqualToString:_oldCarInfo.brandNumber] ||
        ![_carModel.serialNumber isEqualToString:_oldCarInfo.serialNumber]  ||
        ![_carModel.styleNumber isEqualToString:_oldCarInfo.styleNumber]
         ) {
        
        _updateBtn.enabled = YES;
        
        _updateBtn.backgroundColor = XMGreenColor;
        
    }
    
 
}

//->>二维码扫描完成
- (void)QRCodeDidFinishScan:(NSNotification *)noti
{
    NSString *result = noti.userInfo[@"info"];
    XMCarInfoCell *cell = [_tableView cellForRowAtIndexPath:_indexPath];
    
    //!< 二维码扫描完毕，取出对应cell展示扫描结果
    cell.subLabel.text = result;
    self.ID = result;
    
    if(![self.ID isEqualToString:_oldCarInfo.ID])
    {
         _updateBtn.backgroundColor = XMGreenColor;
        
        _updateBtn.enabled = YES;
    }
    
   
}

//->>填写完车牌
- (void)didFinishWriteCarNumber:(NSNotification *)noti
{
    NSString *result = noti.userInfo[@"info"];
    XMCarInfoCell *cell = [_tableView cellForRowAtIndexPath:_indexPath];
    
    //!< 填写完车牌，取出对应cell展示车牌号码
    cell.subLabel.text = result;
    self.carNumber= result;
 
    if (![_carNumber isEqualToString:_oldCarInfo.carNumber])
    {
        _updateBtn.backgroundColor = XMGreenColor;
        
        _updateBtn.enabled = YES;
        
    }
    
}




#pragma mark -- 监听按钮的点击

//->>点击设置默认按钮
- (void)defaultBtnDidClick
{
    //!< 如果正在检测车辆
    if([UIApplication sharedApplication].networkActivityIndicatorVisible)
    {
        
        [MBProgressHUD showError:@"正在检测车辆,不能切换默认车辆"];
        
        return;
        
    }
    
    [MBProgressHUD showMessage:@"正在设置..."];
    //!< 设置为默认车辆
   
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_setfirst&Userid=%@&Qicheid=%ld",self.userid,(long)self.car.qicheid];
    
    //!< 转码
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUD];
        
        int result = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
        
        switch (result)
        {
            case 0:
                
                [MBProgressHUD showError:@"网络异常，请稍后再试"];
                
                break;
                
            case 1:
                
                [self updateLastVCInfo];
                
                [MBProgressHUD showSuccess:@"设置成功"];
                
                //!< 发送通知，通知相关界面，默认车辆已经修改成功
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserSetDefaultCarSuccessNotification object:nil];
                
                //!< 返回上级界面
                [self.navigationController popViewControllerAnimated:YES];
                
                XMLOG(@"设置默认车辆成功");
                
                break;
                
            case -1:
                
                 [MBProgressHUD showError:@"网络异常，请稍后再试"];
                
                break;
                
            default:
                
                break;
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUD];
        
         [MBProgressHUD showError:@"设置失败，请检查网络"];
        
        XMLOG(@"设置默认车辆失败");
    }
     ];
    
    
    
}

//->>点击更新按钮
- (void)updateBtnDidClick
{
    
    if([UIApplication sharedApplication].networkActivityIndicatorVisible)
    {
        [MBProgressHUD showError:@"正在检测车辆,请稍后保存"];
        
        return;
    
    }
    
    //!< 判断IMEI是否有修改
    if ([self.ID isEqualToString:_oldCarInfo.ID])
    {
        //!< 用户的IMEI没有发生变化，只修改车辆信息
        [self updateCarInfo];
        
    }else
    {
        //!< IMEI发生变化，同时更新数据
        
         [self updateCarInfo];
         [self updateIMEI];
    
    }
  
}

- (void)updateIMEI
{
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Rebind&Userid=%@&IMEI=%@&Qicheid=%ld",self.userid,self.ID,(long)self.car.qicheid];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([result isEqualToString:@"1"])
        {
            //!< 更新IMEI成功
            
           XMLOG(@"更新IMEI成功");
            
        }else
        {
             XMLOG(@"更新IMEI失败");
         
        
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
       XMLOG(@"更新IMEI失败");
    }];
    
    
    
}

//!< 更新车辆信息
- (void)updateCarInfo
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"updateqicheinfo&Userid=%@&Qicheid=%lu&Chepaino=%@&Brandid=%@&Seriesid=%@&Styleid=%@",self.userid,(long)self.car.qicheid,self.carNumber,_carModel.brandNumber,_carModel.serialNumber,_carModel.styleNumber];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//!< 转码
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        switch (result.intValue) {
            case 0:
                
                [MBProgressHUD showError:@"无效用户"];
                
                break;
            case -1:
                
                 [MBProgressHUD showError:@"网络异常"];
                
                break;
            case -2:
                 [MBProgressHUD showError:@"更新失败"];
                break;
            case 1:
                 [MBProgressHUD showError:@"更新成功"];
                
                [self updateLastVCInfo];
                
                self.message = self.carNumber;
                
                _updateBtn.enabled = NO;
                
                _updateBtn.backgroundColor = XMGrayColor;
                
                 [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserAllCarDidUpdateNotification object:nil userInfo:nil];
                 
                break;
            case -3:
                 [MBProgressHUD showError:@"车牌号已被占用"];
                break;
                
            default:
                break;
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"网络异常"];

        XMLOG(@"更新车辆信息失败");
        
    }];
    
    
    
    
}

- (void)updateLastVCInfo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(carInfoDidUpdata:)])
    {
        
        //!< 更新上一个界面的数据
        [self.delegate carInfoDidUpdata:self];
    }
    
    
}


#pragma mark --- lazy

- (NSArray *)dataSource
{
    if (!_dataSource)
    {
        //->>数据源根据car来确定数据，如果没有值，就是默认数据
        //->>如果有值的话就是响应的车辆数据
        _dataSource = [XMCarInfoSettingModel buildModelDataWithCarCount:self.car];

    }
    
    return _dataSource;

}

#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMCarInfoCell *cell = nil;
    if (indexPath.row == 0)
    {
        //->>对于第0行单独进行设置
        if(self.car)
        {
            //->>如果是点击车辆近来 单独创建cell
            cell = [tableView dequeueReusableCellWithIdentifier:@"first"];
            if (cell == nil)
            {
                cell = [[XMCarInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"first"];
            }
            cell.isFirst = YES;//->>添加系列款号等控件
            cell.car = self.car; //->>设置数据
        }else
        {
            //->>如果是点击加号近来这个页面，就使用默认数据，不添加其他控件
            cell = [XMCarInfoCell dequeueReusableCellWithTableView:tableView];
            
            //->>只设置简单的数据
            cell.carInfo = self.dataSource[indexPath.row];
        }
       
        
    }else
    {
        //->>其他行默认就行
        cell = [XMCarInfoCell dequeueReusableCellWithTableView:tableView];
        cell.carInfo = self.dataSource[indexPath.row];
    }
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0 ? 110 : 36;

}

#pragma mark --- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

     self.indexPath = indexPath;//!< 记录下标
    
    XMCarInfoSettingModel *model = self.dataSource[indexPath.row];

    UIViewController *vc = [[model.destinationClass alloc]init];
    
    if ([vc isKindOfClass:[XMQRCodeViewController class]])
    {
      XMQRCodeViewController * QRvc = (XMQRCodeViewController*)vc;
         QRvc.writeImeiBlack = ^{
             
            //!< 手动填写imei的callback  跳转过程：扫描界面 - 当前界面 - XMQRCodeWriteInfoViewController（手动填写界面）
            XMQRCodeWriteInfoViewController *vc = [XMQRCodeWriteInfoViewController new];
             
            [self.navigationController pushViewController:vc animated:NO];
        };
    }
    
    [self.navigationController pushViewController:vc animated:YES];
 
}

- (void)dealloc
{

    //!< 移除已通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    XMLOG(@"设置车辆入口界面销毁");

}
@end
