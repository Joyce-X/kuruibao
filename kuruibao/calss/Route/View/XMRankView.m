//
//  XMRankView.m
//  kuruibao
//
//  Created by x on 16/12/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/**********************************************************
 class description:显示排名的自定义视图
 
 **********************************************************/

#import "XMRankView.h"
#import "NSString+extention.h"

#define labelHeight 10

@interface XMRankView()


@property (nonatomic,weak)UILabel* typeLabel;//!< 显示项目名称

@property (nonatomic,weak)UILabel* rankLabel;//!< 排名label

@property (nonatomic,weak)UIImageView* imageView;//!< 显示的图片

@property (nonatomic,weak)UILabel* scoreLabel;//!< 得分label

@property (nonatomic,weak)UILabel* timeLabel;//!< 时长label

@property (nonatomic,weak)UILabel* averageLabel;//!<平均值

@property (nonatomic,weak)UILabel* text1Label;//!< 第一项对应的文字

@property (nonatomic,weak)UILabel* text2Label;//!< 第一项对应的值

@property (nonatomic,weak)UILabel* text3Label;//!< 第一项对应的值

@property (nonatomic,weak)UILabel* paiwei;

@end
@implementation XMRankView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
        [self setupInit];
        
    }
    
    return self;


}

- (void)setupInit
{
    
    
     CGSize size1 = [self getSizeWithFont:12 text:@"急转弯"];//!< 显示排位文字的宽度
    
     CGSize size2 = [self getSizeWithFont:14 text:@"577"];//!< 显示数字文字的宽度
    
    
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 添加排位label
    
    UILabel *paiWei = [self labelWithText:@"排位" fontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentRight];
    
    [self addSubview:paiWei];
    
    self.paiwei = paiWei;
    
    [paiWei mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self).offset(15);
        
        make.left.equalTo(self).offset(9);
        
        make.size.equalTo(size1);
         
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加类型名称
    UILabel *typeLabel = [self labelWithText:nil fontSize:12 textColor:[UIColor whiteColor] alignment:NSTextAlignmentRight];
    
    [self addSubview:typeLabel];
    
    self.typeLabel = typeLabel;
    
    [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(paiWei);
        
        make.left.equalTo(paiWei);
        
        make.top.equalTo(paiWei.mas_bottom).offset(5);
         
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加排名label
    
    CGFloat fontSize = mainSize.width < 375 ? 30 : 38;
    
    UILabel *rankLabel = [self labelWithText:@"0" fontSize:fontSize textColor:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
    
    rankLabel.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    
    [self addSubview:rankLabel];
    
    self.rankLabel = rankLabel;
    
    CGSize size = [@"1234" sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:fontSize]}];
    
    [rankLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(size);
        
        make.bottom.equalTo(typeLabel);
        
        make.left.equalTo(paiWei.mas_right).offset(5);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 图标
    UIImageView *imageView = [[UIImageView alloc]init];
        
    imageView.image = [UIImage imageNamed:@"Track_purpleArrow"];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:imageView];
    
    self.imageView = imageView;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(rankLabel.mas_right).offset(2);
        
        make.right.equalTo(self).offset(-2);
        
        make.bottom.equalTo(rankLabel).offset(-6);
        
        make.height.equalTo(15);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示得分文字
    UILabel *score = [self labelWithText:@"得分" fontSize:12 textColor:XMGrayColor alignment:NSTextAlignmentCenter];
    
    [self addSubview:score];
    
    self.text1Label = score;
    
    [score mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(paiWei);
 
        make.left.equalTo(paiWei);
        
        make.top.equalTo(typeLabel.mas_bottom).offset(10);
    }];
    
    //!< 显示分数
    UILabel *scoreLabel = [self labelWithText:@"0" fontSize:14 textColor:XMGrayColor alignment:NSTextAlignmentCenter];
    
    [self addSubview:scoreLabel];
    
    self.scoreLabel = scoreLabel;
    
    [scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(score);
        
        make.top.equalTo(score.mas_bottom).offset(6);
        
        make.size.equalTo(size2);
        
    }];
    //-----------------------------seperate line---------------------------------------//
    
    //!< 添加百公里文字
    UILabel *average = [self labelWithText:@"百公里" fontSize:12 textColor:XMGrayColor alignment:NSTextAlignmentCenter];
    
    [self addSubview:average];
    
    self.text3Label = average;
    
    [average mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(score);
        
        make.right.equalTo(self).offset(-FITWIDTH(18));
        
        make.size.equalTo(score);
        
    }];
    
    
    
    //!< 添加百公里平均数
    
    UILabel *averageLabel = [self labelWithText:@"" fontSize:14 textColor:XMGrayColor alignment:NSTextAlignmentCenter];
    
    [self addSubview:averageLabel];
    
    self.averageLabel = averageLabel;
    
    [averageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(scoreLabel);
        
        make.centerX.equalTo(average);
        
        make.size.equalTo(scoreLabel);
        
    }];
    //-----------------------------seperate line---------------------------------------//
    
    //!< 显示时长文字
    
    UILabel *time = [self labelWithText:@"次数" fontSize:12 textColor:XMGrayColor alignment:NSTextAlignmentCenter];
    
    [self addSubview:time];
    
    self.text2Label = time;
    
    [time mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(score.mas_right);
        
        make.top.equalTo(score);
        
        make.right.equalTo(average.mas_left);
        
        make.height.equalTo(size1.height);
        
    }];
    
    //!<显示时长数字
    UILabel *timeLabel = [self labelWithText:@"0" fontSize:14 textColor:XMGrayColor alignment:NSTextAlignmentCenter];
    
