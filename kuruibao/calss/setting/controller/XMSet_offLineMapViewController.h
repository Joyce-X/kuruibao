//
//  XMSet_offLineMapViewController.h
//  kuruibao
//
//  Created by x on 16/9/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMSet_offLineMapViewController : UITabBarController

/**
 *  在没有离线地图的时候，点击选择城市按钮跳转到城市列表界面
 *
 *
 */

- (void)jumpToCityList;

- (void)jumpToDownloadViewController;
@end
