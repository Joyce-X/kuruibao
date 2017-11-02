//
//  XMVideoModel.m
//  GKDVR
//
//  Created by x on 16/10/28.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMVideoModel.h"

@implementation XMVideoModel



+ (NSArray *)videoModelWithDictionary:(NSDictionary *)dictionary
{
    
    NSMutableArray *models = [NSMutableArray array];
    
    NSArray *preimages = dictionary[@"prevideo"];
    
    for (NSDictionary *dic in preimages)
    {
        XMVideoModel *model = [[self alloc]initWithDictionary:dic];
        
        [models addObject:model];
    }
    
    return [models copy];
    
    
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init])
    {
        self.videoid = [dic[@"videoid"] integerValue];
        
        self.videoname = dic[@"videoname"] ;
        
        self.videotitle = dic[@"videotitle"] ;
        
        self.videostatus = [dic[@"videostatus"] integerValue];
        
        self.filesize = [dic[@"filesize"] longValue];
        
        self.videoduration = [dic[@"videoduration"] longLongValue];
    }
    
    return self;
    
}


@end
