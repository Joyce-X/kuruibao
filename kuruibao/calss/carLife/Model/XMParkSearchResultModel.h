//
//  XMParkSearchResultModel.h
//  kuruibao
//
//  Created by X on 2017/4/25.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMParkStationModel.h"

#import "MJExtension.h"

@interface XMParkSearchResultModel : NSObject

@property (nonatomic,copy)NSString* reason;

@property (nonatomic,assign)int error_code;

@property (nonatomic,assign)int count;

@property (nonatomic,strong)NSArray<XMParkStationModel *>* result;



@end
