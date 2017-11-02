//
//  XMRankView.h
//  kuruibao
//
//  Created by x on 16/12/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMRankView : UIView

@property (copy, nonatomic) NSString *typeName;//!< 类型的名称

@property (copy, nonatomic) NSString *rank;//!< 名次

@property (strong, nonatomic) UIImage *image;//!< 显示的图标

@property (copy, nonatomic) NSString *text1;//!< 显示得分位置的文字

@property (copy, nonatomic) NSString *text2;//!< 显示得分位置的文字

@property (copy, nonatomic) NSString *text3;//!< 显示得分位置的文字

@property (copy, nonatomic) NSString *value1;//!< 分值

@property (copy, nonatomic) NSString *value2;//!< 次数

@property (copy, nonatomic) NSString *value3;//!< 百公里平均数





@end
