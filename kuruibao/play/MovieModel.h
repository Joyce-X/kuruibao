//
//  MovieModel.h
//  FRIILENS
//
//  Created by 智恒创 on 15/11/5.
//  Copyright © 2015年 zorro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject
@property (nonatomic, strong) NSString *cmd;     //
@property (nonatomic, strong) NSString *status;  //状态
@property (nonatomic, strong) NSString *value;   //
@property (nonatomic, strong) NSMutableArray *namesArray;//名字集合
@end
