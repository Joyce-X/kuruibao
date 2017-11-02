//
//  MyDemoModel.h
//  MyDemo
//
//  Created by 智恒创 on 16/5/31.
//  Copyright © 2016年 zxc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyDemoModel : NSObject

@end



@interface VideoModel : NSObject

@property (nonatomic, strong) NSString *videoid;
@property (nonatomic, strong) NSString *videotitle;
@property (nonatomic, strong) NSString *videoname;
@property (nonatomic, strong) NSString *videostatus;
@property (nonatomic, strong) NSString *videoduration;


@end


@interface ImageModel : NSObject

@property (nonatomic, strong) NSString *imageid;
@property (nonatomic, strong) NSString *imagetitle;
@property (nonatomic, strong) NSString *imagename;
@property (nonatomic, strong) NSString *imagestatus;
@end



@interface RecordModel : NSObject

@property (nonatomic, strong) NSString *BCR;
@property (nonatomic, strong) NSString *Bitrate;
@property (nonatomic, strong) NSString *Frames;
@property (nonatomic, strong) NSString *Profile;
@property (nonatomic, strong) NSString *Quality;
@property (nonatomic, strong) NSString *Rectime;
@property (nonatomic, strong) NSString *Resolution;

@end


@interface SetModel : NSObject

@property (nonatomic, strong) NSString *Brightness;
@property (nonatomic, strong) NSString *Contrast;
@property (nonatomic, strong) NSString *Hue;
@property (nonatomic, strong) NSString *Saturation;
@property (nonatomic, strong) NSString *Sharpness;
@property (nonatomic, strong) NSString *Image_mirror;

@end