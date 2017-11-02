//
//  XMDVRImageModel.m
//  GKDVR
//
//  Created by x on 16/10/27.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMDVRImageModel.h"

@implementation XMDVRImageModel


/*!
 @brief 将请求到的图片信息，转换成为模型信息
 */
+ (NSArray *)imageModelWithDictionary:(NSDictionary *)dictionary
{
    
    NSMutableArray *models = [NSMutableArray array];
    
    NSArray *preimages = dictionary[@"preimage"];
    
    for (NSDictionary *dic in preimages)
    {
        XMDVRImageModel *model = [[self alloc]initWithDictionary:dic];
        
        [models addObject:model];
    }

    return [models copy];


}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init])
    {
        self.imageid = [dic[@"imageid"] integerValue];
        
        self.imagename = dic[@"imagename"] ;
        
        self.imagetitle = dic[@"imagetitle"] ;
        
        self.imagestatus = [dic[@"imagestatus"] integerValue];
        
        self.filesize = [dic[@"filesize"] longValue];
    }

    return self;

}

@end
