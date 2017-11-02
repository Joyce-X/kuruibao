//
//  XMDVRNaviViewController.m
//  GKDVR
//
//  Created by x on 16/10/25.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMDVRNaviViewController.h"


@interface XMDVRNaviViewController ()

@end

@implementation XMDVRNaviViewController

 
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.navigationBar.hidden = YES;
    }

    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    
    self.tabBarController.tabBar.hidden = YES;


}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{

    return [[self topViewController] preferredStatusBarStyle];

}

@end
