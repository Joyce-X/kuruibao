//
//  XMDetailRootViewController.m
//  kuruibao
//
//  Created by x on 16/8/31.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 车辆信息设置界面的二级页面的根控制器，所有在车辆信息模块中的二级页面都继承自这个控制器
 
 
 ************************************************************************************************/

#import "XMDetailRootViewController.h"


@interface XMDetailRootViewController()
@property (nonatomic,weak,readwrite)UILabel* messageLabel;

@end
@implementation XMDetailRootViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //->>设置顶部视图
    [self setupTopView];

    

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //->>隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;

}

/**
 *  设置顶部视图
 */
- (void)setupTopView
{
    //->>背景
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *topImageView = [UIImageView new];
    topImageView.userInteractionEnabled = YES;
    
    topImageView.image = [UIImage imageNamed:@"topbackImage"];
    
    topImageView.frame = CGRectMake(0, 0, mainSize.width, backImageH);
    [self.view addSubview:topImageView];
    self.imageVIew = topImageView;
    
    //!< 状态栏
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    statusBar.backgroundColor = XMTopColor;
    [self.view addSubview:statusBar];
    
    //->>返回按钮
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
     leftItem.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 5, 5);
    
    [leftItem setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftItem addTarget:self action:@selector(backToLast) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftItem];
    [leftItem mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(self.view).offset(FITHEIGHT(43));
        make.size.equalTo(CGSizeMake(36, 36));
        
        
    }];
    
    //->>设置显示提示信息的label
    UILabel *message = [[UILabel alloc]init];
//     message.font = [UIFont systemFontOfSize:26];
    message.textAlignment = NSTextAlignmentLeft;
    [message setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26]];//->>加粗
    message.textColor = XMColorFromRGB(0xF8F8F8);
    [self.view addSubview:message];
    self.messageLabel = message;
    [message mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view).offset(25);
        make.width.equalTo(200);
        make.height.equalTo(31);
        make.top.equalTo(leftItem.mas_bottom).offset( FITHEIGHT(20));
        
        
    }];
    
       
    
    
}

/**
 *  返回上一级界面
 */
- (void)backToLast
{
    [self.navigationController popViewControllerAnimated:YES];
    
}


/**
 *  设置提示信息
 */
- (void)setMessage:(NSString *)message
{
    _message = message;
    self.messageLabel.text = message;


}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
    
}
@end
