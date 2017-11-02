//
//  XMUserInfoView.h
//  kuruibao
//
//  Created by x on 16/9/6.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMUserInfoView;
@protocol XMUserInfoViewDelegate <NSObject,UITableViewDelegate>


/**
 *  点击个性签名
 */
- (void)userInfoViewSignNameDidClick:(XMUserInfoView *)userInfoView;
/**
 *  点击头像
 */
- (void)userInfoViewHeaderDidClick:(XMUserInfoView *)userInfoView;

/**
 *  点击昵称
 */
- (void)userInfoViewNickNameDidClick:(XMUserInfoView *)userInfoView;

/**
 *  点击生日
 */
- (void)userInfoViewBirthdayDidClick:(XMUserInfoView *)userInfoView;

/**
 *  点击地址
 */
- (void)userInfoViewAddressDidClick:(XMUserInfoView *)userInfoView;


@end


@interface XMUserInfoView : UIView
@property (nonatomic,weak)id<XMUserInfoViewDelegate> delegate;

@property (nonatomic,strong)UIImage* image;//->>提供设置头像的接口
@property (nonatomic,copy)NSString* nickName;//->>提供设置昵称的接口
@property (nonatomic,assign)BOOL isMan;//->>提供设置性别的接口
@property (nonatomic,copy)NSString* birthday;//->>设置生日
@property (nonatomic,copy)NSString* address;//->>地址
//@property (nonatomic,assign)BOOL needVerify;//->>是否需要验证
@property (nonatomic,copy)NSString* sign;//->>个性签名
@end
