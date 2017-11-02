//
//  XMSetSignNameViewController.m
//  kuruibao
//
//  Created by x on 16/9/7.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 设置各项签名的控制器
 
 
 ************************************************************************************************/
#import "XMSetSignNameViewController.h"

#define textLengthLimit 24

@interface XMSetSignNameViewController ()<UITextViewDelegate>

@property (nonatomic,weak)UITextView* signTV;//->>编辑个性签名

@property (nonatomic,weak)UILabel* numberLabel;//->>显示剩余字数的label

@property (copy, nonatomic) NSString *sourceText;//!< 进入界面时候的文字

@property (nonatomic,weak)UIButton* saveBtn;

@end

@implementation XMSetSignNameViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupSubViews];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegain(@"设置签名页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"设置签名页面");
    
}
//->>布局子控件
- (void)setupSubViews
{
    self.view.backgroundColor = XMColorFromRGB(0xF8F8F8);
    self.message = @"设置签名";
    
    //->>添加可移动的View
    UIScrollView *bottomView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH)];
    
    bottomView.alwaysBounceVertical = YES;
    
    bottomView.delegate = self;
    
    [self.view addSubview:bottomView];
    
    
    
    //->>添加textView
    UITextView *signTV = [[UITextView alloc]initWithFrame:CGRectMake(0, 15, mainSize.width, 100)];
    signTV.backgroundColor = [UIColor whiteColor];
    signTV.textContainerInset = UIEdgeInsetsMake(15, 10, 20, 10);
    signTV.font = [UIFont systemFontOfSize:16];
    signTV.textColor = XMColorFromRGB(0x7f7f7f);
    NSString *text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo_signName"];
    
    if ([text isEqualToString:@"设置个性签名"])
    {
        signTV.text = nil;
    }else
    {
        signTV.text = text;
    }
    
    self.sourceText = signTV.text;
    
    signTV.delegate = self;
    
    signTV.keyboardType = UIKeyboardTypeDefault;
    
    [bottomView addSubview:signTV];
    
    self.signTV = signTV;
    
    //->>添加显示剩余数字的label
    UILabel *numberLabel = [UILabel new];
    CGFloat num_width = 200;
    CGFloat num_hight = 30;
    CGFloat num_x = mainSize.width - num_width - 20;
    CGFloat num_y = 100 - num_hight - 10;
    numberLabel.frame = CGRectMake(num_x, num_y, num_width, num_hight);
    numberLabel.textAlignment = NSTextAlignmentRight;
    numberLabel.font = [UIFont systemFontOfSize:14];
    numberLabel.textColor = XMColorFromRGB(0x7f7f7f);
    numberLabel.text = [NSString stringWithFormat:@"还可输入%d字",(textLengthLimit - (int)signTV.text.length)];
    [signTV addSubview:numberLabel];
    self.numberLabel = numberLabel;
    
    //-----------------------------seperate line---------------------------------------//
    //!<添加保存按钮
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitle:@"保存" forState:UIControlStateDisabled];
    
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    saveBtn.enabled = NO;
    
    saveBtn.backgroundColor = XMGrayColor;
    
    [saveBtn addTarget:self action:@selector(saveBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:saveBtn];
    
    self.saveBtn = saveBtn;
    
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(self.view);
        
        make.left.equalTo(self.view);
        
        make.right.equalTo(self.view);
        
        make.height.equalTo(55);
        
    }];
    
}

//!< 点击保存按钮
- (void)saveBtnDidClick
{
    
    //->>保存昵称到本地
    
     [[NSUserDefaults standardUserDefaults] setObject:_signTV.text forKey:@"userInfo_signName"];
   
     self.completion(_signTV.text);
    
     [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger count = textView.text.length;
    int result = textLengthLimit - (int)count;
    if (result < 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"长度超过限制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        result = 0;
        textView.text = [textView.text substringWithRange:NSMakeRange(0, textLengthLimit)];
    }
     self.numberLabel.text = [NSString stringWithFormat:@"还可输入%d字",result];
    
    if (![textView.text isEqualToString:self.sourceText])
    {
        
        if(_saveBtn.enabled == NO)
        {
            self.saveBtn.enabled = YES;
            
            self.saveBtn.backgroundColor = XMGreenColor;
            
        }
       
        
    }
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

    [self.view endEditing:YES];

}


- (void)backToLast
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
