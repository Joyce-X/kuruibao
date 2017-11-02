//
//  XMDVR_ShowLocalImageViewController.h
//  kuruibao
//
//  Created by x on 16/11/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMDVR_ShowLocalImageViewController : UIViewController

@property (copy, nonatomic) NSString *imageName;//!< 显示图片名称

@property (strong, nonatomic) NSArray *dataSource;//!< 数据源

@property (assign, nonatomic) NSInteger curretIndex;

@end
