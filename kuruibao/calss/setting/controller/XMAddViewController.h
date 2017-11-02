//
//  XMAddViewController.h
//  kuruibao
//
//  Created by x on 16/12/13.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

 
#import "XMDetailRootViewController.h"
#import "XMCar.h"
@class XMAddViewController;

@protocol XMAddViewControllerDelegate <NSObject>

@required

//->>车辆信息已经更新
- (void)carInfoDidUpdate:(XMAddViewController *)viewController;

@end
@interface XMAddViewController : XMDetailRootViewController
/**
 *  车辆数据模型
 */
@property (nonatomic,strong)XMCar* car;

@property (nonatomic,weak)id<XMAddViewControllerDelegate> delegate;

@property (assign, nonatomic) NSUInteger userCarCount; //!< 用户汽车数量
//
//@property (assign, nonatomic) BOOL isAdd;//!< 是否是添加车辆

@end
