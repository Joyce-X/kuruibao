//
//  XMCarInfoSettingModel.m
//  kuruibao
//
//  Created by x on 16/8/26.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 主设置界面下的车辆信息设置界面的cell对应的模型数据， 车辆建模
 属性：图片名称  标题  内容  跳转目标类信息
 
 
 ************************************************************************************************/

#import "XMCarInfoSettingModel.h"
#import "XMChooseCarViewController.h"
#import "XMQRCodeViewController.h"
#import "XMSetCarNumberViewController.h"


@implementation XMCarInfoSettingModel


- (instancetype)initWithImageName:(NSString *)imageName title:(NSString *)title content:(NSString *)content destinationClass:(Class)desClass
{
    if (self = [super init])
    {
        self.title = title;
        self.content = content;
        self.destinationClass = desClass;
    }
    
    return self;

}



 
+ (NSArray*)buildModelDataWithCarCount:(XMCar *)car
{
    NSMutableArray *result = [NSMutableArray array];
     if(!car)
     {
         //->>用户还没有选择车辆，数据都设置默认数据
         XMCarInfoSettingModel *model1_0 = [[self alloc]initWithImageName:nil title:@"选择车辆" content:@"" destinationClass:[XMChooseCarViewController class]];
         XMCarInfoSettingModel *model1_1 = [[self alloc]initWithImageName:nil title:@"硬件ID" content:nil destinationClass:[XMQRCodeViewController class]];
         XMCarInfoSettingModel *model1_2 = [[self alloc]initWithImageName:nil title:@"车牌号" content:nil destinationClass:[XMSetCarNumberViewController   class]];
         
         [result addObjectsFromArray:@[model1_0,model1_1,model1_2]];
     
     }else
     {
         //->>用户已经选择过车辆，就必定会有默认车辆，取出默认车辆数据来初始化cell的数据模型
//         XMCarModel *car = [NSKeyedUnarchiver unarchiveObjectWithFile:XIAOMI_USERCURRENTCARINFO];
         XMCarInfoSettingModel *model1_0 = [[self alloc]initWithImageName: [NSString stringWithFormat:@"%ld.jpg",(long)car.carbrandid] title: car.brandname content:car.seriesname destinationClass:[XMChooseCarViewController class]];
         model1_0.style  = car.stylename;
         XMCarInfoSettingModel *model1_1 = [[self alloc]initWithImageName:nil title:@"硬件ID" content:car.imei destinationClass:[XMQRCodeViewController class]];
         XMCarInfoSettingModel *model1_2 = [[self alloc]initWithImageName:nil title:@"车牌号" content:car.chepaino destinationClass:[XMSetCarNumberViewController   class]];
        
         [result addObjectsFromArray:@[model1_0,model1_1,model1_2]];
     }

    return result;

}




@end
