//
//  XDMultTableView.h
//  XDMultTableView
//
//  Created by 蔡欣东 on 2016/7/16.
//  Copyright © 2016年 蔡欣东. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMMultTableViewDatasource,XMMultTableViewDelegate;

typedef UITableViewCell XDMultTableViewCell;

typedef UITableViewRowAnimation XDMultTableViewRowAnimation;

typedef NS_ENUM(NSInteger, XDMultTableViewCellEditingStyle) {
    XDMultTableViewCellEditingStyleNone,
    XDMultTableViewCellEditingStyleDelete,
    XDMultTableViewCellEditingStyleInsert
};

@interface XMMultTableView : UIView<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, assign, readwrite) id<XMMultTableViewDatasource> datasource;

@property (nonatomic, assign, readwrite) id<XMMultTableViewDelegate> delegate;

@property (nonatomic, copy, readwrite) NSArray *openSectionArray;

@property (nonatomic, strong, readwrite) UIView *tableViewHeader;

@property (nonatomic,strong)NSArray* data;


- (void)updateData:(NSArray *)seriseArray section:(NSInteger)section willOpen:(BOOL)willOpen;


/**
 *  Cell重用机制（一）
 *
 *  @param identifier Cell标识
 *
 *  @return Cell
 */
- (XDMultTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

/**
 *  Cell重用机制（二）
 *
 *  @param identifier Cell标识
 *  @param indexPath
 *
 *  @return Cell
 */
- (XDMultTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
                                               forIndexPath:(NSIndexPath *)indexPath;
/**
 *  刷新数据源
 */
- (void)reloadData;

/**
 *  注册cell（一）
 *
 *  @param nib
 *  @param identifier
 */
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier ;

/**
 *  注册cell（二）
 *
 *  @param cellClass
 *  @param identifier
 */
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

/**
 *  删除cell
 *
 *  @param indexPaths
 *  @param animation
 */
- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

@end

/**
 *  数据源
 */
@protocol XMMultTableViewDatasource <NSObject>

@required

/**
 *  每个section的行数
 *
 *  @param mTableView
 *  @param section
 *
 *  @return 每个section的行数
 */
- (NSInteger)mTableView:(XMMultTableView *)mTableView numberOfRowsInSection:(NSInteger)section;

/**
 *  Cell显示
 *
 *  @param mTableView
 *  @param indexPath
 *
 *  @return Cell
 */
- (XDMultTableViewCell *)mTableView:(XMMultTableView *)mTableView
               cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  section的数量
 *
 *  @param mTableView
 *
 *  @return section的数量
 */
- (NSInteger)numberOfSectionsInMTableView:(XMMultTableView *)mTableView;              // Default is 1

/**
 *  头部的title
 *
 *  @param tableView mTableView
 *  @param section   section
 *
 *  @return
 */
-(NSString *)mTableView:(XMMultTableView *)mTableView titleForHeaderInSection:(NSInteger)section;

//Edit

/**
 *  cell是否可以编辑
 *
 *  @param mTableView
 *  @param indexPath
 */
- (BOOL)mTableView:(XMMultTableView *)mTableView canEditRowAtIndexPath:(NSIndexPath  *)indexPath;

/**
 *  cell编辑后回调
 *
 *  @param tableView
 *  @param editingStyle
 *  @param indexPath
 */
- (void)mTableView:(XMMultTableView *)tableView commitEditingStyle:(XDMultTableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 *  代理
 */
@protocol XMMultTableViewDelegate <NSObject>

@optional
/**
 *  每个Cell的高度
 *
 *  @param mTableView
 *  @param indexPath
 *
 *  @return 每个Cell的高度
 */
- (CGFloat)mTableView:(XMMultTableView *)mTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  每个section的高度
 *
 *  @param mTableView
 *  @param section
 *
 *  @return 每个section的高度
 */
- (CGFloat)mTableView:(XMMultTableView *)mTableView heightForHeaderInSection:(NSInteger)section;

/**
 *  section View
 *
 *  @param mTableView
 *  @param section
 *
 *  @return section View
 */
- (UIView *)mTableView:(XMMultTableView *)mTableView viewForHeaderInSection:(NSInteger)section;

/**
 *  即将打开指定列表回调
 *
 *  @param mTableView
 *  @param section
 */
- (void)mTableView:(XMMultTableView *)mTableView willOpenHeaderAtSection:(NSInteger)section;

/**
 *
 *  即将关闭列表回调
 *  @param mTableView
 *  @param section
 */
- (void)mTableView:(XMMultTableView *)mTableView willCloseHeaderAtSection:(NSInteger)section;

/**
 *  点击Cell回调
 *
 *  @param mTableView
 *  @param indexPath
 */
- (void)mTableView:(XMMultTableView *)mTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

//Edit

/**
 *
 *  设置cell的编辑类型
 *  @param mTableView
 *  @param indexPath
 *
 *  @return
 */
- (XDMultTableViewCellEditingStyle)mTableView:(XMMultTableView *)mTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  设置cell编辑状态之删除的文本
 *
 *  @param mTableView
 *  @param indexPath
 
 *  @return
 */
- (NSString *)mTableView:(XMMultTableView *)mTableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;


- (void )mTableView:(XMMultTableView *)mTableView sectionHeaderDidClick:(NSInteger)section willOpen:(BOOL)willOpen;
/**
 *  ...易拓展出你想要的tableview的功能，写法可以参照上面的定义
 */

@end

