//
//  XMDVRProgressView.m
//  GKDVR
//
//  Created by x on 16/10/28.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:
 
        下载视频的时候显示下载进度
 
 **********************************************************/
#import "XMDVRProgressView.h"

@interface XMDVRProgressView()

@property (nonatomic,weak)UIProgressView* progressView;

@property (nonatomic,weak)UILabel* showLabel;

@end
@implementation XMDVRProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithSuperView:(UIView *)view cancelHandler:(cancleBlock)cancelBlock
{
    self = [super init];
    
    if (self)
    {
        self.cancelBlock = cancelBlock;
        
        self.frame = view.bounds;
        
        [view addSubview:self];
        
        [self setupSubviews];
        
    }

    return self;

}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:0.5];
    
    UIProgressView *progress = [UIProgressView new];
    
    progress.progressTintColor = [UIColor greenColor];
    
    [self addSubview:progress];
    
    self.progressView = progress;
    
    [progress mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(self.centerY);
        
        make.left.equalTo(self).offset(50);
        
        make.right.equalTo(self).offset(-50);
        
        make.height.equalTo(5);
        
    }];
    
    
    UILabel *showLabel = [UILabel new];
    
    showLabel.textColor = [UIColor blackColor];
    
    showLabel.font = [UIFont systemFontOfSize:30];
    
    showLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:showLabel];
    
    self.showLabel = showLabel;
    
    [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
      
        
        make.bottom.equalTo(progress.mas_top).offset(-20);
        
        make.height.equalTo(50);
        
        make.left.equalTo(progress);
        
        make.right.equalTo(progress);
        
    }];
    
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cancelBtn setTitle:@"X" forState:UIControlStateNormal];
    
    [cancelBtn  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:40];
    
    [cancelBtn addTarget:self action:@selector(cancelBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    cancelBtn.frame = CGRectMake(300, 200, 60, 60);
    
    [self addSubview:cancelBtn];
    
}


- (void)setProgress:(float)progress
{
    _progress = progress;
    
    self.progressView.progress = progress;
    
    self.showLabel.text = [NSString stringWithFormat:@"下载进度:%d%%",(int)(progress * 100)];

}

- (void)cancelBtnDidClick
{
    if (self.cancelBlock)
    {
        self.cancelBlock();
    }
    
    [self removeFromSuperview];
    
}
@end
