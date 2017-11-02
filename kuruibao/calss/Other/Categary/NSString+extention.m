//
//  NSString+extention.m
//  kuruibao
//
//  Created by x on 16/7/13.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "NSString+extention.h"

@implementation NSString (extention)
 

+(NSString *)lowercaseSpellingWithChineseCharacters:(NSString *)chinese {
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:chinese];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    //返回小写拼音
    return [str lowercaseString];
}


- (CGFloat)getWidthWith:(CGFloat )fontSize
{

    if([self isEqualToString:@""] || self == nil)
    {
        return 0;
    
    }
    CGSize size = [self sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]}];
    return size.width;

}
@end
