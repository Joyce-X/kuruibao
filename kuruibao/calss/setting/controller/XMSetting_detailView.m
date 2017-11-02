//
//  XMSetting_detailView.m
//  kuruibao
//
//  Created by x on 16/9/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 设置界面的自定义view
 
 
 ************************************************************************************************/
#import "XMSetting_detailView.h"
@interface XMSetting_detailView()
@property (weak, nonatomic) IBOutlet UIButton *isPush;

@end
@implementation XMSetting_detailView

//->>点击账户
- (IBAction)setAccount:(UITapGestureRecognizer *)sender {
    if(self.setAccount)
    {
        _setAccount();
    }
}
//->>点击离线地图
- (IBAction)offLine:(id)sender {
    if (_offLineMap)
    {
        _offLineMap();
    }
}

//->>点击帮助
- (IBAction)helpClick:(id)sender {
    if (_helping)
    {
    _helping();
    }
}

//->>点击用户反馈
- (IBAction)userBack:(id)sender {
    if (_userBack)
    {
        _userBack();
    }
}

//->>点击给我们好评
- (IBAction)haoPingClick:(id)sender {
    XMLOG(@"2222");
    if (_haoPing)
    {
        XMLOG(@"1111");
        _haoPing();
    }
}
//->>点击消息推送按钮
- (IBAction)messagePushClick:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pushMessageBtnDidClick:)])
    {
        [self.delegate pushMessageBtnDidClick:sender];
    }
    
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    self.isPush.selected = isSelected;

}

+ (instancetype)shared
{
    return [[[NSBundle mainBundle] loadNibNamed:@"XMSetting_detailView" owner:nil options:nil] firstObject];
}

@end
