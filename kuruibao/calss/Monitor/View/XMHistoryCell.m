//
//  XMHistoryCell.m
//  kuruibao
//
//  Created by x on 17/5/27.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMHistoryCell.h"


@interface XMHistoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *number;

@end


@implementation XMHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDic:(NSDictionary *)dic
{

    _dic = dic;
    
    NSString *time = dic[@"createtime"];
    
    //!< 分为年月日字符串 和时分秒字符串
    NSArray *timeArr = [time componentsSeparatedByString:@"T"];
    
    NSString *dayStr = [timeArr.firstObject stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    
    NSString *secondStr = [timeArr.lastObject substringWithRange:NSMakeRange(0, 8)];
    
    secondStr = [secondStr stringByReplacingOccurrencesOfString:@":" withString:@"."];
    
    self.timeLabel.text = [@"检测时间:" stringByAppendingFormat:@"%@ %@",dayStr,secondStr];

    NSString *str =  dic[@"errorcodeindex"];
    
    NSArray *arr = [str componentsSeparatedByString:@","];
    
    int troubleNum;
    
    int score;
    
    if (arr.count == 1)
    {
        self.number.text = @"1个故障";
        
        troubleNum = 1;
        
        score = 85;
        
    }else
    {
        troubleNum = (int)arr.count;
        
        self.number.text = [NSString stringWithFormat:@"%ld个故障",arr.count];
    
        score = 85 - 10 * (int)arr.count;
        
        if (score<0)
        {
            score = 0;
        }
        
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",score];
    
    

}

@end
