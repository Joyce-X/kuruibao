//
//  XMFindPwdViewController.h
//  KuRuiBao
//
//  Created by x on 16/6/23.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^callbackBlock)(NSString *phoneNumber,NSString *pwd);

@interface XMFindPwdViewController : UIViewController

@property (copy, nonatomic) callbackBlock finishFind;

@end
