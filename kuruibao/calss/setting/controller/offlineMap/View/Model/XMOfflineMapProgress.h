//
//  XMOfflineMapProgress.h
//  kuruibao
//
//  Created by x on 16/10/17.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMOfflineMapProgress : NSObject

@property (strong, nonatomic) NSMutableDictionary *downloadStages;

//!< 返回单利对象
+ (instancetype)shareInstance;

@end
