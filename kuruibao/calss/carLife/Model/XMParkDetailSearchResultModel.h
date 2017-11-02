//
//  XMParkDetailSearchResultModel.h
//  kuruibao
//
//  Created by x on 17/4/26.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMParkDetailModel.h"

#import "MJExtension.h"

@interface XMParkDetailSearchResultModel : NSObject

@property (copy, nonatomic) NSString *reason;

@property (assign, nonatomic) int error_code;

@property (strong, nonatomic) NSArray <XMParkDetailModel *> *result;

@end


 
