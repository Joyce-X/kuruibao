//
//  ZxcRtsp.m
//  RTSPA
//
//  Created by 黎峰麟 on 16/6/14.
//  Copyright © 2016年 黎峰麟. All rights reserved.
//

#import "ZxcRtspA.h"
#import "RTSPPlayer.h"
#import "NetTool.h"
@interface ZxcRtspA(){
    
    NSTimer *_nextFrameTimer;
    NSThread *_rtsp_Therad;
    NSInteger _reConnectCount;
    
    long long _lastStarTime;
}

@property (nonatomic, strong) RTSPPlayer *rTSPPlayervideo;

@end

@implementation ZxcRtspA

static ZxcRtspA *_instance;

+ (ZxcRtspA *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)appWillEnterForeground:(NSNotification *)note {
    // [self continueFrame];
}

- (void)appWillEnterBackground:(NSNotification *)note {
    
    //_currentImage = nil;
    //[self pauseFrame];
    
}

- (void)continueFrame {
    
    if (_rTSPPlayervideo) {
        //        [_rTSPPlayervideo seekTime:1000];
        
        _rtsp_Therad.name = @"YES";
        [self stopNextFrameTimer];
        
        NetToolManager.isBeginB =YES;
        _nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/15.0f
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil repeats:YES];
        [_nextFrameTimer fire];
    }
}


- (void)pauseFrame {
    
    _isPlaying = NO;
    [self stopNextFrameTimer];
    //    _rtsp_Therad.name = @"NO";
    
}

#pragma mark - @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
- (void)displayNextFrame:(NSTimer *)timer {
    
    UIImage *image = _rTSPPlayervideo.lastImage;
    
    if (image == nil) return;
    
    _currentImage = image;
    _isPlaying = YES;
    
    if ([_delegate respondsToSelector:@selector(zxcRtspACurrentImage:)]) {
        [_delegate zxcRtspACurrentImage:image];
    }
}

- (void)starRtsp {
    
    //    @synchronized (_rTSPPlayervideo) {
    NSString *movePath = @"rtsp://192.168.63.9/live/udp/ch3_0";
    int timeInt = (CFAbsoluteTimeGetCurrent() - _lastStarTime);
    if (timeInt > 3) {
        _lastStarTime = CFAbsoluteTimeGetCurrent();
    }else{
        return;
    }
    if (_isPlaying == YES)return;
    
    //    [self stopRtsp];
    //    if(_rTSPPlayervideo) [_rTSPPlayervideo playerFree];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _rTSPPlayervideo = [[RTSPPlayer alloc] initWithVideo:movePath];
        if (_rTSPPlayervideo) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                _reConnectCount = 0;
                
                [NetTool sharedInstance] .isBeginB = YES;
                
                [self stopNextFrameTimer];
                _nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/15.0f
                                                                   target:self
                                                                 selector:@selector(displayNextFrame:)
                                                                 userInfo:nil repeats:YES];
                [_nextFrameTimer fire];
                
                _rtsp_Therad = [[NSThread alloc] initWithTarget:self selector:@selector(displayNext) object:nil];
                _rtsp_Therad.name = @"YES";
                [_rtsp_Therad start];
            });
        } else {
            [self stopRtsp];
            _reConnectCount++;
            if (_reConnectCount < 5) {
                [self delayReconnectRTSP:2.0f];
            } else {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    _isPlaying = NO;
                    if ([_delegate respondsToSelector:@selector(zxcRtspADisplayFailure:)]) {
                        
                        [NetTool sharedInstance] .isBeginB = NO;
                        [_delegate zxcRtspADisplayFailure:NO];
                    }
                    
                });
                
                _reConnectCount = 0;
                [self delayReconnectRTSP:2.0];
            }
        }
    });
}

//}

- (void)displayNext {
    while (![[NSThread currentThread] isCancelled]) {
        
        //        @synchronized (_rtsp_Therad) {
        
        if ([_rtsp_Therad.name isEqualToString:@"YES"]) {
            
            [NSThread sleepForTimeInterval:0.01];
            if (![_rTSPPlayervideo stepFrame]) {
                
                [self stopRtsp];
                _isPlaying = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //                    [self reconnectRTSP];
                });
                [self delayReconnectRTSP:2.0];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    if ([_delegate respondsToSelector:@selector(zxcRtspADisplayFailure:)]) {
                        [_delegate zxcRtspADisplayFailure:YES];
                    }
                });
            }
        }
        //      }
    }
}

- (void)reconnectRTSP {
    [self stopRtsp];
    [self starRtsp];
}

- (void)stopRtsp {
    [self stopNextFrameTimer];
    
    _rtsp_Therad.name = @"NO";
    [_rtsp_Therad cancel];
    _rtsp_Therad = nil;
    
    //    [_rTSPPlayervideo playerFree];
    //    _rTSPPlayervideo = nil;
    [NetTool sharedInstance] .isBeginB = NO;
    _isPlaying = NO;
}

- (void)stopNextFrameTimer {
    if (_nextFrameTimer) {
        [_nextFrameTimer invalidate];
        _nextFrameTimer = nil;
    }
}

- (void)delayReconnectRTSP:(CGFloat)time {
    //    if (NetToolManager.isRtspBViewController == YES) {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(starRtsp) object:nil];
    [self performSelector:@selector(starRtsp) withObject:nil afterDelay:time];
    //    }
    
}

- (void)cancelDelayReconnectRTSP {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(starRtsp) object:nil];
}

@end
