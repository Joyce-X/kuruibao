//
//  XMCheckManager.m
//  kuruibao
//
//  Created by x on 17/6/6.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCheckManager.h"

static XMCheckManager *manager;

@implementation XMCheckManager


+ (instancetype)shareManager
{
    if (manager == nil)
    {
        
        manager = [[XMCheckManager alloc]init];
        
        
        
    }
    
    return manager;

}

@end
