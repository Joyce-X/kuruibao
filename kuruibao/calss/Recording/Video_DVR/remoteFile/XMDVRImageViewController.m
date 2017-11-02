//
//  XMDVRViewController.m
//  GKDVR
//
//  Created by x on 16/10/25.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/**********************************************************
 class description:
 
      show the image,video,lockedFile of SD card,this VC showing image only
 
 **********************************************************/

#import "XMDVRImageViewController.h"
#import "XMDVRRemoteImageViewController.h"
#import "XMDVRLockedFileViewController.h"
#import "XMDVRRemoteVideoViewController.h"




@interface XMDVRImageViewController ()

//@property (nonatomic,weak)UIView* line;//!< 顶部线条
//
//@property (assign, nonatomic) NSInteger currentIndex;//!< 上次位置下标
//
//@property (nonatomic,weak)UIView* topView;
  @property (nonatomic,weak)UIButton* cancelBtn;//!< 取消下载的按钮
@end

@implementation XMDVRImageViewController
 
/*!
 @brief 三个子控制器
 */
-(void)createChildVC
{
    
        XMDVRRemoteImageViewController *imageVC = [XMDVRRemoteImageViewController new];
    
         XMDVRRemoteVideoViewController *videoVC = [XMDVRRemoteVideoViewController new];
        
        XMDVRLockedFileViewController *lockVideoVC = [XMDVRLockedFileViewController new];
        
        [self addChildViewController:imageVC];
        
        [self addChildViewController:videoVC];
        
        [self addChildViewController:lockVideoVC];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.message = @"远程文件";
    
  
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    cancel.hidden = YES;
    
    cancel.titleLabel.font = [UIFont systemFontOfSize:17];
    
    [cancel addTarget:self action:@selector(cancelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cancel];
    
    [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(self.view).offset(-20);
        
        make.top.equalTo(self.view).offset(45);
        
        make.width.equalTo(60);
        
        make.height.equalTo(30);
        
    }];
    
    self.cancelBtn = cancel;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"记录仪图片页面");
}



- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    
    if (self.cancelBtn)
    {
        [self cancelBtnDidClick:_cancelBtn];
    }
    
    MobClickEnd(@"记录仪图片界面");


}

- (void)cancelBtnDidClick:(UIButton *)cancel
{
    cancel.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMDVRImageViewControllerCancelBtnClickNotification object:nil userInfo:nil];
    
    self.chooseBar.userInteractionEnabled = YES;
    
}

- (void)showCancelBtn
{

    self.cancelBtn.hidden = !self.cancelBtn.hidden;
    self.chooseBar.userInteractionEnabled = self.cancelBtn.hidden;//!< 显示取消按钮的时候，就取消选择栏交互效果

}
 













@end
