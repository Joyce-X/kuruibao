//
//  XMSettingCell.h
//  kuruibao
//
//  Created by x on 16/8/3.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMSettingCellModel.h"
@interface XMSettingCell : UITableViewCell

/**
 *  imageName
 */
@property (nonatomic,copy)NSString* iamgeName;

/**
 *  text
 */
@property (nonatomic,copy)NSString* text;

/**
 *  moreImageName
 */
@property (nonatomic,copy)NSString* moreImageName;


@property (nonatomic,strong)XMSettingCellModel* cellModel;

+ (instancetype)dequeueReusableCellWithTableview:(UITableView *)tableview;

@end
