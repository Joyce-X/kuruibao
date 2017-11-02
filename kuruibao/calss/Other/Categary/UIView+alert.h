//
//  UIView+alert.h
//  kuruibao
//
//  Created by x on 16/9/30.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (alert)

- (void)showAlertWithMessage:(NSString *)message btnTitle:(NSString *)btnTitle;

 
- (BOOL)isShowing;
@end
