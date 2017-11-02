//
//  XMCarLifeNaviViewController.m
//  kuruibao
//
//  Created by x on 17/5/8.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLifeNaviViewController.h"

@interface XMCarLifeNaviViewController ()

@end

@implementation XMCarLifeNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationBarHidden = YES;
    
    self.navigationBar.hidden = YES;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.topViewController preferredStatusBarStyle];
    
}


@end
