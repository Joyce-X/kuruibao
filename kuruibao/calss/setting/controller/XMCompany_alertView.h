//
//  XMCompany_alertView.h
//  kuruibao
//
//  Created by x on 17/5/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^completionBlock)();

@interface XMCompany_alertView : UIView


@property (copy, nonatomic) completionBlock clearBlock;//!< 点击清空按钮执行

+(instancetype)alertView;

@end
