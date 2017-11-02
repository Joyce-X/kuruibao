//
//  XMDetailRootViewController.h
//  kuruibao
//
//  Created by x on 16/8/31.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^setInfo)(id result);
#define backImageH  FITHEIGHT(181) //背景的高度
@interface XMDetailRootViewController : UIViewController

/**
 *  回调设置昵称
 */
@property (nonatomic,copy)setInfo completion;

/**
 *  箭头下边的提示文字
 */
@property (nonatomic,copy)NSString* message;

@property (nonatomic,weak)UIImageView* imageVIew;

 
@property (nonatomic,weak,readonly)UILabel* messageLabel;

- (void)backToLast;
@end
