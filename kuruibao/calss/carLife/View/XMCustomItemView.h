//
//  XMCustomItemView.h
//  kuruibao
//
//  Created by x on 17/4/18.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 
 custom View show the  item of FM module
 
 ************************************************************************************************/

#import <UIKit/UIKit.h>

@class XMCustomItemView;

typedef void(^triggerBlock)(XMCustomItemView *view);

@interface XMCustomItemView : UIView

@property (copy, nonatomic) NSString *title;

@property (weak, nonatomic) UIImageView *imageView;//!< show coverImage

@property (copy, nonatomic) triggerBlock completion;


@end
