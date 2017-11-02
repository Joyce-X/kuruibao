//
//  XMCity.h
//  kuruibao
//
//  Created by x on 16/9/8.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMCity : NSObject
/**
 *  市名称
 */
@property (nonatomic,copy)NSString* cityName;
/**
 *  区数组 存放当前市所有区的数组
 */
@property (nonatomic,strong)NSArray* areas;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end
