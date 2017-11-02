//
//  XMOfflineMapProgress.m
//  kuruibao
//
//  Created by x on 16/10/17.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMOfflineMapProgress.h"


static XMOfflineMapProgress *offlineProgress = nil;

@implementation XMOfflineMapProgress


+ (instancetype)shareInstance
{

    if (offlineProgress == nil)
    {
        offlineProgress = [[self alloc]init];
    }
    
    return offlineProgress;
     

}

- (instancetype)init
{
    if (self = [super init])
    {
        self.downloadStages = [NSMutableDictionary dictionary];
        //!< 正在下载的数组
        [self.downloadStages setObject:[NSMutableArray array] forKey:@"downloading"];
        
        //!< 下载完成的数组
        [self.downloadStages setObject:[NSMutableArray array] forKey:@"cache"];
    }
    
    return self;
}

@end
