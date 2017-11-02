//
//  XMDVRImageModel.h
//  GKDVR
//
//  Created by x on 16/10/27.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:图片信息转换成为图片模型
 
 **********************************************************/
#import <Foundation/Foundation.h>

@interface XMDVRImageModel : NSObject

@property (assign, nonatomic) NSInteger imageid;//!< 图片id

@property (copy, nonatomic) NSString *imagename;//!< 图片名称

@property (assign, nonatomic) NSInteger imagestatus;//!< 图片状态

@property (copy, nonatomic) NSString *imagetitle;//!< 标题

@property (assign, nonatomic) long filesize;//!< 大小


+ (NSArray *)imageModelWithDictionary:(NSDictionary *)dictionary;

@end
