//
//  XMMonitorTroubleShowViewController.h
//  kuruibao
//
//  Created by x on 16/11/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMMonitorTroubleShowViewController : UIViewController

/*!
 @brief 检测到的问题项数组
 */
@property (strong, nonatomic) NSArray *troubleArray;


/*!
 @brief 显示标题信息
 */
@property (assign, nonatomic) NSInteger index;



/**
 汽车编号
 */
@property (copy, nonatomic) NSString *qicheid;

/*!
 @brief 用户编号
 */
@property (copy, nonatomic) NSString *userid;

@end
