//
//  XMSetCarNumberViewController.m
//  kuruibao
//
//  Created by x on 16/8/31.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 设置车牌号码的控制器
 
 
 ************************************************************************************************/
#import "XMSetCarNumberViewController.h"
#import "NSString+extention.h"

#define btnFont 15

@interface XMSetCarNumberViewController()


@property (nonatomic,strong)NSArray* provinces;//->>数据


@property (nonatomic,weak)UIView* whiteView;//!< 显示按钮的背景图

@property (nonatomic,weak)UILabel* temLabel;

@end
@implementation XMSetCarNumberViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

       //->背景
    [self setupSubViews];

    //->>监听通知
    [self monitorNotification];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"添加车辆设置车牌号页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"添加车辆设置车牌号页面");
    
}


- (void)monitorNotification
{
    //-- 监听键盘的弹起好落下
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)setupSubViews
{
    //->>背景
    self.imageVIew.frame = [UIScreen mainScreen].bounds;
    self.imageVIew.image = [UIImage imageNamed:@"carInfo_setCarNum_backImage"];
    self.message = @"车牌号码";
    
    //->>车牌名称
    self.provinces = @[@"京",@"津",@"冀",@"晋",@"蒙",@"辽",@"吉",@"黑",@"沪",@"苏",@"浙",@"皖",@"闽",@"赣",@"鲁",@"豫",@"鄂",@"湘",@"粤",@"桂",@"琼",@"渝",@"川",@"贵",@"云",@"藏",@"陕",@"甘",@"青",@"宁",@"新",@"台"];
    
    //->>btn宽高
   
    CGFloat btnW = 30;
   
    CGFloat btnH = 30;
    
    CGFloat marginY = FITHEIGHT(7);//-> y轴的间距
    
    CGFloat marginX =  ((mainSize.width - 50 - 15 - 15) - (30 * 4))/3;
    
    CGFloat backView_X = 25;
    
    CGFloat backView_W = mainSize.width - 50;
    
    CGFloat backView_Y = FITHEIGHT(152);
    
    CGFloat backView_H = (marginY * 9)+ btnH * 8 + FITHEIGHT(14);
    
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(backView_X, backView_Y, backView_W, backView_H)];
    whiteView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
    whiteView.layer.masksToBounds = YES;
    
    whiteView.layer.cornerRadius = 7;
    
    [self.view addSubview:whiteView];
    
    self.whiteView = whiteView;
    
    for (int i = 0; i < _provinces.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [btn setTitle:_provinces[i] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        btn.tag = i;
        
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        int col = i % 4;//->>列
        
        int row = i * 0.25;//->>行
        
        CGFloat btnX = ((marginX + btnW) *col) + 15;
        
        CGFloat btnY = ((marginY + btnH) *row) + FITHEIGHT(14);
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        btn.contentEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
        
        btn.titleLabel.font = [UIFont systemFontOfSize:btnFont];
        
         
        [whiteView addSubview:btn];
    }
    
    //->>添加label
    UILabel *first = [UILabel new];
    
    first.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
    first.textColor = XMColorFromRGB(0xFFFFFF);
    
    first.font = [UIFont systemFontOfSize:btnFont];
    
    first.textAlignment = NSTextAlignmentCenter;
    
    first.layer.masksToBounds = YES;
    
    first.layer.cornerRadius = 7;
    
    [self.view addSubview:first];
    
    self.firstName = first;
    
    [first mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(whiteView);
        
        make.top.equalTo(whiteView.mas_bottom).offset(15);
        
        make.height.equalTo(40);
        
        make.width.equalTo(btnW * 2);
        
    }];
    
    //->>添加输入框
     UITextField *numberTF = [[UITextField alloc]init];
    
     numberTF.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
     numberTF.textColor = XMColorFromRGB(0xFFFFFF);
    
     numberTF.font = [UIFont systemFontOfSize:btnFont];
    
    numberTF.clearButtonMode = UITextFieldViewModeAlways;
    
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 40)];
    
    numberTF.leftView = leftView;
    
    numberTF.leftViewMode = UITextFieldViewModeAlways;
    
    numberTF.layer.masksToBounds = YES;
    
    numberTF.layer.cornerRadius = 7;
    
//    numberTF.keyboardType = UIKeyboardTypeURL

    [self.view addSubview:numberTF];
    
    self.numberTF = numberTF;
    
    [numberTF mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.equalTo(first);
        
        make.right.equalTo(whiteView);
        
        make.left.equalTo(first.mas_right).offset(10);
        
        make.top.equalTo(first);
        
    }];
    

}

//->>点击按钮
- (void)btnDidClick:(UIButton *)sender
{
    
    _firstName.text = [_provinces objectAtIndex:sender.tag];
    
 }


//->>点击返回
- (void)backToLast
{
    
    //->>对车牌号码进行校验
    if (![self validateCarNo] && ![_numberTF.text isEqualToString:@""])
    {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请输入正确的车牌号码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
        
    }
    
    if (self.numberTF.text.length > 3)
    {
        char first = [_numberTF.text characterAtIndex:0];
        
        if (first <= 'Z' && first >= 'A')
        {
            XMLOG(@"***sss");
            
        }else
        {
            
            [MBProgressHUD showError:@"请输入正确的车牌号码"];
            
            return;
            
        }
    }
    
    
    
    //!< back to last page, convenient subClass to override this method
    [self executeBackTask];


}

- (void)executeBackTask
{
    [self.view endEditing:YES];
    
    if (![self.numberTF.text isEqualToString:@""])
    {
        NSString *carNumber = [NSString stringWithFormat:@"%@%@",_firstName.text,_numberTF.text];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCHEXIAOMISETTINGDIDWRITECARNUMBERNOTIFICATION object:self userInfo:@{@"info": carNumber}];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


//->>校验车牌号码
 - (BOOL)validateCarNo
{
    NSString *carRegex = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    
     return [carTest evaluateWithObject:_numberTF.text];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];

}


#pragma mark -- 监听通知的方法

/**
 *  键盘即将弹出
 */
- (void)keyboardWillShow:(NSNotification *)noti
{
//    XMLOG(@"%@",noti);
    if (self.view.frame.origin.y != 0)return;
    
    CGFloat duration = [noti.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    [UIView animateWithDuration:duration animations:^{
        
        CGRect frame =  self.view.frame;
        frame.origin.y -= 230;
        self.view.frame = frame;
        
    }];
    
    
}



/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHide:(NSNotification *)noti
{
    if (self.view.frame.origin.y == 0)return;
    CGFloat duration = [noti.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    [UIView animateWithDuration:duration animations:^{
        
//        self.view.y += 230;
        CGRect frame =  self.view.frame;
        frame.origin.y += 230;
        self.view.frame = frame;
        
    }];
    
    
    
}


- (void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
 
}


@end
