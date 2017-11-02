//
//  XMLabel.m
//  kuruibao
//
//  Created by x on 16/8/10.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMLabel.h"

@implementation XMLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.textColor = XMColorFromRGB(0xF8F8F8);
        self.adjustsFontSizeToFitWidth = YES;

    }
    
    return self;
}
 
@end
