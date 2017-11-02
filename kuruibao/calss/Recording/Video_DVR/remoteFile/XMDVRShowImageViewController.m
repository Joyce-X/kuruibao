//
//  XMDVRShowImageViewController.m
//  GKDVR
//
//  Created by x on 16/10/28.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:
    
    show the origin remote image
 
 **********************************************************/
#import "XMDVRShowImageViewController.h"
 


@interface XMDVRShowImageViewController ()


@property (nonatomic,weak)UIImageView* imageView;

@end

@implementation XMDVRShowImageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit];
 
 }

- (void)setupInit
{
    
    [self.navigationController.navigationBar setBarTintColor:XMColor(46, 46, 46)];
    
    [self.navigationController.navigationBar
     
     setTitleTextAttributes:@{ NSFontAttributeName :[UIFont systemFontOfSize:18],
                             NSForegroundColorAttributeName:[UIColor whiteColor]
                              }];
                                                                      
    
    self.title = @"预览";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnDidClick)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    imageView.image = [UIImage imageNamed:@"placeholderImage"];
    
    [self.view addSubview:imageView];
    
    self.imageView = imageView;
    
    self.view.backgroundColor  = [UIColor blackColor];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.63.9/sdcard/DVR/PIC/%@",self.imageName]];
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.imageView.image = [UIImage imageWithData:data];
            
            [MBProgressHUD hideHUDForView:self.view];
        });
 
        
    });
    
        
}


- (void)backBtnDidClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
 


@end
