//
//  XMSearchBreakRulesViewController.m
//  kuruibao
//
//  Created by x on 17/4/19.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMSearchBreakRulesViewController.h"

#import "XMCarLifeSetCarNumberViewController.h"

#import "AFNetworking.h"

#import "XMCarLife_Break_ProvinceModel.h"

#import "XMCarLife_breakRules_ShowViewController.h"

#define appkey @"d45a1baf1e156842d8011d6ade93d1ae"

#define slideUpOffset 200

@interface XMSearchBreakRulesViewController ()<XMSetCarNumberViewControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;

@property (weak, nonatomic) IBOutlet UIButton *seasrchBtn;

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet UITextField *engineTF;

@property (weak, nonatomic) IBOutlet UITextField *classTF;

@property (copy, nonatomic) NSString *carNumber;//!< save car number

@property (strong, nonatomic) AFHTTPSessionManager *session;

@property (strong, nonatomic) NSData *responseData;//!< request city result

@property (weak, nonatomic) UIView *bottomView;

@property (weak, nonatomic) UIPickerView *picker;

@property (strong, nonatomic) NSArray *models;

@property (strong, nonatomic) XMCarLife_Break_ProvinceModel *oldModel;

@property (copy, nonatomic) NSString *cityCode;
@end

@implementation XMSearchBreakRulesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self requestCityData];
    
    [self setSubviews];
    
    [MBProgressHUD showMessage:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUD];
        
    });
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"违章查询页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"违章查询页面");
    
}


- (void)setSubviews
{
    
    //!< set background
    UIImageView *iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_breakRule_background"]];
    
    iv.frame = CGRectMake(0, 0, mainSize.width, mainSize.height);
    
    [self.view insertSubview:iv atIndex:0];
    
    //!< disable search btn
//    [self.seasrchBtn setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkDidChanged:) name:XMNetWorkDidChangedNotification object:nil];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark ------- lazy


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

#pragma mark ------- XMSetCarNumberViewControllerDelegate
 
- (void)setCarNumberVCDidFinish:(NSString *)carNumber
{
    
    self.carNumberLabel.text = carNumber;
    
//    [self.seasrchBtn setEnabled:YES];

}


#pragma mark ------- btn click
/**
 * @brief search btn click
 */
- (IBAction)searchBtnClick {
    
    
    XMLOG(@"***searchBnClick");
    if (self.cityLabel.text.length == 0)
    {
        [MBProgressHUD showSuccess:@"请选择城市"];
        
        return;
    }
    
    if (self.carNumberLabel.text.length == 0)
    {
        [MBProgressHUD showSuccess:@"请填写车牌"];
        
        return;
    }
    
    if (self.engineTF.text.length == 0)
    {
        [MBProgressHUD showSuccess:@"请输入发动机号"];
        
        return;
    }
    
    if (self.classTF.text.length == 0)
    {
        [MBProgressHUD showSuccess:@"请输入车架号"];
        
        return;
    }
    
    //!< request break message not city message......
    [MBProgressHUD showMessage:nil];
    
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    
    paras[@"dtype"] = @"json";
    
    paras[@"key"] = appkey;
    
    paras[@"city"] = self.cityCode;
    
    paras[@"hphm"] = [self.carNumberLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
    
    paras[@"engineno"] = self.engineTF.text;
    
    paras[@"classno"] = self.classTF.text;
    
    [self.session POST:@"http://v.juhe.cn/wz/query" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [MBProgressHUD hideHUD];
        
//        [MBProgressHUD showSuccess:@"success"];
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        if ([dic[@"resultcode"] intValue] != 200)
        {
            [MBProgressHUD showError:@"查询失败"];
            
            return ;
        }
        
        NSArray *lists = [dic[@"result"] objectForKey:@"lists"];
        
        
        XMCarLife_breakRules_ShowViewController *vc = [XMCarLife_breakRules_ShowViewController new];
        
        vc.lists = lists;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUD];
        
        [MBProgressHUD showSuccess:@"网络超时"];
        
    }];
    
    
}

- (IBAction)backBtnClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)certainBtnClick
{
    
    
    NSInteger  firstComponentIndex = [_picker selectedRowInComponent:0];
    
    NSInteger  secondComponentIndex = [_picker selectedRowInComponent:1];
    
    XMLOG(@"---------%lu,%lu---------",firstComponentIndex,secondComponentIndex);
    
    
    XMCarLife_Break_ProvinceModel *model = _models[firstComponentIndex];
    
    XMCarLife_Break_CityModel *cityModel = model.citys[secondComponentIndex];
    
    self.cityLabel.text = cityModel.city_name;
    
    self.cityCode = cityModel.city_code;
    
    [self.bottomView removeFromSuperview];
    
    
    
}

- (void)cancleBtnClick
{
    [self.bottomView removeFromSuperview];
    
}


#pragma mark ------- gesture
- (IBAction)chooseCity:(UITapGestureRecognizer *)sender {
    
    XMLOG(@"***chooseCity");
    
    //!<judge network
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [MBProgressHUD showError:@"无网络连接"];
        
        return;
    }
    
    if (self.responseData)
    {
        //!< if city data exist load picker View
        
        [self showPicker];
        
        
    }else
    {
        //!< request city data
        
        [MBProgressHUD showMessage:nil];
        
        NSMutableDictionary *paras = [NSMutableDictionary dictionary];
        
        paras[@"key"] = appkey;
        
        [self.session POST:@"http://v.juhe.cn/wz/citys" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [MBProgressHUD hideHUD];
            
            //!< to do  show picker view.....
            [self showPicker];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [MBProgressHUD hideHUD];
            
            [MBProgressHUD showError:@"网络超时"];
            
        }];
        
    
    }
    
}

