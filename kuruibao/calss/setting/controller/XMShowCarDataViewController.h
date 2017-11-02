//
//  XMShowCarDataViewController.h
//  kuruibao
//
//  Created by x on 16/8/31.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMDetailRootViewController.h"
#import "XMCar.h"
@class XMShowCarDataViewController;
/**
typedef  NS_ENUM(NSInteger,XMShowCarDataType)
{
    
    XMShowCarDataTypeAdd,//->>添加车辆
    XMShowCarDataTypeEdite //->>展示车辆

};
 */
@protocol XMShowCarDataViewControllerDelegate <NSObject>

@required

//->>车辆信息已经更新
- (void)carInfoDidUpdata:(XMShowCarDataViewController *)viewController;

@end

@interface XMShowCarDataViewController : XMDetailRootViewController

/**
 *  车辆数据模型
 */
@property (nonatomic,strong)XMCar* car;

@property (nonatomic,weak)id<XMShowCarDataViewControllerDelegate> delegate;

//@property (assign, nonatomic) NSUInteger userCarCount; //!< 用户汽车数量

//@property (assign, nonatomic) BOOL isAdd;//!< 是否是添加车辆


@end
