//
//  XMCarInsuranceViewController.m
//  kuruibao
//
//  Created by x on 17/4/19.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarInsuranceViewController.h"

@interface XMCarInsuranceViewController ()

@end

@implementation XMCarInsuranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = XMRandomColor;
    
    UILabel *label = [UILabel new];
    
    label.numberOfLines = 0;
    
    label.text = [NSStringFromClass([self class]) stringByAppendingString:@"车辆保险"];
    label.textColor = XMRandomColor;
    
    label.font = [UIFont systemFontOfSize:50];
    
    label.frame = self.view.bounds;
    
    [self.view addSubview:label];
    
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

@end