- (IBAction)serCarNumber:(id)sender {
    
    XMLOG(@"***serCarNumber");
    XMCarLifeSetCarNumberViewController *setNumberVC = [XMCarLifeSetCarNumberViewController new];
    
    setNumberVC.delegate = self;
    
    [self.navigationController pushViewController:setNumberVC animated:YES];
    
}

- (void)requestCityData
{
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    
    paras[@"key"] = appkey;
    
    [self.session POST:@"http://v.juhe.cn/wz/citys" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        XMLOG(@"---------request city data success---------");
        
        self.responseData = responseObject;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
       XMLOG(@"---------request city data failed---------");
        
    }];
    
    
}

#pragma mark ------- UIPickerViewDelegate,UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{

    return 2;

}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{

    if (component == 0)
    {
        return self.models.count;
        
    }else
    {
    
        NSInteger rows = [pickerView selectedRowInComponent:0];
        
        XMCarLife_Break_ProvinceModel *model = self.models[rows];
        
        self.oldModel = model;
        
        return model.citys.count;
    
    }

}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        XMCarLife_Break_ProvinceModel *model = self.models[row];
        
        return model.province;
        
    }else
    {
        
//        NSInteger index = [pickerView selectedRowInComponent:0];
        
//        XMCarLife_Break_ProvinceModel *model = self.models[index];
        
        NSInteger count = self.oldModel.citys.count;
        
        if (row >= count)
        {
            row = 0;
        }
        
        
        XMCarLife_Break_CityModel *cityModel = self.oldModel.citys[row];
        
        return cityModel.city_name;

    }
    

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

    if (component == 0)
    {
        XMLOG(@"---------province:%@---------",[self.models[row] province]);
        
        [pickerView reloadComponent:1];
        
        
    }else
    {
        
//        NSInteger index = [pickerView selectedRowInComponent:0];
//        
//        XMCarLife_Break_ProvinceModel *model = self.models[index];
//        
//        XMCarLife_Break_CityModel *cModel = model.citys[row];
        
//        XMLOG(@"---------city:%@- citycode:%@--------",cModel.city_name,cModel.city_code);
    
    }
    
    
    
}

#pragma mark ------- setter

- (void)setResponseData:(NSData *)responseData
{
    _responseData = responseData;
    
    NSDictionary *dic_all = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    
    NSDictionary *dic_result = dic_all[@"result"];
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:dic_result.allKeys.count];
    
    for (NSString *key in dic_result.allKeys)
    {
        NSDictionary *dic_pro = dic_result[key];
        
        XMCarLife_Break_ProvinceModel *model = [XMCarLife_Break_ProvinceModel mj_objectWithKeyValues:dic_pro];
        
        [arrM addObject:model];
    }
    
    self.models = [arrM copy];

}

#pragma mark ------- system


- (void)netWorkDidChanged:(NSNotification *)noti
{
    
    XMLOG(@"---------network did change  %@---------",noti.userInfo[@"info"]);
    
    if ([noti.userInfo[@"info"] intValue] > 0)
    {
        //!< network resume
        if (self.responseData == nil)
        {
            //!< request data
            [self requestCityData];
        }
    }
    
}
/**
 *  键盘即将弹出
 */
- (void)keyboardWillShow:(NSNotification *)noti
{
    if (self.view.y != 0)return;
    
    XMLOG(@"%@",noti.userInfo);
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        
        self.view.y -= slideUpOffset;
        
    }];
    
    
}



/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHide:(NSNotification *)noti
{
    if (self.view.y == 0)return;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.y += slideUpOffset;
        
    }];
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;

}


- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

//-----------------------------seperate line---------------------------------------//

- (void)showPicker
{
    
    UIView *bottomView = [UIView new];
    
//    bottomView.backgroundColor = [UIColor redColor];
    
//    bottomView.frame = CGRectMake(0, mainSize.height - 216 - 10, mainSize.width, 226);
    bottomView.frame = CGRectMake(0, 0, mainSize.width, mainSize.height);

    [self.view addSubview:bottomView];
    
    self.bottomView  = bottomView;
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    cancleBtn.frame = CGRectMake(0, 0, mainSize.width, mainSize.height - 226);
    
    [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:cancleBtn];
    
    //!< contain picker and certain btn
    UIView *bView = [UIView new];
    
    bView.backgroundColor = [UIColor whiteColor];
    
    bView.frame = CGRectMake(0, mainSize.height - 216 - 10, mainSize.width, 226);
    
    [bottomView addSubview:bView];
    
  
    
    
    UIPickerView *picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 10, mainSize.width, 216)];
    
    picker.delegate = self;
    
    picker.dataSource = self;
    
//    picker.backgroundColor = [UIColor orangeColor];
    
    [bView addSubview:picker];
    
    self.picker = picker;
    
    UIButton *certainBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [certainBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    certainBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    [certainBtn addTarget:self action:@selector(certainBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    certainBtn.frame = CGRectMake(mainSize.width - 55, 8, 40, 25);
    
    [bView addSubview:certainBtn];
    
}

#pragma mark ------- system

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [self.view endEditing:YES];
    
    if (self.bottomView)
    {
        [self.bottomView removeFromSuperview];
    }

}


@end
