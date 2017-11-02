//
//  XMAddViewController.m
//  kuruibao
//
//  Created by x on 16/12/13.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMAddViewController.h"
 
#import "XMCarInfoSettingModel.h"
#import "XMCarInfoCell.h"
#import "AFNetworking.h"
#import "XMCarModel.h"
#import "XMQRCodeViewController.h"
#import "XMQRCodeWriteInfoViewController.h"
#import "XMUser.h"

#define kCheXiaoMiUserAllCarDidUpdateNotification @"kCheXiaoMiUserAllCarDidUpdateNotification"

@interface XMAddViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy)NSString* carNumber;//!<车牌号

@property (nonatomic,copy)NSString* ID;//!<硬件编号

@property (nonatomic,strong)NSArray* dataSource;//->>数据源
@property (nonatomic,weak)UITableView* tableView;//->>展示列表
@property (nonatomic,strong)NSIndexPath * indexPath;//->>记录最后一次点击下标
@property (nonatomic,weak)UIButton* save;//->>保存按钮

//@property (nonatomic,assign)BOOL isSaved;//->>是否已经保存

@property (strong, nonatomic) XMCarModel *carModel;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (copy, nonatomic) NSString *userid;//!<用户id


//@property (nonatomic,weak)UIButton* defaultBtn;//!< 设置默认按钮




@end

@implementation XMAddViewController

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
    
    if (_carNumber && _carModel && _ID )
    {
        //!< 激活保存按钮
        _save.enabled = YES;
        _save.backgroundColor = XMGreenColor;
        
    }
    
    MobClickBegain(@"添加车辆页面");
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    MobClickEnd(@"添加车辆页面");

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
    
         //->>点击加号跳转到当前界面  有保存按钮
        self.message = @"添加车辆";
        
        //->>设置保存按钮
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
 
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    
    saveBtn.backgroundColor = XMGrayColor;
    
        [saveBtn addTarget:self action:@selector(saveBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat save_w = mainSize.width;
        
        CGFloat save_h = (60);
        
        CGFloat save_x = 0;
        
        CGFloat save_y = mainSize.height - backImageH - save_h;
        
        saveBtn.frame = CGRectMake(save_x, save_y, save_w, save_h);
        
        saveBtn.enabled = NO;
        
        [tableView addSubview:saveBtn];
        
        self.save = saveBtn;
        
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
    
}

//->>二维码扫描完成
- (void)QRCodeDidFinishScan:(NSNotification *)noti
{
    NSString *result = noti.userInfo[@"info"];
    XMCarInfoCell *cell = [_tableView cellForRowAtIndexPath:_indexPath];
    
    //!< 二维码扫描完毕，取出对应cell展示扫描结果
    cell.subLabel.text = result;
    self.ID = result;
    
}

//->>填写完车牌
- (void)didFinishWriteCarNumber:(NSNotification *)noti
{
    NSString *result = noti.userInfo[@"info"];
    XMCarInfoCell *cell = [_tableView cellForRowAtIndexPath:_indexPath];
    
    //!< 填写完车牌，取出对应cell展示车牌号码
    cell.subLabel.text = result;
    
    self.carNumber= result;
    
}




#pragma mark -- 监听按钮的点击

//->>点击保存按钮
- (void)saveBtnDidClick
{
    
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Qiche_add&Userid=%@&Imei=%@&Chepaino=%@&Brandid=%@&Seriesid=%@&Styleid=%@",self.userid,_ID,self.carNumber,_carModel.brandNumber,_carModel.serialNumber,_carModel.styleNumber];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //!< 转码
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        
        
        int result = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
        
        switch (result) {
            case 0:
                [MBProgressHUD showError:@"无效用户"];
                break;
            case -1:
                [MBProgressHUD showError:@"网络错误"];
                break;
            case -2:
                [MBProgressHUD showError:@"车牌号已经存在"];
                break;
            case -3:
                [MBProgressHUD showError:@"车牌号无效"];
                break;
                
            default:
            {
                
                [MBProgressHUD showSuccess:@"保存成功"];
                
                //!< 通知主界面从新获取用户所有车辆
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserAllCarDidUpdateNotification object:nil userInfo:nil];
                
                //->>通知代理更新界面
                if ([self.delegate respondsToSelector:@selector(carInfoDidUpdate:)])
                {
                    [self.delegate carInfoDidUpdate:self];
                }
                
                NSString *qicheId = [[NSString alloc]initWithFormat:@"%d",result];
                
                //!< 是否设置为默认车辆
                [self setThisCarDefaultAfterAddWithCarID:qicheId];
                
                //!< 默认进行激活
                [self performSelector:@selector(onLineActiveWithCarId:) withObject:qicheId afterDelay:0.7];
                //!< 返回上级界面
                [self.navigationController popViewControllerAnimated:YES];
                
                
            }
                
                break;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [MBProgressHUD showError:@"保存失败，请检查网络"];
        
    }];
    
    
    
    
}


- (void)setThisCarDefaultAfterAddWithCarID:(NSString *)carID
{
    
    if (self.userCarCount > 0)
    {
        //!< 如果用户有车辆数据就不设置默认
        return;
    }else
    {
        
        //!< 如果用户还没有车辆数据，说明第一次添加车辆，默认设置这辆车为默认车辆
        
        NSString *urlStr = [mainAddress stringByAppendingFormat:@"qiche_setfirst&Userid=%@&Qicheid=%@",self.userid, carID];
        
        //!< 转码
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            
            int result = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
            switch (result)
            {
                case 0:
                    XMLOG(@"设置默认车辆失败，网络错误");
                    break;
                case 1:
                    
                    XMLOG(@"设置默认车辆成功");
                    
                    //!< 发送通知，通知相关界面，默认车辆已经修改成功
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCheXiaoMiUserSetDefaultCarSuccessNotification object:nil];
                    
                    self.userCarCount++;//!< 做++操作，防止在当前界面继续修改车牌添加设置默认
                    
                    
                    break;
                case -1:
                    
                    XMLOG(@"设置默认车辆失败，网络错误");
                    
                    break;
                    
                default:
                    break;
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD hideHUDForView:self.view  animated:NO];
            
            XMLOG(@"设置默认车辆失败，网络错误");
        }
         ];
        
        
        
    }
    
    
    
    
    
}


//!< 在线激活的方法
- (void)onLineActiveWithCarId:(NSString *)qicheId
{
    
    //!< 在线激活 发送101指令
    
    NSString *userId = self.userid;
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"Active&Userid=%@&Qicheid=%@",userId,qicheId];
    
    [self.session GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        int statusCode = [[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding] intValue];
        
        switch (statusCode)
        {
            case 0:
                
                XMLOG(@"激活失败，网络错误");
                
                break;
                
            case -1:
                
                XMLOG(@"激活失败，终端不在线");
                break;
                
                
                
            default:
                
                //!< 激活成功，返回终端编号
                XMLOG(@"激活成功");
                
                break;
        }
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XMLOG(@"激活失败，网络错误");
    }];
    
    
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
