//
//  XMColumnList.h
//  喜马拉雅测试
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
 每一次请求页面数据对应的数据模型，包含一个存放听单模型的数组
 
 ************************************************************************************************/
#import <Foundation/Foundation.h>
#import "XMColumn_x.h"
@interface XMColumnList_x : NSObject

@property (assign, nonatomic) int current_page;

@property (assign, nonatomic) int total_page;

@property (assign, nonatomic) int total_count;

//!< 听单数组
@property (strong, nonatomic) NSArray<XMColumn_x *> *columns;

@end
