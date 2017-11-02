//
//  XMCompanyCarListViewController.h
//  kuruibao
//
//  Created by x on 17/5/24.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMBaseViewController.h"

#import "XMCar.h"

@interface XMCompanyCarListViewController : XMBaseViewController

@property (copy, nonatomic) NSString *carNumber;//-- 企业账号登陆时候传车牌号进来，避免选中重复车辆

@property (nonatomic,strong)XMCar* defaultCar;//->>当前默认车辆


@end
