//
//  XMMapOperateView.m
//  kuruibao
//
//  Created by x on 16/11/24.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:展示搜索结果上边的操作视图
 
 **********************************************************/

#import "XMMapOperateView.h"

@interface XMMapOperateView()

@property (nonatomic,weak)UILabel* messageLabel;

@end

@implementation XMMapOperateView

- (instancetype)initWithTarget:(UIViewController *)target
{

    self = [super init];
    
    if (self)
    {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [backBtn setImage:[UIImage imageNamed:@"Map_searchBack"] forState:UIControlStateNormal];
        
        backBtn.contentEdgeInsets = UIEdgeInsetsMake(14.5, 13, 14.5, 16);
        
        [backBtn addTarget:target action:@selector(backToSearchList) forControlEvents:UIControlEventTouchDown];
        
         [self addSubview:backBtn];
        
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self);
            
            make.top.equalTo(self);
            
            make.bottom.equalTo(self);
            
            make.width.equalTo(50);
            
        }];
        
        
        //-----------------------------seperate line---------------------------------------//
        
        UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        exitBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [exitBtn setImage:[UIImage imageNamed:@"Map_searchX"]  forState:UIControlStateNormal];
        
        [exitBtn addTarget:target action:@selector(exitToMapView) forControlEvents:UIControlEventTouchDown];
        
        
        [self addSubview:exitBtn];
        
        [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self);
            
            make.top.equalTo(self);
            
            make.bottom.equalTo(self);
            
            make.width.equalTo(50);
            
        }];

        
        //-----------------------------seperate line---------------------------------------//
        
        UILabel *message = [UILabel new];
        
        message.textColor = XMGrayColor;
        
        message.font = [UIFont systemFontOfSize:20];
        
        [self addSubview:message];
        
        self.messageLabel = message;
        
        [message mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self);
            
            make.bottom.equalTo(self);
            
            make.right.equalTo(exitBtn.mas_left).offset(-10);
            
            make.left.equalTo(backBtn.mas_right);
            
        }];
        
        
        
    }

    return self;

}

- (void)setMessage:(NSString *)message
{
    
    self.messageLabel.text = message;


}


@end
