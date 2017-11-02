//
//  XMChooseCommonADViewController.h
//  kuruibao
//
//  Created by x on 16/11/25.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapNaviKit/AMapNaviKit.h>


@interface XMChooseCommonADViewController : UIViewController

@property (assign, nonatomic) NSInteger index;//!< 点击按钮的下标

@property (strong, nonatomic) NSArray *pois;//!< 将要展示的大头针信息数组

@end
