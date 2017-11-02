//
//  XMCarLifeBtn.m
//  kuruibao
//
//  Created by x on 17/5/8.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMCarLifeBtn.h"

@implementation XMCarLifeBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    float btn_width = (mainSize.width - 58 - 83 - 41) / 4;
    
    
    
    return CGRectMake(0, 19, btn_width, btn_width);

}


- (CGRect)titleRectForContentRect:(CGRect)contentRect
{

    float btn_width = (mainSize.width - 58 - 83 - 41) / 4;
        
    return CGRectMake(-20, 19 + btn_width + 10, btn_width + 40, 13);


}

@end
