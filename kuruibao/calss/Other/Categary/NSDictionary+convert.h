//
//  NSDictionary+convert.h
//  kuruibao
//
//  Created by x on 16/11/17.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (convert)

//!< 将字典中的NSNull 转换为@“”
+(NSDictionary *)nullDic:(NSDictionary *)myDic;

@end
