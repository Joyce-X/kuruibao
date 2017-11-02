//
//  XMTroubleItemModel.m
//  kuruibao
//
//  Created by x on 16/11/21.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMTroubleItemModel.h"

@implementation XMTroubleItemModel


- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    
    self = [super init];
    
    if (self)
    {
    
        [self setValuesForKeysWithDictionary:dic];

        
    }
    
    return self;

}

@end
