//
//  OfflineDetailViewController.h
//  OfficialDemo3D
//
//  Created by xiaoming han on 14-5-5.
//  Copyright (c) 2014年 songjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

@class XMDownLoadViewController;

@protocol XMDownLoadViewControllerDelegate <NSObject>

@optional

/**
 *  将要下载一个项目的时候调用代理方法
 *
 * para : 要下载的项目
 */

- (void)downloadViewController:(XMDownLoadViewController *)viewController willBeginDownloadItem:(MAOfflineItem *)item;

/**
 *  更新数据调用代理是代理更新数据
 *
 * para : 更新的项目
 */
- (void)downloadViewController:(XMDownLoadViewController *)viewController didUpdateInfoForItem:(MAOfflineItem *)item;


/**
 *  将要下载完成一个项目的时候调用代理方法
 *
 * para : 完成下载的项目
 */
- (void)downloadViewController:(XMDownLoadViewController *)viewController willFinishDownloadItem:(MAOfflineItem *)item;


/**
 *  点击已经下载完成的项目
 *
 * para : 完成下载的项目
 */
- (void)downloadViewController:(XMDownLoadViewController *)viewController didClickFinishedItem:(MAOfflineItem *)item;

/**
 *  点击正在下载的项目
 *
 * para : 正在下载的项目
 */
- (void)downloadViewController:(XMDownLoadViewController *)viewController didClickDownloadingItem:(MAOfflineItem *)item;


@end

@interface XMDownLoadViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,weak)id<XMDownLoadViewControllerDelegate> delegate; //!< 更新代理的进度
//@property (nonatomic, strong) MAMapView *mapView;通知更新地图


+ (instancetype)sharedInstance;

- (void)downloadItem:(MAOfflineItem *)item;

@end
