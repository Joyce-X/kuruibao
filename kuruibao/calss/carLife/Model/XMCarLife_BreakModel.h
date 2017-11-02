//
//  XMCarLife_BreakModel.h
//  kuruibao
//
//  Created by x on 17/5/13.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMCarLife_BreakModel : NSObject

@property (copy, nonatomic) NSString *date;//!< 违章日期

@property (copy, nonatomic) NSString *area;//!< 违章地方

@property (copy, nonatomic) NSString *act;//!< 违章信息

@property (copy, nonatomic) NSString *code;//!< 违章代码

@property (copy, nonatomic) NSString *fen;//!< 处罚分数

@property (copy, nonatomic) NSString *money;//!< 罚款金额

@property (copy, nonatomic) NSString *handled;//!< 是否处理

@end
