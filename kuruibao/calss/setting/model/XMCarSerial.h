//
//  XMCarSerial.h
//  TestDemo
//
//  Created by x on 16/8/23.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 展示车系数据的模型
 
 
 ************************************************************************************************/

#import <Foundation/Foundation.h>

@interface XMCarSerial : NSObject

@property (nonatomic, assign) NSInteger seriesid;//!< 系列编号

@property (nonatomic, copy) NSString *seriesname;//!< 系列名称


@end
