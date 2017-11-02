//
//  XMSetAddressViewController.m
//  kuruibao
//
//  Created by x on 16/9/7.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 设置地区的控制器
 
 
 ************************************************************************************************/
#import "XMSetAddressViewController.h"
#import "XMProvince_x.h"
#import "XMCity.h"
#import "XMArea.h"
#import "ChinaPlckerView.h"

@interface XMSetAddressViewController ()<ChinaPlckerViewDelegate>
@property (nonatomic,copy)NSString* address;
@end

@implementation XMSetAddressViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    [self setSubViews];

   ;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"设置地址页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"设置地址页面");
    
}



- (void)setSubViews
{
    self.message = @"设置地区";
    
    [ChinaPlckerView customChinaPicker:self superView:self.view];
    
    
    
}

#pragma mark --- ChinaPlckerViewDelegate

- (void)chinaPlckerViewDelegateChinaModel:(ChinaArea *)chinaModel
{
    //->>picker变化时候调用方法 获取选择的地址
    NSMutableString *address = [NSMutableString string];
    NSString *province = chinaModel.provinceModel.NAME;
    NSString *city = chinaModel.cityModel.NAME;
    NSString *area = chinaModel.areaModel.NAME;
    if ([province isEqualToString:city] && ![city isEqualToString:area])
    {
        //->>直辖市或者港澳台
        [address appendString:city];
        [address appendFormat:@" %@",area];
    }else if([province isEqualToString:city] && [city isEqualToString:area])
    {
        //->>省市区都一致的情况下
        [address appendString:area];
    
    }else
    {
        [address appendString:province];
        [address appendFormat:@" %@",city];
        [address appendFormat:@" %@",area];
    
    }
    self.address = address;
 
}

- (void)backToLast
{

    if (self.address)
    {
        self.completion(_address);//->>更新上一个界面的数据
        
        //->>保存到本地
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:_address forKey:@"userInfo_area"];
        [df synchronize];//->>立即存储
    }

    //->>返回上一界面
    [self.navigationController popViewControllerAnimated:YES];

}

@end
