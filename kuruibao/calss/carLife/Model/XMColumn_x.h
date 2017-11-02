//
//  XMColumn.h
//  喜马拉雅测试
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//


/***********************************************************************************************
 
 每一天推荐的听单对应的数据模型
 
 ************************************************************************************************/

#import <Foundation/Foundation.h>

@interface XMColumn_x : NSObject

@property (assign, nonatomic) int is_hot;

@property (copy, nonatomic) NSString *cover_url_super_large;

@property (assign, nonatomic) int ID;

@property (copy, nonatomic) NSString *column_sub_title;

@property (copy, nonatomic) NSString *cover_url_small;

@property (copy, nonatomic) NSString *cover_url_large;

@property (assign, nonatomic) long  released_at;

@property (copy, nonatomic) NSString *kind;

@property (copy, nonatomic) NSString *column_title;

@property (assign, nonatomic) int column_content_type;

@property (copy, nonatomic) NSString *column_foot_note;

@end

/*
is_hot = 0;
cover_url_super_large = http://fdfs.xmcdn.com/group27/M00/A0/3D/wKgJW1jwaAri-TrqAAa44NzWZHw243_mobile_large.jpg;
id = 1053;
column_sub_title = 我喜欢这样的生活，波澜不惊，小桥流水，有家常夫妻的温暖;
cover_url_small = http://fdfs.xmcdn.com/group27/M00/A0/3E/wKgJW1jwaA-AyAy0AAa44NzWZHw255_mobile_small.jpg;
released_at = 1492156630000;
cover_url_large = http://fdfs.xmcdn.com/group27/M00/A0/3D/wKgJW1jwaAri-TrqAAa44NzWZHw243_mobile_medium.jpg;
kind = column;
column_title = 听完两个字，给你一辈子;
column_foot_note = 10首声音;
column_content_type = 2;
**/







