//
//  XMAboutViewController.m
//  kuruibao
//
//  Created by x on 16/8/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 展示关于公司信息的相关界面
 
 
 
 ************************************************************************************************/

#import "XMAboutViewController.h"
#import "AppDelegate.h"

@interface XMAboutViewController ()

/**
 *  显示文字内容
 */
@property (nonatomic,copy)NSString* content;

@end

@implementation XMAboutViewController

- (instancetype)init
{

    self = [super init];
    if (self)
    {
        _content = @"\n        深圳车小米智能网络科技有限公司是一家致力于为各类TO B端企业用户提供车辆管理解决方案的供应商.\n        我们以自主知识产权的精准车辆管理平台及各类硬件终端为依托。结合车音网国际领先的自主语音识别技术以及基于该技术搭建的车联网系统服务平台,力争为各类企业主实现车队的精准化管理,节省成本,实时高效.于此同时,我们还能为驾驶者打造安全便捷的语音通讯,导航,娱乐,救援,人工客服等人机交互体验.\n        我们希望通过3年时间的努力,让车小米真正成为一家在国内车辆管理领域具有一定行业地位的领导者,坚持创新,实现辉煌.";
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self creatSubViews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"关于页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"关于页面");
    
}


- (void)creatSubViews
{
    
    self.message = @"关于";
    
    self.view.backgroundColor = XMColorFromRGB(0xF8F8F8);
 
    UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(25, backImageH, mainSize.width - 50 , mainSize.height - backImageH - 27)];
    
    tv.editable = NO;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    
    paragraphStyle.lineSpacing = 10;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName : paragraphStyle
                                 
                                 };
    
    tv.attributedText = [[NSAttributedString alloc]initWithString:_content attributes:
                         attributes];
    
    tv.showsVerticalScrollIndicator = NO;
    
    tv.textColor = [UIColor grayColor];
   
    tv.backgroundColor = XMColorFromRGB(0xF8F8F8);
    
    [self.view addSubview:tv];
 
    
    
    
    //-----------------------------seperate line--------------------origin-------------------//
    
//    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, backImageH , mainSize.width , mainSize.height - backImageH)];
//    tableView.backgroundColor = XMColorFromRGB(0xF8F8F8);
//    //->>创建textView显示车小米简介
//    
//    UIView *clearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, mainSize.height - backImageH)];
//    clearView.backgroundColor = XMColorFromRGB(0xF8F8F8);
//     tableView.tableFooterView = clearView;
//    
//    UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(25, backImageH, mainSize.width - 50 , mainSize.height - backImageH - 27)];
//    
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    paragraphStyle.lineSpacing = 10;
//    NSDictionary *attributes = @{
//                                 NSFontAttributeName : [UIFont systemFontOfSize:15],
//                                 NSParagraphStyleAttributeName : paragraphStyle
//                                 
//                                 };
//    tv.attributedText = [[NSAttributedString alloc]initWithString:_content attributes:
//                         attributes];
//    
//    tv.showsVerticalScrollIndicator = NO;
//    
//    tv.textColor = [UIColor grayColor];
//    tv.userInteractionEnabled = NO;
//    tv.backgroundColor = XMColorFromRGB(0xF8F8F8);
//    [clearView addSubview:tv];
//    [self.view addSubview:clearView];
    
    
    
    
}

- (void)backToLast
{

    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (tempAppDelegate.sliderVC.closed)
    {
        [tempAppDelegate.sliderVC openLeftView];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
