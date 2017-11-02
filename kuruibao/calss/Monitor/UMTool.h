//
//  UMTool.h
//  kuruibao
//
//  Created by x on 17/7/12.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMTool : NSObject

/**
 体检时没有检测到问题项的时候上传信息到友盟
 */
+ (void)handleSuccellWithCarnumber:(NSString *)number;


/**
 检测到问题项时候，上传信息到友盟

 @param array 问题项数组
 */
+ (void)handleFailedWithArray:(NSArray *)array carNumber:(NSString *)number;

@end
