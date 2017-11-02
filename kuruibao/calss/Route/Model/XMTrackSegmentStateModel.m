//
//  XMTrackSegmentStateModel.m
//  kuruibao
//
//  Created by x on 16/11/29.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/**********************************************************
 class description:一天内分段行程的模型数据
 
 **********************************************************/
#import "XMTrackSegmentStateModel.h"

@interface XMTrackSegmentStateModel()

 
@end

@implementation XMTrackSegmentStateModel


- (instancetype)initWithDictionary:(NSDictionary *)dic
{

    self = [super init];
    
    if (self)
    {
        self.xingchengstatus = [dic[@"xingchengstatus"] boolValue];
        
        self.starttime = dic[@"starttime"];
        
        self.endtime = dic[@"endtime"];
        
        self.penyou = dic[@"penyou"];
        
        self.penyou = [NSString stringWithFormat:@"%.1f",self.penyou.floatValue];
        
        self.licheng = dic[@"licheng"];
        
        
        self.xingshiTime = dic[@"xingshitime"];
        
        self.daisuTime = dic[@"daisutime"];
        
        self.jishache = dic[@"jishache"];
        
        self.jijiayou = dic[@"jijiayou"];
        
        self.comfortscore = dic[@"comfortscore"];
        
        self.xingchengid = dic[@"xingchengid"];
        
        //!< 对时间进行处理
        [self formatterxiangshiTime];
        
        
    }


    return self;



}

- (void)formatterxiangshiTime
{
    int time = self.xingshiTime.intValue;
    
    if (time < 60)
    {
        //!< 不到一分钟
        self.xingshiTime = [self.xingshiTime stringByAppendingString:@"s"];
        
    }else if(time < 3600)
    {
        //!< 不到一小时
        int  sec = time % 60;
        int min = time / 60;
        
        self.xingshiTime = [NSString stringWithFormat:@"%dm%ds",min,sec];
    
    }else
    {
        //!< 大于一小时
        int hour = time / 3600;
        
        int min = (time % 3600) / 60;
        
        int sec = time % 60;
        
        self.xingshiTime = [NSString stringWithFormat:@"%dh%dm%ds",hour,min,sec];
    
    
    }
    
    
}

@end
