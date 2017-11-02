//
//  XMContact.h
//  kuruibao
//
//  Created by x on 16/7/12.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMContact : NSObject

 
@property (nonatomic, copy  ) NSString *name;//解析后 真正的name
@property (nonatomic, copy  ) NSString *name_pinyin;//解析后 真正的pinyin name
@property (nonatomic, copy  ) NSString *firstName;//-- 名
@property (nonatomic, copy  ) NSString *lastName;//-- 姓
@property (nonatomic, strong) NSMutableArray  *phones;//联系人可能有多个电话

//@property (nonatomic, copy  ) NSString *midName;
//@property (nonatomic, copy  ) NSString *prefix;
//@property (nonatomic, copy  ) NSString *suffix;
//@property (nonatomic, copy  ) NSString *nickName;
//@property (nonatomic, copy  ) NSString *firstNamePhonetic;//firstName拼音音标
//@property (nonatomic, copy  ) NSString *lastNamePhonetic;//
//@property (nonatomic, copy  ) NSString *midNamePhonetic;//
//@property (nonatomic, copy  ) NSString *organiztion;//公司
//@property (nonatomic, copy  ) NSString *jobTitle;//工作
//@property (nonatomic, copy  ) NSString *department;//部门
//@property (nonatomic, copy  ) NSString *birthday;//生日
//@property (nonatomic, copy  ) NSString *note;//备忘
//@property (nonatomic, copy  ) NSString *creationDate;//第一次添加该记录的时间
//@property (nonatomic, copy  ) NSString *modificationDate;//最后一次修改改天记录的时间
//@property (nonatomic, strong) NSMutableArray  *emailCount;//email
//@property (nonatomic, strong) NSMutableArray  *address;//地址
//@property (nonatomic, strong) NSMutableArray  *dates;//dates多值
//@property (nonatomic, copy  ) NSString *kind;//kind多值
//@property (nonatomic, strong) NSMutableArray  *instantMessage;//IM
//
//@property (nonatomic, strong) NSMutableArray  *url;//URL多值
//@property (nonatomic, strong) NSData   *headImage;//照片
@end
