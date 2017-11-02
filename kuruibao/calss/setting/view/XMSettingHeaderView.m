//
//  XMSettingHeaderView.m
//  kuruibao
//
//  Created by x on 16/8/3.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 设置主界面的tableView的表头视图
 
 
 ************************************************************************************************/

#import "XMSettingHeaderView.h"
#import "AppDelegate.h"



//->>昵称发生变化发送的通知
#define kCheXiaoMiUserNickNameDidChangeNotification @"kCheXiaoMiUserNickNameDidChangeNotification"

@interface XMSettingHeaderView()

@property (weak, nonatomic) IBOutlet UIImageView *headerIV;//->>头像

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;//->>昵称label

@end

@implementation XMSettingHeaderView

 
- (void)awakeFromNib
{
    [super awakeFromNib];
    //->>设置初始值
    
   
    self.headerIV.layer.cornerRadius = 107/2;
     //->>监听更换头像的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHeaderImage) name:kXIAOMIHEADERIMAGEWRITEFINISHNOTIFICATION object:nil];
    
    //->>监听昵称改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userNickNameDidChange) name:kCheXiaoMiUserNickNameDidChangeNotification object:nil];
    
}


/**
 *  更新头像
 */
- (void)updateHeaderImage
{
     //->>判断是否有裁剪好的图库中的照片头像
    self.headerIV.image = [UIImage imageWithContentsOfFile:XIAOMI_HEADERLOCALPATH];
 
}

/**
 *  更换昵称
 */
- (void)userNickNameDidChange
{
    self.nickNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo_nickName"];
}


#pragma mark --- setter

-(void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    
    self.nickNameLabel.text = nickName;


}

- (void)setHeaderImage:(UIImage *)headerImage
{
    _headerImage = headerImage;
    
    self.headerIV.image = headerImage;

}



/**
 *  监听头像按钮的点击
 */
- (IBAction)headerBtnClick:(UIButton *)sender {
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(headerViewDidClick:)])
    {
        [self.delegate headerViewDidClick:self];
    }
     
    
}


- (void)dealloc
{

    //->>移除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

@end
