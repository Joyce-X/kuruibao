//
//  XMSetCarNumberViewController.h
//  kuruibao
//
//  Created by x on 16/8/31.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 设置车牌号
 
 
 ************************************************************************************************/
#import <UIKit/UIKit.h>
#import "XMDetailRootViewController.h"
@interface XMSetCarNumberViewController : XMDetailRootViewController
//@property (nonatomic,weak)id delegate;

@property (nonatomic,weak)UILabel* firstName;//->>显示label

@property (nonatomic,weak)UITextField* numberTF;//->>输入框
 
@end
