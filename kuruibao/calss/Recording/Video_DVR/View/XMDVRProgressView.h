//
//  XMDVRProgressView.h
//  GKDVR
//
//  Created by x on 16/10/28.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^cancleBlock)();

@interface XMDVRProgressView : UIView

@property (assign, nonatomic) float progress;

@property (copy, nonatomic) cancleBlock cancelBlock;

- (instancetype)initWithSuperView:(UIView *)view cancelHandler:(cancleBlock)cancelBlock;

@end
