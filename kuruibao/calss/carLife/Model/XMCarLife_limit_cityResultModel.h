//
//  XMCarLife_limit_cityResultModel.h
//  kuruibao
//
//  Created by x on 17/5/12.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMCarLife_limit_cityModel.h"

#import "MJExtension.h"

@interface XMCarLife_limit_cityResultModel : NSObject

@property (copy, nonatomic) NSString *rspcode;//!< response code

@property (strong, nonatomic) NSArray<XMCarLife_limit_cityModel *> *data;

@end
