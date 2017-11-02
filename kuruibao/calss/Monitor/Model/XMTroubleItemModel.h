//
//  XMTroubleItemModel.h
//  kuruibao
//
//  Created by x on 16/11/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMTroubleItemModel : NSObject

@property (copy, nonatomic) NSString *codeid;

@property (copy, nonatomic) NSString *code;

@property (copy, nonatomic) NSString *codedesc;//!< 故障码描述

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
