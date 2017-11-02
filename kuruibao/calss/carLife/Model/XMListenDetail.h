//
//  XMListenDetail.h
//  喜马拉雅测试
//
//  Created by x on 17/4/17.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
 每一条听单详细信息 对应的数据模型
 
 1 包含一个听单编辑模型
 
 2 包含一个对应的数组 存档听单列表，对应模型XMColumn_itemModel
 
 
 ************************************************************************************************/


#import <Foundation/Foundation.h>
#import "XMColumn_editorModel.h"
#import "XMColumn_itemModel.h"


@interface XMListenDetail : NSObject

@property (assign, nonatomic) int ID;

@property (copy, nonatomic) NSString *logo_small;//!< logo小图标

@property (copy, nonatomic) NSString *cover_url_large;//!< 封面大图

@property (copy, nonatomic) NSString *kind;//!< 固定值

@property (copy, nonatomic) NSString *column_intro;//!< 听单简介

@property (assign, nonatomic) int column_content_type;//!< 听单的内容类型

@property (strong, nonatomic) XMColumn_editorModel *column_editor;//!< 听单编辑

@property (strong, nonatomic) NSArray<XMColumn_itemModel *> *column_items;//!< 听单项目列表

@end


