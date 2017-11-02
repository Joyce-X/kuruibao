//
//  XMCommonView.m
//  kuruibao
//
//  Created by x on 16/12/6.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/**********************************************************
 class description:用来展示常用地址，和直接进行导航
 
 **********************************************************/

#import "XMCommonView.h"

@interface XMCommonView()
{
    UIImageView *_imageIV;
    
    UILabel *_addressLabel;


}


@end

@implementation XMCommonView


- (instancetype)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setupInit];
        
    }
    
    return self;


}

- (void)setupInit
{
    _imageIV = [[UIImageView alloc]init];
    
    _imageIV.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:_imageIV];
    
    [_imageIV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.equalTo(CGSizeMake(35, 35));
        
        make.left.equalTo(self).offset(FITWIDTH(19));
        
        make.top.equalTo(self).offset(18);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    //!< 导航按钮
    UIButton *naviBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [naviBtn setImage:[UIImage imageNamed:@"map_commonNavi_normal"] forState:UIControlStateNormal];
    
    [naviBtn setImage:[UIImage imageNamed:@"map_commonNavi_highlighted"] forState:UIControlStateHighlighted];
    
    [naviBtn addTarget:self action:@selector(naviBtnDicClick) forControlEvents:UIControlEventTouchUpInside];
    
    naviBtn.contentEdgeInsets = UIEdgeInsetsMake(24, 15, 24, 15);
    
    [self addSubview:naviBtn];
    
    [naviBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(self);
        
        make.top.equalTo(self);
        
        make.bottom.equalTo(self);
        
        make.width.equalTo(45);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    //!< 显示地址
    _addressLabel = [UILabel new];
    
    _addressLabel.font = [UIFont systemFontOfSize:10];
    
    _addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _addressLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:_addressLabel];
    
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self).offset(34);
        
        make.left.equalTo(_imageIV.mas_right).offset(12);
        
        make.height.equalTo(10);
        
        make.right.equalTo(naviBtn.mas_left);
        
        
    }];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    
    [self addGestureRecognizer:longPress];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    
    [self addGestureRecognizer:tap];
    
}



#pragma mark -------------- setter
- (void)setImage:(UIImage *)image
{
    _image = image;
    
    _imageIV.image = image;

}

-(void)setAddress:(NSString *)address
{
    _address = address;
    
    _addressLabel.text = address;


}

#pragma mark -------------- btn click

//!< 点击导航按钮
- (void)naviBtnDicClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commonViewNaviBtnDidClick:)])
    {
        [self.delegate commonViewNaviBtnDidClick:self];
    }
    
    
}
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(commonViewDidTriggerLongPress:)])
        {
            [self.delegate commonViewDidTriggerLongPress:self];
        }
    
    }
   
    
    
}

- (void)tap:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commonViewDidClick:)])
    {
        [self.delegate commonViewDidClick:self];
    }



}
@end
