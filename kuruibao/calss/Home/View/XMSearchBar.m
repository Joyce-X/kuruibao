//
//  HMSearchBar.m
//  黑马微博
//
//  Created by apple on 14-7-4.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "XMSearchBar.h"

@implementation XMSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 设置背景
        self.backgroundColor = [UIColor whiteColor];
        
        self.font = [UIFont systemFontOfSize:14];
        
        self.borderStyle = UITextBorderStyleRoundedRect;
        
        // 设置内容 -- 垂直居中
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        // 设置左边显示一个放大镜
        UIImageView *leftView = [[UIImageView alloc] init];
        
         leftView.image = [UIImage imageNamed:@"searchbar_textfield_search_icon"];
        
        leftView.width = leftView.image.size.width + 10;
        
        leftView.height = leftView.image.size.height;
        
         // 设置leftView的内容居中
        leftView.contentMode = UIViewContentModeCenter;
        
        self.leftView = leftView;
        
         
         // 设置左边的view永远显示
        self.leftViewMode = UITextFieldViewModeAlways;
        
        // 设置右边永远显示清除按钮
        self.clearButtonMode = UITextFieldViewModeAlways;
        
       
        
    }
    return self;
}



+ (instancetype)searchBar
{
    return [[self alloc] init];
}
@end
