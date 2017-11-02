//
//  XMSearchCityListModel.h
//  kuruibao
//
//  Created by X on 2017/4/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMParkSupportCityModel.h"

#import "MJExtension.h"

@interface XMSearchCityListModel : NSObject

@property (nonatomic,assign)int error_code;

@property (nonatomic,copy)NSString* reason;

@property (nonatomic,strong)NSArray<XMParkSupportCityModel *>* result;


@end
 
