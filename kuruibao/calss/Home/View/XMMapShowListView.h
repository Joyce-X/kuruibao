//
//  XMMapShowListView.h
//  kuruibao
//
//  Created by x on 16/11/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>




@protocol XMMapShowListViewDelegate <NSObject>

- (void)mapShowListViewDidSelectDestinationPoi:(AMapPOI *)poi;

- (void)mapShowListViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end



@interface XMMapShowListView : UIView

@property (strong, nonatomic) NSArray *dataSource;//!< 数据源

@property (assign, nonatomic) CGFloat rowHeight;//!< 行高

@property (nonatomic,weak)id<XMMapShowListViewDelegate> delegate;

@property (nonatomic,weak)UITableView* tableView;

+(instancetype)listView;

@end
