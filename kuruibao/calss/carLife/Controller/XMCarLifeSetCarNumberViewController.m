//
//  XMCarLifeSetCarNumberViewController.m
//  kuruibao
//
//  Created by x on 17/5/10.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLifeSetCarNumberViewController.h"

@interface XMCarLifeSetCarNumberViewController ()

@end

@implementation XMCarLifeSetCarNumberViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    self.imageVIew.frame = CGRectMake(0,0,mainSize.width,mainSize.height);
    
    self.imageVIew.image = [UIImage imageNamed:@"carLife_breakRule_background"];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

}


- (void)executeBackTask
{
    [self.view endEditing:YES];
    
    //!< appinding firstName and car number
    NSString *deliverStr = [self.firstName.text stringByAppendingString:self.numberTF.text];
    
    [self.delegate setCarNumberVCDidFinish:deliverStr];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"车生活设置车牌页面");

}
- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    MobClickBegain(@"车生活设置车牌页面");

}

@end
