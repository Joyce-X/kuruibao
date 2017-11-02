//
//  XMCustomItemView.m
//  kuruibao
//
//  Created by x on 17/4/18.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCustomItemView.h"

@interface XMCustomItemView ()



@property (weak, nonatomic) UILabel *titleLabel;//!< titleLabel

@property (weak, nonatomic) UIButton *btn;
@end

@implementation XMCustomItemView


-(instancetype)init
{
    
    self = [super init];
    
    if (self)
    {
        
        [self setSubViews];
        
    }
    
    return self;
    
    
}


- (void)setSubViews
{
    
    //!< add imageView
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cirLIfe_placeholder"]];
    
    [self addSubview:imageView];
    
    self.imageView = imageView;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.top.right.bottom.equalTo(self);
        
    }];
    
    
    UIImageView *cover = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cover_image"]];
    
    
    
    [self addSubview:cover];
    
    [cover mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.top.right.bottom.equalTo(self);
        
    }];
    
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< add label
    UILabel *titleLabel = [UILabel new];
    
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.font = [UIFont systemFontOfSize:13];
    
    titleLabel.numberOfLines = 0;
    
    [self addSubview:titleLabel];
    
    self.titleLabel = titleLabel;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self).offset(5);
        
        make.right.equalTo(self).offset(-5);
        
        make.bottom.equalTo(self).offset(-5);
        
        make.height.equalTo(40);
        
    }];
    
    //-----------------------------seperate line---------------------------------------//
    
    //!< add clickBtn
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btn];
    
    self.btn = btn;
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.top.right.bottom.equalTo(self);

     }];
    
    
}

#pragma mark ------- btn click

//!< btn click
- (void)btnClick:(UIButton *)sender
{
 
    XMLOG(@"btn click");
    
    if (self.completion)
    {
        _completion(self);
    }
    
    
}

- (void)setTitle:(NSString *)title
{

    _title = title;
    
    self.titleLabel.text = title;


}


@end
