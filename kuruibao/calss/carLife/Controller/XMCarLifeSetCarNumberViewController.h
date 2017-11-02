//
//  XMCarLifeSetCarNumberViewController.h
//  kuruibao
//
//  Created by x on 17/5/10.
//  Copyright © 2017年 ChexXiaoMi. All rights reserved.
//

#import "XMSetCarNumberViewController.h"

@protocol XMSetCarNumberViewControllerDelegate <NSObject>

- (void)setCarNumberVCDidFinish:(NSString *)carNumber;

@end

@interface XMCarLifeSetCarNumberViewController : XMSetCarNumberViewController

@property (weak, nonatomic) id<XMSetCarNumberViewControllerDelegate> delegate;

@end
