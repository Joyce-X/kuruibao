
//
//  ZxcRtsp.h
//  RTSPA
//
//  Created by 黎峰麟 on 16/6/14.
//  Copyright © 2016年 黎峰麟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RTSPPlayer.h"



@protocol ZxcRtspBDelegate <NSObject>

- (void)zxcRtspBCurrentImage:(UIImage *)image;
- (void)zxcRtspBDisplayFailure:(BOOL)isFifth;
- (void)zxcRtspBFailedToOpenStream;

@end


@interface ZxcRtspB : NSObject


+ (ZxcRtspB *)shared;


@property (nonatomic, weak) id <ZxcRtspBDelegate> delegate;

@property (nonatomic,strong,readonly) UIImage *currentImage;
@property (nonatomic,assign,readonly) BOOL isPlaying;
@property (nonatomic, strong) RTSPPlayer *rTSPPlayervideo;

- (void)delayReconnectRTSP:(CGFloat)time;

- (void)starRtsp;
- (void)pauseFrame;
- (void)continueFrame;
- (void)stopRtsp;
- (void)cancelDelayReconnectRTSP;

//@"rtsp://192.168.63.9/live/udp/ch1_0";

@end
