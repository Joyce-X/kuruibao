//
//  BoolTool.h
//  GuoKeDV
//
//  Created by zxc-02 on 16/8/9.
//  Copyright © 2016年 zxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"

#define BoolToolManager  [BoolTool sharedInstance]
@interface BoolTool : NSObject

@property (nonatomic, assign)BOOL isBegin;   //首次加载直播A
@property (nonatomic, assign)BOOL isBeginB;  //首次加载直播B

AS_SINGLETON(BoolTool)

@end
