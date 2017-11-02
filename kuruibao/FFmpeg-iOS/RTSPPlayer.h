#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RTSPPlayerDelegate;

@interface RTSPPlayer : NSObject

@property (nonatomic, readonly) UIImage *lastImage;
@property (nonatomic, assign) int outputWidth, outputHeight;
@property (nonatomic, assign) id <RTSPPlayerDelegate> delegate;

- (id)initWithVideo:(NSString *)moviePath;
- (BOOL)stepFrame;
- (void)seekTime:(double)seconds;
- (void)playerFree;

@end

@protocol RTSPPlayerDelegate <NSObject>

- (void)RTSPPlayerPlayStatus:(BOOL)isSuccess;

@end
