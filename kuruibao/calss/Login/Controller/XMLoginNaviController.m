//
//  XMLoginNaviController.m
//  kuruibao
//
//  Created by x on 16/10/2.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMLoginNaviController.h"

@implementation XMLoginNaviController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //!<隐藏导航栏
    self.navigationBar.hidden = YES;
    

}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIViewController *topVC = self.topViewController;
    return [topVC preferredStatusBarStyle];

}
@end
