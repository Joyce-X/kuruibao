//
//  XMDVR_DisplayImageCell.m
//  kuruibao
//
//  Created by x on 16/11/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//


/**********************************************************
 
 class description:
 
        点击预览本地图片的时候 自定义的collectionView  cell
 
 **********************************************************/


#import "XMDVR_DisplayImageCell.h"

#define directoryPath_IMAGE [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/DVR/PIC"]

@interface XMDVR_DisplayImageCell()

@property (nonatomic,weak)UIImageView* imageView;

@end

@implementation XMDVR_DisplayImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        
        imageView.backgroundColor = [UIColor blackColor];
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:imageView];
        
        self.imageView = imageView;
        
    }
    
    return self;
}

- (void)setName:(NSString *)name
{
    _name = name;
    
    NSString *imagePath = [directoryPath_IMAGE stringByAppendingPathComponent:name];
    
    self.imageView.image = [UIImage imageWithContentsOfFile:imagePath];



}

@end
