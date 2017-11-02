//
//  XMPriceResultModel.h
//  kuruibao
//
//  Created by X on 2017/4/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPriceModel.h"

#import "MJExtension.h"

@interface XMPriceResultModel : NSObject

@property (nonatomic,assign)int error_code;

@property (nonatomic,copy)NSString* resultcode;

@property (nonatomic,copy)NSString* reason;

@property (nonatomic,strong)NSArray <XMPriceModel *> * result;

@end
