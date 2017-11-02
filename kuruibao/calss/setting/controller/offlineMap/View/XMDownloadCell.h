//
//  XMDownloadCell.h
//  kuruibao
//
//  Created by x on 16/9/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/AMapNaviKit.h>





typedef void (^downloadBlock)(UIButton *sender,UIEvent *event);

@interface XMDownloadCell : UITableViewCell


@property (nonatomic,weak)UILabel* nameLabel;//!< 显示地区名称的Label
@property (nonatomic,copy)NSString* accessoryText;//!< 辅助区域显示的文字信息
@property (nonatomic,strong)UIColor* tintColor;//!< 进度条填充部分的颜色
@property (nonatomic,strong)UIColor* trackTintColor;//!< 进度条没有填充部分的颜色
@property (nonatomic,copy)downloadBlock startDownloadBlock;//!< 开始下载
@property (nonatomic,weak)UIButton* btn_download;
 
/**
 *  创建复用的单元格
 *
 *  @param tableView tab
 *
 *  @return 实例
 */
+ (instancetype)dequeueResuableCellWithTableView:(UITableView *)tableView;



/**
 *  更新名称
 *
 *  @param item 同上
 */
- (void)updateTitleWithItem:(MAOfflineItem *)item;




/**
 *  更新辅助区域显示内容
 *
 *  @param item 对应地图
 */
- (void)updateAccessoryViewWithItem:(MAOfflineItem *)item;


 

/**
 *  当处于等待下载的时候更新cell内容
 */
- (void)updateCellWhenWaitDownload;


/**
 *  更新cell子控件显示的内容信息
 *
 *  @param item          当前下载地图
 *  @param info          下载过程的信息
 *  @param isDownloading 是否包含在正在下载的数组当中
 */
- (void)updateContentWithItem:(MAOfflineItem *)item infoDictionary:(NSMutableDictionary *)info contentInDownloading:(BOOL)isDownloading;



/**
 *  当全省地图正在下载的时候，当前分区cell的用户交互
 */
- (void)turnOffUserInteraction;

//(MAOfflineItem *downloadItem, MAOfflineMapDownloadStatus downloadStatus, id info)
/**
 *  开始下载的时候，实时更新UI
 *
 *  @param item   地图数据
 *  @param status 下载状态
 *  @param info   信息
 */
//- (void)updateUIWithitem:(MAOfflineItem *)item downloadStatus:(MAOfflineMapDownloadStatus)status info:(id)info;

/**
 *  点击省份下载全部
 */
- (void)downloadAll;
@end
