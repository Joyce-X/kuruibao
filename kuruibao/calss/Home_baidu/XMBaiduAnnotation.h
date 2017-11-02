//
//  XMBaiduAnnotation.h
//  kuruibao
//
//  Created by x on 17/6/19.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import<BaiduMapAPI_Map/BMKMapComponent.h>

@interface XMBaiduAnnotation : BMKPointAnnotation

@property (copy, nonatomic) NSString *deadLine;//!< 最后定位时间

@property (assign, nonatomic) NSUInteger brindId;//!< 品牌id

@property (copy, nonatomic) NSString *carNumber;//!< 车牌号码

@property (nonatomic,copy)NSString* showName;//-- 显示在线不在线  或者显示行驶中/停驶/失联状态
@end
