//
//  XMCarLife_chooseCityView.h
//  kuruibao
//
//  Created by x on 17/5/12.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMCarLife_limit_cityModel.h"
@class XMCarLife_chooseCityView;
@protocol XMCarLife_chooseCityViewDelegate <NSObject>

/**
 * @brief click refresh button,to refresh the user location
 */
-(void)XMCarLife_chooseCityViewRefreshLocationDidClick:(XMCarLife_chooseCityView*)chooseView;


/**
 * @brief did choose city
 */
-(void)XMCarLife_chooseCityViewDidSelectedCity:(XMCarLife_limit_cityModel *)cityModel;



@end

@interface XMCarLife_chooseCityView : UIView

@property (weak, nonatomic,readonly) UILabel *cityLabel;//!< show location city

@property (strong, nonatomic) NSArray *citys;//!< city array

@property (weak, nonatomic) id<XMCarLife_chooseCityViewDelegate> delegate;

//!< set location city
- (void)setLocationCity:(NSString *)city;




@end
