//
//  XMCarInfoViewController.h
//  kuruibao
//
//  Created by x on 16/8/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMDetailRootViewController.h"

typedef void(^writeBlock) ();

@interface XMQRCodeViewController : XMDetailRootViewController

@property (copy, nonatomic) writeBlock writeImeiBlack;

@end
