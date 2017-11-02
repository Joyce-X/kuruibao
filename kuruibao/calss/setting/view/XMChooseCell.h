//
//  XMChooseCell.h
//  kuruibao
//
//  Created by x on 16/8/30.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMChooseCell : UITableViewCell

/**
 *  展示品牌
 */
@property (nonatomic,weak)UILabel* brand;
/**
 *  展示品牌对应的图标
 */
@property (nonatomic,weak)UIImageView* picture;

+ (instancetype)dequeueResuableCellWithTableView:(UITableView *)tableView;

@end
