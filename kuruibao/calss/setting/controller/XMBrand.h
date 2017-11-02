//
//  XMBrand.h
//  kuruibao
//
//  Created by x on 16/10/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMBrand : NSObject

@property (nonatomic, copy) NSString *obdcodetype;//!< OBD码库类别

@property (nonatomic, copy) NSString *brandnav;//!< 索引

@property (nonatomic, copy) NSString *brandname;//!< 品牌名称

@property (nonatomic, assign) NSInteger brandid;//!< 品牌编号
/**
 *  品牌首字母
 */
@property (nonatomic,copy)NSString* initial;
@end
