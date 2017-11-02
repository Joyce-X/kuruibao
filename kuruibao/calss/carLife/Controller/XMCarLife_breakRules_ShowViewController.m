//
//  XMCarLife_breakRules_ShowViewController.m
//  kuruibao
//
//  Created by x on 17/5/13.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLife_breakRules_ShowViewController.h"

#import "XMCarLife_BreakModel.h"

#import "MJExtension.h"

#import "XMShowBreakCell.h"

#define headerFooterIdentifier @"headerFooterViewIdentifier"


@interface XMCarLife_breakRules_ShowViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *sectionArray;//!< 分区是否展开

@end

@implementation XMCarLife_breakRules_ShowViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
     
    
    if (self.lists.count == 0)
    {
         
        self.messageLabel.text = @"没有违章信息";
        
         return;
    }
    
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:self.lists.count];
    
    int socer = 0;
    
    int money = 0;
    
    for (NSDictionary *dic in self.lists)
    {
        XMCarLife_BreakModel *model = [XMCarLife_BreakModel mj_objectWithKeyValues:dic];
        
        [arrM addObject:model];
        
        socer += [dic[@"fen"] intValue];
        
        money += [dic[@"money"] intValue];
        
    }
    
    self.messageLabel.text = [NSString stringWithFormat:@"    %lu次违章    记%d分    罚款%d元",self.lists.count,socer,money];
    
    self.lists = [arrM copy];
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    self.sectionArray = [NSMutableArray array];
    
    [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:headerFooterIdentifier];
    
    _tableView.backgroundColor = [UIColor clearColor];
    
    _tableView.bounces = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"显示违章信息页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"显示违章信息页面");
    
}

#pragma mark ------- btn click

- (IBAction)backBtnClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark -------------- UITableViewDelegate && UItableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.lists.count;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([self.sectionArray containsObject:@(section)])
    {
        return 1;
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMShowBreakCell *cell = [XMShowBreakCell dequeueReuseableCellWith:tableView];
    
    cell.model = self.lists[indexPath.section];
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerFooterIdentifier];
    
    UILabel *textLabel = [headerView.contentView viewWithTag:134];
    
    UIImageView *arrowIV = [headerView viewWithTag:133];
    
    if (!textLabel)
    {
        
        
        textLabel = [UILabel new];
        
        textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        
        textLabel.textColor = [UIColor whiteColor];
        
        textLabel.frame = CGRectMake(15, 0, (mainSize.width - 50 - 15 -30), 30);
        
        textLabel.tag = 134;
        
        [headerView.contentView addSubview:textLabel];
    }
    
    XMCarLife_BreakModel *model = self.lists[section];
    
   
    
    if (model.handled.integerValue == 0)
    {
        
         textLabel.text =  [NSString stringWithFormat:@"%lu、记%d分    罚款%d元        未处理",section + 1,model.fen.intValue,model.money.intValue];
        
           headerView.contentView.backgroundColor = XMRedColor;
       
        
        
    }else
    {
        
        textLabel.text =  [NSString stringWithFormat:@"%lu、记%d分    罚款%d元        已处理",section + 1,model.fen.intValue,model.money.intValue];
        
        headerView.contentView.backgroundColor = XMGrayColor;
     
    
    }
    
    if (!arrowIV)
    {
        CGFloat width = self.tableView.bounds.size.width;
        
        CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
        
        arrowIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"track_openTriangle"]];
        
        CGFloat arrowIV_W = 18;
        
        CGFloat arrowIV_H  = 18;
        
        arrowIV.frame = CGRectMake((width-arrowIV_W -15) , (height - arrowIV_H)/2, arrowIV_W, arrowIV_H);
        
        arrowIV.contentMode = UIViewContentModeScaleAspectFit;
        
        arrowIV.tag = 133;
        
        [headerView.contentView addSubview:arrowIV];
    }
    
    if ([self.sectionArray containsObject:@(section)])
    {
        
        arrowIV.transform = CGAffineTransformMakeRotation(M_PI_2);
        
    }else
    {
        arrowIV.transform = CGAffineTransformMakeRotation(0);
    }
    
    
    headerView.tag = section;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerViewDidCick:)];
    
    [headerView addGestureRecognizer:tap];
    
    
    return headerView;
    
}



//!< 头部高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

//!< 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMCarLife_BreakModel *model = self.lists[indexPath.section];
    
    float height = 15 + 24 + 20 + 20 + 17;
    
    float height_area = [self heightForText:model.area];
    
    float height_act = [self heightForText:model.act];
    
    return height + height_area + height_act;
    
}


//!< 点击尾部视图
- (void)headerViewDidCick:(UITapGestureRecognizer *)tap
{
    
    UITableViewHeaderFooterView *view = (UITableViewHeaderFooterView *)tap.view;
    
    NSInteger section = view.tag;
    
    UIImageView *triangleIV = [tap.view viewWithTag:133];
    
    if ([self.sectionArray containsObject:@(section)])
    {
        //!< 展开状态
        
        [self.sectionArray removeObject:@(section)];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            triangleIV.transform = CGAffineTransformIdentity;
            
        }];
        
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }else
    {
        //!< 闭合状态
        
        [UIView animateWithDuration:0.3 animations:^{
            
            triangleIV.transform =CGAffineTransformMakeRotation(M_PI_2) ;
            
        }];
        
        [self.sectionArray addObject:@(section)];
        
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
}


- (float)heightForText:(NSString *)text
{
    
    float width = mainSize.width - 49 - 120;
    
    CGSize titleSize = [text boundingRectWithSize:CGSizeMake(width-16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    
    return titleSize.height + 16;
}

@end
