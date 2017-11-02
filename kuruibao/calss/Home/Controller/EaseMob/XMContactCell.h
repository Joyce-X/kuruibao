//
//  XMFriendCell.h
//  kuruibao
//
//  Created by x on 16/7/6.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 这个cell用到显示谁联系人列表的时候 和 显示群内好友和群外好友的情况下
 
 
 
 ************************************************************************************************/

#import <UIKit/UIKit.h>
#import "XMContact.h"
@interface XMContactCell : UITableViewCell



/**
 *  转让群主按钮     显示群内好友时候用到
 */
@property (nonatomic,weak)UIButton* transferButton;


/**
 *  联系人模型  显示联系人模型时候用到
 */
@property (nonatomic,strong)XMContact* contact;

/**
 *  添加好友或者邀请好友  显示群内好友和手机联系人都有用到
 */
@property (nonatomic,weak)UIButton* addFriend;

+ (instancetype)dequeueReusableCellWithTableview:(UITableView *)tableview;

@end
