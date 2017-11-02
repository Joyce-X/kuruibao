//
//  XMVideoModel.h
//  GKDVR
//
//  Created by x on 16/10/28.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMVideoModel : NSObject

@property (assign, nonatomic) NSInteger videoid;

@property (copy, nonatomic) NSString *videoname;

@property (assign, nonatomic) NSInteger videostatus;

@property (copy, nonatomic) NSString *videotitle;

@property (assign, nonatomic) long filesize;

@property (assign, nonatomic) long videoduration;


+ (NSArray *)videoModelWithDictionary:(NSDictionary *)dictionary;




@end
