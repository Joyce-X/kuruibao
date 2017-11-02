//
//  XMUserInfoView.m
//  kuruibao
//
//  Created by x on 16/9/6.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 用xib来描述个人资设置的选项
 
 
 ************************************************************************************************/
#import "XMUserInfoView.h"
#import "AFNetworking.h"

@interface XMUserInfoView()
@property (weak, nonatomic) IBOutlet UIButton *headerBtn;//->>头像按钮
@property (weak, nonatomic) IBOutlet UILabel *signName;//->>个性签名

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;//->>显示昵称
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;//->>显示生日
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;//->>显示地址
@property (weak, nonatomic) IBOutlet UIButton *boyBtn;//->>男按钮
@property (weak, nonatomic) IBOutlet UIButton *girlBtn;//->>女按钮
@property (strong, nonatomic) AFHTTPSessionManager *session;
@end
@implementation XMUserInfoView



-(void)awakeFromNib
{
    
    
    [super awakeFromNib];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //!< 性别
    NSString *sex = [defaults objectForKey:@"userInfo_sex"];
    
    if (sex == nil || sex.length == 0)
    {
        //!< 没有请求到数据，默认为男
        self.boyBtn.selected = YES;
        
        [defaults setObject:@"1" forKey:@"userInfo_sex"];
        
    }else
    {
        if ([sex isEqualToString:@"1"])
        {
            self.boyBtn.selected = YES;
            
            self.girlBtn.selected = NO;
            
        }else
        {
            self.girlBtn.selected = YES;
            
            self.boyBtn.selected = NO;
        
        }
    
     }
    
    //!< 头像
     NSString *headerPath = [defaults objectForKey:@"userInfo_userImage"];
    
    if (headerPath.length > 0)
    {
        
        UIImage *image = [UIImage imageWithContentsOfFile:XIAOMI_HEADERLOCALPATH];
        
        if (image == nil)
        {
            

            //!< 第一次加载数据                        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSData *imageData = [NSData dataWithContentsOfFile: headerPath];
               
             dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImage *downloadImage = [UIImage imageWithData:imageData];
                
                [_headerBtn setImage:downloadImage forState:UIControlStateNormal];

            });
                
            });
            
         }else
        {
            
         [_headerBtn setImage:image forState:UIControlStateNormal];
        
        }
        
       
    }else
    {
         [_headerBtn setImage:[UIImage imageNamed:@"selfSetting_default"] forState:UIControlStateNormal];
    
    }
    
    
    //!< 签名
    NSString *signName = [defaults objectForKey:@"userInfo_signName"];
    
    if (signName.length > 0)
    {
        self.signName.text = signName;
    }else
    {
         self.signName.text = @"设置个性签名";
        
        [defaults setObject:@"设置个性签名" forKey:@"userInfo_signName"];
    
    }
    
    
    
    //!< 生日
    
    NSString *birthday = [defaults objectForKey:@"userInfo_birthday"];
    
    self.birthdayLabel.text = birthday;
    
    
    
    //!< 地区
    
    NSString *area = [defaults objectForKey:@"userInfo_area"];
    
    self.addressLabel.text = area;

    
    
    //!< 昵称userInfo_nickName
    NSString *nickName = [defaults objectForKey:@"userInfo_nickName"];
    
    
    
    self.nickName = nickName;
    
    _headerBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
 
}

- (AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _session.requestSerializer.timeoutInterval = 10;
    }
    
    return _session;


}

//->>通知代理点击设置头像
- (IBAction)headerBtn:(UIButton *)sender {
    
    if([self.delegate respondsToSelector:@selector(userInfoViewHeaderDidClick:)])
    {
        
        [self.delegate userInfoViewHeaderDidClick:self];
    }
    
}

//->>通知代理点击设置个性签名
- (IBAction)firstClick:(UITapGestureRecognizer *)sender {
     
   if([self.delegate respondsToSelector:@selector(userInfoViewSignNameDidClick:)])
   {
   
       [self.delegate userInfoViewSignNameDidClick:self];
   }
}

//->>通知代理点击昵称
- (IBAction)secondClick:(UITapGestureRecognizer *)sender {
    
    if([self.delegate respondsToSelector:@selector(userInfoViewNickNameDidClick:)])
    {
        
        [self.delegate userInfoViewNickNameDidClick:self];
    }
}

//->>通知代理点击生日
- (IBAction)fourthClick:(UITapGestureRecognizer *)sender {
  
    
    if([self.delegate respondsToSelector:@selector(userInfoViewBirthdayDidClick:)])
    {
        
        [self.delegate userInfoViewBirthdayDidClick:self];
    }
}

//->>通知代理点击地址
- (IBAction)fivthClick:(id)sender {
    
    
    if([self.delegate respondsToSelector:@selector(userInfoViewAddressDidClick:)])
    {
        
        [self.delegate userInfoViewAddressDidClick:self];
    }
    
}

//->>点击男按钮
- (IBAction)manBtnClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected)
    {
        _girlBtn.selected = NO;
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"userInfo_sex"];
     
    }
    
    
    
 }

//->>点击女按钮
- (IBAction)girlBtnClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
     if (sender.selected)
     {
        _boyBtn.selected = NO;
         
         [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"userInfo_sex"];
        
     }
    
    
    

    
    
} 

 
#pragma mark --- setter

//->>设置头像
- (void)setImage:(UIImage *)image
{
    _image = image;
    
     [_headerBtn setImage:image forState:UIControlStateNormal];
    
    [_headerBtn setImage:image forState:UIControlStateHighlighted];
  

}

//->>设置个性签名
- (void)setSign:(NSString *)sign
{
    _sign = sign;
    
    _signName.text = sign;
    
    [[NSUserDefaults standardUserDefaults] setObject:sign forKey:@"userInfo_signName"];
    

}

//->>设置昵称
- (void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    
    self.nickNameLabel.text = nickName;
    
     [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:@"userInfo_nickName"];

}



//->>设置生日
- (void)setBirthday:(NSString *)birthday
{
    _birthday = birthday;
    
    _birthdayLabel.text = birthday;
    
     [[NSUserDefaults standardUserDefaults] setObject:birthday forKey:@"userInfo_birthday"];

}

//->>设置地区
- (void)setAddress:(NSString *)address
{
    _address = address;
    
    self.addressLabel.text = address;
    
    [[NSUserDefaults standardUserDefaults] setObject:address forKey:@"userInfo_area"];


}
@end
