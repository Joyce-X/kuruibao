//
//  UIViewController+alert.h
//  kuruibao
//
//  Created by x on 16/8/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (alert)
 
- (void)showAlertWithMessage:(NSString *)message btnTitle:(NSString *)btnTitle;

- (void)showAlertAnimateWithMessage:(NSString *)message btnTitle:(NSString *)btnTitle;

- (void)hideHUD;

- (BOOL)isShowing;
@end
