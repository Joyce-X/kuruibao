//
//  XMMapShowListView.m
//  kuruibao
//
//  Created by x on 16/11/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:
 
 用来展示搜索列表
 
 **********************************************************/

#import "XMMapShowListView.h"
#import "XMMapListCell.h"



#define defaultRowHeight 70

@interface XMMapShowListView()<UITableViewDelegate,UITableViewDataSource>



@end


@implementation XMMapShowListView

+(instancetype)listView
{
    
    return [[XMMapShowListView alloc]init];

}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
         [self setupInit];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBtnClick:) name:kXMCellNaviBtnDidClickNotification object:nil];
    }

    return self;

}

- (void)setupInit
{
    
    UIView *topView = [[UIView alloc]init];
    
    topView.backgroundColor = XMWhiteColor;
    
    [self addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self);
        
        make.right.equalTo(self);
        
        make.left.equalTo(self);
        
        make.height.equalTo(33);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    UIView *line = [UIView new];
    
    line.backgroundColor = XMGrayColor;
    
    line.layer.cornerRadius = 3;
    
    [topView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(topView);
        
        make.top.equalTo(topView).offset(12);
        
        make.width.equalTo(55);
        
        make.height.equalTo(3);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    UITableView *tab = [[UITableView alloc]init];
    
    tab.delegate = self;
    
    tab.dataSource = self;
    
    tab.rowHeight = self.rowHeight > 0 ? _rowHeight : defaultRowHeight;
    
    tab.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:tab];
    
    self.tableView = tab;
    
    [tab mas_makeConstraints:^(MASConstraintMaker *make) {
       
        
        make.left.equalTo(topView);
        
        make.right.equalTo(topView);
        
        make.bottom.equalTo(self);
        
        make.top.equalTo(topView.mas_bottom);
        
        
        
    }];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.dataSource.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    XMMapListCell *cell = [XMMapListCell dequeueReuseableCellWithTableView:tableView];
    
    cell.poi = self.dataSource[indexPath.row];

    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapShowListViewDidSelectRowAtIndexPath:)])
    {
        [self.delegate mapShowListViewDidSelectRowAtIndexPath:indexPath];
    }


}

- (void)naviBtnClick:(NSNotification *)noti
{
    UIButton *btn = noti.userInfo[@"sender"];
    
    UIEvent *event = noti.userInfo[@"event"];
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![btn pointInside:[touch locationInView:btn] withEvent:event]) {
        return;
    }
    
    CGPoint touchPosition = [touch locationInView:self.tableView];
    
   NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPosition];
    
    AMapPOI *poi = self.dataSource[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(mapShowListViewDidSelectDestinationPoi:)])
    {
        [self.delegate mapShowListViewDidSelectDestinationPoi:poi];
    }
    
    
}


- (void)dealloc
{
    
    XMLOG(@"+++++++++++++++++++++");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
