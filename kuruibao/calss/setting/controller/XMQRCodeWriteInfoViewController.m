//
//  XMQRCodeWriteInfoViewController.m
//  kuruibao
//
//  Created by x on 16/10/5.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMQRCodeWriteInfoViewController.h"

@interface XMQRCodeWriteInfoViewController ()
@property (nonatomic,weak)UITextField* imeiTF;
@property (nonatomic,weak)UIButton* saveBtn;
@end

@implementation XMQRCodeWriteInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self setupSubViews];
 }





- (void)setupSubViews
{
    self.message = @"手动添加";
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"AddButton"] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"AddButton"] forState:UIControlStateHighlighted];
    CGFloat btn_w = 55;
    CGFloat btn_h = btn_w;
    CGFloat btn_x = mainSize.width - btn_w - 15;
    CGFloat btn_y = backImageH - btn_h * 0.5;
    saveBtn.frame = CGRectMake(btn_x, btn_y, btn_w, btn_h);
    [saveBtn addTarget:self action:@selector(saveBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    self.saveBtn = saveBtn;
    
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH)];
    scrollView.bounces = YES;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    
    UILabel *imeiLabel = [UILabel new];
    imeiLabel.text = @"Imei号码：";
    imeiLabel.textAlignment = NSTextAlignmentCenter;
    imeiLabel.textColor = [UIColor blackColor];
    imeiLabel.font = [UIFont systemFontOfSize:15];
    [scrollView addSubview:imeiLabel];
    [imeiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(scrollView).offset(30);
        make.left.equalTo(scrollView).offset(30);
        make.size.equalTo(CGSizeMake(90, 25));
        
    }];
    
    UITextField * imeiTF = [UITextField new];
    imeiTF.placeholder = @"请输入obd盒子上的编码";
    imeiTF.borderStyle = UITextBorderStyleRoundedRect;
    imeiTF.font = [UIFont systemFontOfSize:13];
    [scrollView addSubview:imeiTF];
    self.imeiTF = imeiTF;
    [imeiTF mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(imeiLabel);
        make.height.equalTo(imeiLabel);
        make.left.equalTo(imeiLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    
}

- (void)saveBtnDidClick
{
    
    if (_imeiTF.text.length != 15)
    {
        [MBProgressHUD showError:@"请输入15位编码"];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: kCHEXIAOMISETTINGQRCODIDIDFINISHSCANNOTIFICATION object:self userInfo:@{@"info":_imeiTF.text}];
    [self.navigationController popViewControllerAnimated:YES];
}

 - (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:_saveBtn];
    
    MobClickBegain(@"手动设置imei页面");

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    MobClickEnd(@"手动设置imei界面");

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [self.view endEditing:YES];

}
#pragma mark -- 监听通知的方法



@end