//    timeLabel.backgroundColor = XMRandomColor;
    
    [self addSubview:timeLabel];
    
    self.timeLabel = timeLabel;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(scoreLabel);
        
        make.centerX.equalTo(time);
        
        make.height.equalTo(scoreLabel);
        
        make.width.equalTo(time);
        
    }];
    
    
    
    
}

- (UILabel *)labelWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment
{
    UILabel *label = [UILabel new];
    
    label.font = [UIFont systemFontOfSize:fontSize];
    
    label.textAlignment = alignment;
    
    label.text = text;
    
    label.textColor = textColor;
    
    label.adjustsFontSizeToFitWidth = YES;
    
//    label.backgroundColor = XMRandomColor;
    
     return label;
   
}


- (CGSize)getSizeWithFont:(CGFloat)fontSize text:(NSString *)text
{
    return  [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
 
}

#pragma mark -------------- setter

//!< 显示的类型
-(void)setTypeName:(NSString *)typeName
{
    _typeName = typeName;
    
    if (typeName.length > 3)
    {
        
       CGSize size = [self getSizeWithFont:12 text:@"弯道加速"];
        
        [self.typeLabel remakeConstraints:^(MASConstraintMaker *make) {
           
            make.right.equalTo(_paiwei).offset(5);
            
            make.size.equalTo(size);
            
            make.top.equalTo(_paiwei.mas_bottom).offset(3);
            
            
        }];
        
        
    }
    
    self.typeLabel.text = typeName;
    
}

//!< 设置名次
- (void)setRank:(NSString *)rank
{
    _rank = rank;
    
    _rankLabel.text = rank;
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    
    NSString *key = self.typeLabel.text;
    
    NSInteger lastRank = [df integerForKey:key];
    
    NSInteger currentRank = rank.integerValue;
    
    UIImage *image = nil;
    
    if (currentRank > lastRank)
    {
       image = [UIImage imageNamed:@"Track_greenArrow"];
        
    }else if(currentRank == lastRank)
    {
        image = [UIImage imageNamed:@"Track_purpleArrow"];
        
    }else
    {
        image = [UIImage imageNamed:@"Track_redArrow"];
    
    }
        
    self.imageView.image = image;
    
    [df setInteger:currentRank forKey:key];
    
    [df synchronize];
    
}

//!< 设置图片
- (void)setImage:(UIImage *)image
{

    _image = image;
    
    _imageView.image = image;

}

//!< 设置第一项文字内容

-(void)setText1:(NSString *)text1
{
    _text1 = text1;
    
    _text1Label.text = text1;

 }

//!< 设置第二项文字内容

-(void)setText2:(NSString *)text2
{
    _text2 = text2;
    
    _text2Label.text = text2;
    
}


//!< 设置第三项文字内容

-(void)setText3:(NSString *)text3
{
    _text3 = text3;
    
    _text3Label.text = text3;
    
}

//!< 设置第一项的值

- (void)setValue1:(NSString *)value1
{
    _value1 = value1;
    
    _scoreLabel.text = value1;

}

//!< 设置第二项的值

-(void)setValue2:(NSString *)value2
{

    _value2 = value2;
    
    _timeLabel.text = value2;

}

//!< 设置第三项的值

- (void)setValue3:(NSString *)value3
{
    _value3 = value3;
    
    _averageLabel.text = value3;

}

@end
