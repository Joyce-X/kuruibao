//
//  AppDelegate.h
//  kuruibao
//
//  Created by x on 16/6/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMSlideViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,weak)UITabBarController* tabBarController;
@property (nonatomic,weak)XMSlideViewController* sliderVC;

@property (assign, nonatomic) BOOL allowRotation;

@end

