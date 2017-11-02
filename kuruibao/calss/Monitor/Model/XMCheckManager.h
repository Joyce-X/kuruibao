//
//  XMCheckManager.h
//  kuruibao
//
//  Created by x on 17/6/6.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMCheckManager : NSObject

/**
 是否正在检测
 */
@property (assign, nonatomic) BOOL isChecking;

+ (instancetype)shareManager;

@end
