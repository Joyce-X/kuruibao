//
//  ZxcRtspA.h
//  RTSPA
//
//  Created by 黎峰麟 on 16/6/23.
//  Copyright © 2016年 黎峰麟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ZxcRtspADelegate <NSObject>

- (void)zxcRtspACurrentImage:(UIImage *)image;
- (void)zxcRtspADisplayFailure:(BOOL)isFifth;;     //读不到下一帧和重连五次失败会调用
- (void)zxcRtspAFailedToOpenStream; //打开流失败

@end


@interface ZxcRtspA : NSObject

+ (ZxcRtspA *)shared;

@property (nonatomic, weak) id <ZxcRtspADelegate> delegate;
@property (nonatomic,strong,readonly) UIImage *currentImage;
@property (nonatomic,assign,readonly) BOOL isPlaying;

- (void)delayReconnectRTSP:(CGFloat)time;
- (void)starRtsp;
- (void)pauseFrame;
- (void)continueFrame;
- (void)stopRtsp;
- (void)cancelDelayReconnectRTSP;

//@"rtsp://192.168.63.9/live/udp/ch3_0";

@end