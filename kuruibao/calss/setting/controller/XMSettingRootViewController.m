//
//  XMSettingRootViewController.m
//  kuruibao
//
//  Created by x on 16/8/8.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMSettingRootViewController.h"

@implementation XMSettingRootViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backToMainView)];


}

- (void)backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
