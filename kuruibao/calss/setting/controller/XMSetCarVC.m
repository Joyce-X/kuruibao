//
//  XMSetCarVC.m
//  kuruibao
//
//  Created by x on 16/8/31.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMSetCarVC.h"

@implementation XMSetCarVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubViews];
}


- (void)setupSubViews
{
    self.view.backgroundColor = [UIColor whiteColor];

    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}
@end
