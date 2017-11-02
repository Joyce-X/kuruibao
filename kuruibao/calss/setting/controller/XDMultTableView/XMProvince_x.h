//
//  XMProvince.h
//  kuruibao
//
//  Created by x on 16/9/8.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMProvince_x : NSObject
/**
 *  省名或者直辖市名称
 */
@property (nonatomic,copy)NSString* provinceName;//->>

/**
 *  存放当前省或直辖市对应的市
 */
@property (nonatomic,strong)NSArray* citys;

+(NSArray *)loadData;


@end
