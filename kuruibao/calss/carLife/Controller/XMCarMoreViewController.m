//
//  XMCarMoreViewController.m
//  kuruibao
//
//  Created by x on 17/4/19.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarMoreViewController.h"

#import "XMCarlife_Cell_01.h"


#import "XMCarlife_Cell_02.h"

#import "XMCarlife_Cell_03.h"

#import "XMCarLife_showArticleViewController.h"

@interface XMCarMoreViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation XMCarMoreViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    //!< back imageVIew
    UIImageView *backIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"carLife_breakRule_background"]];
    
    [self.view addSubview:backIV];
    
    [backIV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.view).offset(20);
        
        make.left.right.bottom.equalTo(self.view);
        
    }];
    
    //!< top
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    topView.backgroundColor = XMColor(47, 48, 43);
    
    [self.view addSubview:topView];
    
    
    //!< back button
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn setImage:[UIImage imageNamed:@"carLife_searchPetrolPrice_backBtnImage"] forState:UIControlStateNormal];
    
     
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view).offset(20);
        
        make.top.equalTo(backIV).offset(28);
        
        make.size.equalTo(CGSizeMake(30,30));;
        
    }];
    
    
    //!< title
    UILabel *titleLabel = [UILabel new];
    
    titleLabel.text = @"精选文章";
    
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:26];
    
    [self.view addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backIV).offset(24);
        
        make.top.equalTo(backBtn.mas_bottom).offset(18);
        
        make.height.equalTo(26);
        
        make.width.equalTo(200);
        
    }];
    
    //!< tableView
    
    UITableView *tableView = [[UITableView alloc]init];
    
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.dataSource = self;
    
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.equalTo(self.view);
        
        make.top.equalTo(titleLabel.mas_bottom).offset(56);
        
        
    }];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"车生活更多页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"车生活更多页面");
    
}

#pragma mark ------- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0)
    {
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"XMCarlife_Cell_01" owner:nil options:nil].firstObject;
        
        
        
    }else if(indexPath.row == 1)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"XMCarlife_Cell_02" owner:nil options:nil].firstObject;
        
        
        
        
        
    }else
    {
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"XMCarlife_Cell_03" owner:nil options:nil].firstObject;
        
        
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    return cell;
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        return 105;
        
    }else if(indexPath.row == 1)
    {
        
        return 220;
        
    }else
    {
        
        return 150;
        
    }
    
    
}

#pragma mark ------- UITableviewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *address;
    
    switch (indexPath.row) {
            
        case 0:
            
            address = @"http://mp.weixin.qq.com/s/YDCWhXexiuCxcLFWSBAkeQ";
            
            break;
            
        case 1:
            
            address = @"http://mp.weixin.qq.com/s/1myqzSVme2L5p-Aa-ch9HA";
            
            break;
            
        case 2:
            
            address = @"http://mp.weixin.qq.com/s/tWPQWN_9pdnxonzKLVQGtg";
            
            break;
            
        default:
            break;
    }
    
    XMCarLife_showArticleViewController *vc = [XMCarLife_showArticleViewController new];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    vc.address = address;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
    
}


#pragma mark ------- btn click

- (void)backBtnClick
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{

    return UIStatusBarStyleLightContent;

}

@end
