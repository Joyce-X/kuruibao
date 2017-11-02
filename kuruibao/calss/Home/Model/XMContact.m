//
//  XMContact.m
//  kuruibao
//
//  Created by x on 16/7/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import "XMContact.h"
#import "NSString+extention.h"

@interface XMContact() 



@end

@implementation XMContact

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.phones = [NSMutableArray array];
    }
    return self;
}


- (void)setName:(NSString *)name
{
    //-- set姓名的时候，设置姓名的拼音
    _name = name;
    self.name_pinyin = [NSString lowercaseSpellingWithChineseCharacters:name];

}


//- (void)encodeWithCoder:(NSCoder *)encode
//{
//    [encode encodeObject:self.name forKey:@"name"];
//    [encode encodeObject:self.firstName forKey:@"firstName"];
//    [encode encodeObject:self.lastName forKey:@"lastName"];
//    [encode encodeObject:self.name_pinyin forKey:@"name_pinyin"];
//    [encode encodeObject:self.phones forKey:@"phones"];
//
//
//}
//- (nullable instancetype)initWithCoder:(NSCoder *)decoder
//{
//    //-- 反序列化
//    self = [super init];
//    if (self)
//    {
//        self.name_pinyin = [decoder decodeObjectForKey:@"name_pinyin"];
//        self.name = [decoder decodeObjectForKey:@"name"];
//        self.firstName = [decoder decodeObjectForKey:@"firstName"];
//        self.phones = [decoder decodeObjectForKey:@"phones"];
//
//        self.lastName = [decoder decodeObjectForKey:@"lastName"];
//
//    }
//    
//    return self;
//
//
//}
@end
