//
//  XMColumn_itemModel.h
//  喜马拉雅测试
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMSubordinated_albumModel.h"
#import "XMAnnouncerModel.h"

@interface XMColumn_itemModel : NSObject

@property (assign, nonatomic) int ID;

@property (assign, nonatomic) int comment_count;

@property (copy, nonatomic) NSString *cover_url_middle;

@property (assign, nonatomic) int favorite_count;

@property (assign, nonatomic) int can_download;

@property (assign, nonatomic) long created_at;


@property (copy, nonatomic) NSString *cover_url_large;

@property (copy, nonatomic) NSString *cover_url_small;

@property (strong, nonatomic) XMSubordinated_albumModel *subordinated_album;

@property (copy, nonatomic) NSString *play_url_32;

@property (copy, nonatomic) NSString *track_title;

@property (strong, nonatomic) XMAnnouncerModel *announcer;

@property (assign, nonatomic) int duration;

@property (copy, nonatomic) NSString *kind;

@property (assign, nonatomic) int share_count;

@property (assign, nonatomic) int play_count;

@property (copy, nonatomic) NSString *play_url_64;

@end


