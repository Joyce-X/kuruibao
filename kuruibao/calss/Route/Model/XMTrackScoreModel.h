//
//  XMTrackScoreModel.h
//  kuruibao
//
//  Created by x on 16/12/5.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMTrackScoreModel : NSObject

@property (copy, nonatomic) NSString *qicheid;//!< 汽车编号


//!< 总油耗
@property (copy, nonatomic) NSString *penyou;//!< 统计总油耗

@property (copy, nonatomic) NSString *penyouno;//!< 统计油耗总排名

@property (copy, nonatomic) NSString *penyouscore;//!< 总油耗排名


//!< 急刹车
@property (copy, nonatomic) NSString *jishache;//!< 急刹车总次数

@property (copy, nonatomic) NSString *jishache100;//!< 百公里急刹车次数

@property (copy, nonatomic) NSString *jishacheno;//!< 急刹车排名

@property (copy, nonatomic) NSString *jishachescore;//!< 急刹车得分


//!< 急加油
@property (copy, nonatomic) NSString *jijiayou;//!< 急加油总次数

@property (copy, nonatomic) NSString *jijiayou100;//!< 百公里急加油次数

@property (copy, nonatomic) NSString *jijiayouno;//!< 百公里急加油排名

@property (copy, nonatomic) NSString *jijiayouscore;//!< 急加油得分


//!< 频繁变道

@property (copy, nonatomic) NSString *pinfanbiandao;//!< 频繁变道总次数

@property (copy, nonatomic) NSString *pinfanbiandao100;//!< 百公里频繁变道次数

@property (copy, nonatomic) NSString *pinfanbiandaono;//!< 频繁变道排名

@property (copy, nonatomic) NSString *pinfanbiandaoscore;//!< 频繁变道得分


//!< 弯道加速
@property (copy, nonatomic) NSString *wandaojiasu;//!< 弯道加速总次数

@property (copy, nonatomic) NSString *wandaojiasu100;//!< 百公里弯道加速次数

@property (copy, nonatomic) NSString *wandaojiasuno;//!< 弯道加速排名

@property (copy, nonatomic) NSString *wandaojiasuscore;//!< 弯道加速得分
//---


//!< 平均油耗
@property (copy, nonatomic) NSString *youhao100;//!< 百公里油耗

@property (copy, nonatomic) NSString *youhao100no;//!< 百公里油耗排名

@property (copy, nonatomic) NSString *youhao100score;//!< 百公里油耗得分


//!< 怠速
@property (copy, nonatomic) NSString *daisutime;//!< 总怠速时长

@property (copy, nonatomic) NSString *daisu100;//!< 百公里怠速时长

@property (copy, nonatomic) NSString *daisuno;//!< 怠速排名

@property (copy, nonatomic) NSString *daisuscore;//!<怠速得分



//!< 急转弯
@property (copy, nonatomic) NSString *jizhuanwan;//!< 急转弯次数

@property (copy, nonatomic) NSString *jizhuanwan100;//!< 百公里急转弯次数

@property (copy, nonatomic) NSString *jizhuanwanno;//!< 百公里急转弯排名

@property (copy, nonatomic) NSString *jizhuanscore;//!< 急转弯得分

@property (copy, nonatomic) NSString *anquanscore;//!< 安全得分

@property (copy, nonatomic) NSString *speedscore;//!<速度得分

@property (copy, nonatomic) NSString *huanbaoscore;//!< 环保得分

@property (copy, nonatomic) NSString *ditanscore;//!< 低碳生活得分

@property (copy, nonatomic) NSString *xiguanscore;//!< 习惯得分


- (instancetype)initWithDic:(NSDictionary *)dic;

















@end
