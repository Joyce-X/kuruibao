//
//  NSString+extention.h
//  kuruibao
//
//  Created by x on 16/7/13.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (extention)


/**
 *  转换成拼音
 */
+(NSString *)lowercaseSpellingWithChineseCharacters:(NSString *)chinese;


/**
 *  根据文字算宽度
 */
- (CGFloat)getWidthWith:(CGFloat )fontSize;
@end
