//
//  XMSet_helpViewController.m
//  kuruibao
//
//  Created by x on 16/9/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMSet_helpViewController.h"

@interface XMSet_helpViewController ()

@end

@implementation XMSet_helpViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupInit_help];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"帮助页面");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    MobClickEnd(@"帮助页面");
    
}


- (void)setupInit_help
{
     self.message = @"帮助";
    
    [self.imageVIew removeFromSuperview];
    
    //-----------------------------seperate line---------------------------------------//
    //!< statusBar
    UIView *statusBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainSize.width, 20)];
    
    statusBar.backgroundColor = XMTopColor;
    
    [self.view addSubview:statusBar];
    
    //-----------------------------seperate line---------------------------------------//
    UIImageView *backIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"monitor_background"]];
    
    backIV.frame = CGRectMake(0, 20, mainSize.width, mainSize.height - 20);
    
    [self.view addSubview:backIV];
    
    [self.view sendSubviewToBack:backIV];
    
    //-----------------------------seperate line---------------------------------------//
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加背景图
    UIView *backView = [UIView new];
    
    backView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    
    [self.view addSubview:backView];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(backIV).offset(25);
        
        make.right.equalTo(backIV).offset(-25);
        
        make.bottom.equalTo(backIV).offset(-18);
        
        make.top.equalTo(statusBar.mas_bottom).offset(FITHEIGHT(145));
        
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加图片
    
    UIImage *image = [UIImage imageNamed:@"setting_help"];
    
    CGSize imageSize = image.size;
    
    CGFloat height = imageSize.height * (mainSize.width - 50) / imageSize.width;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [backView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backView);
        
        make.top.equalTo(backView);
        
        make.right.equalTo(backView);
        
        make.height.equalTo(height);
        
    }];
    
    
    NSString *title = @"A区域:通用、大众、福特、丰田、现代、雪铁龙、宝马等品牌的绝大部分车型\nB区域:本田、大众途安、进口雷克萨斯等车型\nC区域:东风雪铁龙、东风标致等少量车型\nD区域:东风雪铁龙等少量车型\nE区域:其他少量车型";
    
    
    UILabel *label = [UILabel new];
    
    label.font = [UIFont systemFontOfSize:14];
    
    label.textColor = [UIColor whiteColor];
    
    label.text = @"车辆OBD接口位置识别";
    
    label.backgroundColor = [UIColor clearColor];
    
    [backView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backView).offset(15);
        
        make.top.equalTo(imageView.mas_bottom).offset(10);
        
        make.height.equalTo(25);
        
        make.width.equalTo(200);
        
        
    }];
    
    UITextView *textView = [UITextView new];
    
    textView.font = [UIFont systemFontOfSize:12];
    
    textView.backgroundColor = [UIColor clearColor];
    
     textView.userInteractionEnabled = NO;
    
    [backView addSubview:textView];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:12],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:[UIColor whiteColor]
                                 
                                 };
    textView.attributedText = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backView).offset(15);
        
        make.right.equalTo(backView).offset(-15);
        
        make.bottom.equalTo(backView);
        
        make.top.equalTo(label.mas_bottom).offset(2);
        
    }];
    
    
    
    

    
    
}
@end
