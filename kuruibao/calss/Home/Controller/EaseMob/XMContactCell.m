//
//  XMFriendCell.m
//  kuruibao
//
//  Created by x on 16/7/6.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMContactCell.h"

@interface XMContactCell()

//@property (nonatomic,weak)UILabel* nameLabel;


@end
@implementation XMContactCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}



/**
 *  cell的复用
 */
+ (instancetype)dequeueReusableCellWithTableview:(UITableView *)tableview
{
    static NSString *identifier = @"friendCell";
    XMContactCell *cell = [tableview dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[XMContactCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
 
        //-- 删除自带的两个没有用到的控件
        [self.detailTextLabel removeFromSuperview];
        [self.imageView removeFromSuperview];
        __weak typeof(self) weakSelf = self;
 
        
        //-- 添加加好友按钮  显示加好友或者邀请
        UIButton *addFriend = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addFriend.backgroundColor = XMColor(239, 239, 239);
        
        [addFriend addTarget:self action:@selector(addFriendBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:addFriend];
       
        [addFriend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakSelf.contentView);
            make.right.equalTo(weakSelf.contentView.mas_right).offset(-10);
            make.size.equalTo(CGSizeMake(60, 25));
        }];
        
        self.addFriend = addFriend;
        
        
        //-- 添加群主的转让按键
        UIButton *transferButton = [UIButton buttonWithType:UIButtonTypeSystem];
        transferButton.backgroundColor = XMColor(239, 239, 239);
        [transferButton addTarget:self action:@selector(transferButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        transferButton.hidden = YES;
        [self.contentView addSubview:transferButton];
        
        [transferButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakSelf.contentView);
            make.right.equalTo(addFriend.mas_left).offset(-10);
            make.size.equalTo(CGSizeMake(60, 25));
        }];
        
        self.transferButton = transferButton;
        
    }
    
    return self;
}


/**
 *  设置联系人模型
 */
- (void)setContact:(XMContact *)contact
{
    _contact = contact;
    self.textLabel.text = contact.name;
    
    
//    if (contact.phones.count == 0)
//    {
//        self.detailTextLabel.text = @"无电话号码";
//        return;
//    }
//    self.detailTextLabel.text = contact.phones[0];

}



/**
 *  添加好友或者邀请按钮被点击
 */
- (void)addFriendBtnDidClick:(UIButton *)sender
{
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"踢出"] || [title isEqualToString:@"添加"] )
    {
        //-- 发送通知被点击 ，当这个cell在显示群内好友和群外好友时候使用，发送这个通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"operationBtnClick" object:nil userInfo:@{@"title":[sender titleForState:UIControlStateNormal],@"user":self.textLabel.text}];
        [sender setTitle:@"已发送" forState:UIControlStateNormal];
        
    }else
    {
    
        //-- 发送通知被点击  当这个cell在手机联系人界面使用的时候，标题为添加或者邀请，发送这个通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addFriendBtnDidClick" object:nil userInfo:@{@"title":[sender titleForState:UIControlStateNormal],@"contact":self.contact}];
    
    }
   
    
    
}



/**
 *  转让群主按钮被点击
 */
- (void)transferButtonDidClick:(UIButton *)sender
{
    
     XMLOG(@"转让按钮被点击");  //-- 点击转让群组的时候会发这个通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"transferGroupOwnerNotification" object:nil userInfo:nil];
    
}
@end
