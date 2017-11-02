//
//  XMSetNickNameViewController.m
//  kuruibao
//
//  Created by x on 16/9/7.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
设置昵称的控制器
 
 
 ************************************************************************************************/
#import "XMSetNickNameViewController.h"

#define kCheXiaoMiUserNickNameDidChangeNotification @"kCheXiaoMiUserNickNameDidChangeNotification"

#define kXMNickNameChangeNotification @"kXMNickNameChangeNotification"

@interface XMSetNickNameViewController ()<UIScrollViewDelegate>
@property (nonatomic,weak)UITextField * nickTF;//->>输入框

@property (nonatomic,weak)UIButton* saveBtn;//!< 保存按钮

@property (copy, nonatomic) NSString *sourceText;//!< 进入界面时候的名称

@end

@implementation XMSetNickNameViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_nickTF becomeFirstResponder];
    
    MobClickBegain(@"设置昵称页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"设置昵称页面");
    
}

 
//->>布局子控件
- (void)setupSubViews
{
    self.view.backgroundColor = XMColorFromRGB(0xF8F8F8);
    
    self.message = @"设置昵称";
    
    //->>添加可移动的View
    UIScrollView *bottomView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH)];
    
    bottomView.alwaysBounceVertical = YES;
    
    bottomView.delegate = self;
    
    [self.view addSubview:bottomView];
    
     //->>添加textfield
     UITextField *nickTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 15, mainSize.width, 30)];
    
    nickTF.backgroundColor = [UIColor whiteColor];
    
    nickTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 30)];
    
    nickTF.clearButtonMode = UITextFieldViewModeAlways;
    
    nickTF.leftViewMode = UITextFieldViewModeAlways;
    
     [bottomView addSubview:nickTF];
    
    self.nickTF = nickTF;
    
    NSString *text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo_nickName"];
    
    self.sourceText = text;
    
    _nickTF.text = text ? text : @"";
    
    
    //->监听textfield字数变化的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nickMameTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];

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

//!< 点击按钮
- (void)saveBtnDidClick
{
    
    if (_nickTF.text.length == 0)
    {
        [MBProgressHUD showError:@"昵称不能为空"];
        
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_nickTF.text forKey:@"userInfo_nickName"];
    
    self.completion(_nickTF.text);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMNickNameChangeNotification object:nil userInfo:@{@"info":_nickTF.text}];
    
     [self backToLast];
    
}


#pragma mark -------------- UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    
}

//->>监听文字长度变化
- (void)nickMameTextDidChanged:(NSNotification *)noti
{
    
    NSUInteger count = _nickTF.text.length;
    if (count > 12)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"长度超过限制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        _nickTF.text = [_nickTF.text substringWithRange:NSMakeRange(0, 8)];
    }
    
    if (![_nickTF.text isEqualToString:_sourceText])
    {
        
        if (!_saveBtn.enabled)
        {
             _saveBtn.enabled = YES;
            
            _saveBtn.backgroundColor = XMGreenColor;
            
        }
     }
    
}


//->>返回
- (void)backToLast
{
    [self.navigationController popViewControllerAnimated:YES];

 }

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

@end
