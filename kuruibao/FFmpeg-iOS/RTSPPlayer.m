#import "RTSPPlayer.h"
#include <libavutil/imgutils.h>
#import "libavformat/avformat.h"
#import "avcodec.h"
#import "avio.h"
#import "swscale.h"
#import "libavutil/opt.h"
#import "libavutil/time.h"
#import "libm.h"
#import "ffmpeg.h"
#import "cmdutils.h"

static const HWAccel *get_hwaccel(enum AVPixelFormat pix_fmt)
{
    int i;
    for (i = 0; hwaccels[i].name; i++) {
        if (hwaccels[i].pix_fmt == pix_fmt) {
            return &hwaccels[i];
        }
    }
    
    return NULL;
}

static enum AVPixelFormat get_format(AVCodecContext *s, const enum AVPixelFormat *pix_fmts)
{
    InputStream *ist = s->opaque;
    const HWAccel *hwaccel;
    hwaccel = get_hwaccel(AV_PIX_FMT_VIDEOTOOLBOX);
    hwaccel->init(s);
    ist->active_hwaccel_id = hwaccel->id;
    ist->hwaccel_pix_fmt   = AV_PIX_FMT_VIDEOTOOLBOX;
    
    return AV_PIX_FMT_VIDEOTOOLBOX;
}

static int get_buffer(AVCodecContext *s, AVFrame *frame, int flags)
{
    return avcodec_default_get_buffer2(s, frame, flags);
}

@interface RTSPPlayer ()
{
    AVFormatContext *pFormatCtx;
    AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    AVPacket packet;
    AVPicture picture;
    int videoStream;
    struct SwsContext *img_convert_ctx;
    InputStream *ist;

    uint8_t *dst_data[4];
    int dst_linesize[4];
    NSMutableArray *_imageArray;
    BOOL _isFirstDecodingBEerror;
}

@property (nonatomic, strong) NSData *rgb;
@property (nonatomic, assign) NSInteger lastPts;
@property (nonatomic, assign) BOOL isHWAccel;

@end

@implementation RTSPPlayer

- (void)free
{    
    videoStream = -1;
    
    if (img_convert_ctx) {
        sws_freeContext(img_convert_ctx);
        img_convert_ctx = NULL;
    }
    
    av_packet_unref(&packet);
    av_freep(&dst_data[0]);

    if (pFrame) {
        av_free(pFrame);
        pFrame = NULL;
    }
    
    if (pCodecCtx) {
        if (_isHWAccel) {
            ist->hwaccel_uninit(ist->dec_ctx);
        }
        if (pCodecCtx) {
            avcodec_close(pCodecCtx);
        }
        pCodecCtx = NULL;
        if (_isHWAccel) {
            av_freep(&ist);
            ist = NULL;
        }
    }
    
    if (pFormatCtx)  {
       avformat_close_input(&pFormatCtx);
    }
}

- (void)setOutputWidth:(int)newValue
{
    _outputWidth = newValue;
    [self setupScaler];
}

- (void)setOutputHeight:(int)newValue
{
    _outputHeight = newValue;
    [self setupScaler];
}

- (BOOL)swsScale
{
    if (_isHWAccel) {
        if (!pFrame->data[3]) {
            return NO;
        }
    } else {
        if (!pFrame ||!pFrame->data[0]) {
            return NO;
        }
    }
    
    if (img_convert_ctx)
    {
        if (_isHWAccel) {
            ist->hwaccel_retrieve_data(ist->dec_ctx, pFrame);
        }
        
        sws_scale(img_convert_ctx, pFrame->data, pFrame->linesize, 0,
                  pCodecCtx->height, dst_data, dst_linesize);
        
        return YES;
    }
    
    return NO;
}

- (double)duration
{
	return (double)pFormatCtx->duration / AV_TIME_BASE;
}

- (double)currentTime
{
    AVRational timeBase = pFormatCtx->streams[videoStream]->time_base;
    return packet.pts * (double)timeBase.num / timeBase.den;
}

- (int)sourceWidth
{
	return pCodecCtx->width;
}

- (int)sourceHeight
{
	return pCodecCtx->height;
}

- (id)initWithVideo:(NSString *)moviePath
{
	if (!(self=[super init])) return nil;
 
    AVCodec *pCodec;
		
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
        
    AVDictionary *opts = NULL;
    av_dict_set(&opts, "rtsp_transport", "udp", 0);
    // av_dict_set(&opts, "probesize", "2048", 0);
    // av_dict_set(&opts, "max_analyze_duration", "1000", 0);
    av_dict_set(&opts, "max_delay", "0.3", 0);
    
    if (avformat_open_input(&pFormatCtx, [moviePath UTF8String], NULL, &opts) !=0 ) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't open file\n");
        if (pFormatCtx) {
            avformat_free_context(pFormatCtx);
        }
        
        return nil;
    }
    
    if (avformat_find_stream_info(pFormatCtx, NULL) < 0) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't find stream information\n");
        
        avformat_close_input(&pFormatCtx);

        return nil;
    }
    
    av_dump_format(pFormatCtx, 0, [moviePath UTF8String], false);
    
    videoStream=-1;

    for (int i = 0; i < pFormatCtx->nb_streams; i++) {
        if (pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
            NSLog(@"found video stream");
            videoStream = i;
        }
    }
    
    if (videoStream == -1) {
        return nil;
    }

    pCodecCtx = pFormatCtx->streams[videoStream]->codec;
    
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if (pCodec == NULL) {
        av_log(NULL, AV_LOG_ERROR, "Unsupported codec!\n");
        return nil;
    }
    
    _isHWAccel = NO;
    
    if (_isHWAccel) {
        ist = av_mallocz(sizeof(*ist));
        ist->st = pFormatCtx->streams[videoStream];
        ist->dec = pCodec;
        ist->dec_ctx = avcodec_alloc_context3(pCodec);
        
        avcodec_copy_context(ist->dec_ctx, pCodecCtx);
        ist->dec_ctx->opaque = ist;
        ist->hwaccel_id = HWACCEL_VIDEOTOOLBOX;
        ist->hwaccel_pix_fmt = AV_PIX_FMT_NONE;
        ist->dec_ctx->get_format = get_format;
        ist->dec_ctx->get_buffer2 = get_buffer;
        pCodecCtx = ist->dec_ctx;
    }
	
    if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
        av_log(NULL, AV_LOG_ERROR, "Cannot open video decoder\n");
        return nil;
    }
    
    pFrame = av_frame_alloc();
    
    if (!pFrame) {
        avcodec_close(pCodecCtx);
        return nil;
    }
			
	_outputWidth = pCodecCtx->width;
	self.outputHeight = pCodecCtx->height;

    _imageArray = [[NSMutableArray alloc] init];
			
	return self;
}

- (id)loadFail
{
    return nil;
}

- (void)setupScaler
{
    av_freep(&dst_data[0]);
	sws_freeContext(img_convert_ctx);
	
	// avpicture_alloc(&picture, AV_PIX_FMT_RGB24, _outputWidth, _outputHeight);
	
    av_image_alloc(dst_data, dst_linesize,
                   _outputWidth, _outputHeight, AV_PIX_FMT_RGB24, 1);
    
	static int sws_flags =  SWS_FAST_BILINEAR;
	img_convert_ctx = sws_getContext(pCodecCtx->width, 
									 pCodecCtx->height,
									 _isHWAccel ? AV_PIX_FMT_NV12 : pCodecCtx->pix_fmt,
									 _outputWidth, 
									 _outputHeight,
									 AV_PIX_FMT_RGB24,
									 sws_flags, NULL, NULL, NULL);
	
}

- (void)seekTime:(double)seconds
{
	AVRational timeBase = pFormatCtx->streams[videoStream]->time_base;
	int64_t targetFrame = (int64_t)((double)timeBase.den / timeBase.num * seconds);
	avformat_seek_file(pFormatCtx, videoStream, targetFrame, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
	avcodec_flush_buffers(pCodecCtx);
}

- (void)dealloc
{
    [self free];
}

- (BOOL)stepFrame
{
    int frameFinished = 0;
    
    while (!frameFinished && pFormatCtx) {
        if (av_read_frame(pFormatCtx, &packet) >= 0) {
            if(packet.stream_index==videoStream) {
                int len = avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
                /* NSLog(@"packet->pts = %lld %lld %lu %d", packet.pts, (packet.pts - _lastPts),
                      (unsigned long)_imageArray.count, avcodec_get_notfullframe()); */
                _lastPts = packet.pts;
                
                int flag = avcodec_get_notfullframe();
                if (flag) {
                    // NSLog(@"stepFrame--pFrame->pict_type = %d-avcodec_get_notfullframe = %d",pFrame->pict_type, flag);
                    avcodec_reset_notfullframe(0);
                    
                    /*
                    if (pFrame->pict_type == AV_PICTURE_TYPE_I) {
                    // 解码出错了如果是B帧就记录下来   因为每次循环解码都会用到B
                        _isFirstDecodingBEerror = YES;
                    } */
                    
                    // _isFirstDecodingBEerror = YES;
                    // break;
                }
                
                if (len < 0) {
                    break;
                }
                /*
                if (_isFirstDecodingBEerror && pFrame->pict_type == AV_PICTURE_TYPE_I) {
                    _isFirstDecodingBEerror = NO;
                }
                
                if (frameFinished && _isFirstDecodingBEerror == NO) {
                    [self addImageToArray];
                } */
                
                [self addImageToArray];

            }
            av_packet_unref(&packet);
        } else {
            if ([_delegate respondsToSelector:@selector(RTSPPlayerPlayStatus:)]) {
                [_delegate RTSPPlayerPlayStatus:NO];
            }
            break;
        }
        
        av_packet_unref(&packet);
    }
    
    return frameFinished != 0;
}

- (void)addImageToArray
{
    @synchronized(_imageArray) {
        BOOL ret = [self swsScale];
        if (ret) {
            /*
            NSData *data = [[NSData alloc] initWithBytesNoCopy:dst_data[0]
                                            length:_outputWidth * _outputHeight * 3]; */
            NSData *data = [[NSData alloc] initWithBytesNoCopy:dst_data[0] length:_outputWidth * _outputHeight * 3 deallocator:^(void * _Nonnull bytes, NSUInteger length) {
            }];
            [_imageArray addObject:data];
            
            // NSLog(@"_imageArray.count = %lu", (unsigned long)_imageArray.count);
            if (_imageArray.count > 100) {
                // [_imageArray removeObjectsInRange:NSMakeRange(0, _imageArray.count - 8)];
                [self freeImageArray];
            }
        }
    }
}

- (UIImage *)asImage
{
    UIImage *image = nil;

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(_rgb));
    if (provider) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace) {
            CGImageRef imageRef = CGImageCreate(_outputWidth,
                                                _outputHeight,
                                                8,
                                                24,
                                                dst_linesize[0],
                                                colorSpace,
                                                kCGBitmapByteOrderDefault,
                                                provider,
                                                NULL,
                                                YES, // NO
                                                kCGRenderingIntentDefault);
            
            if (imageRef) {
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
            CGColorSpaceRelease(colorSpace);
        }
        CGDataProviderRelease(provider);
    }
	
	return image;
}

- (UIImage *)lastImage
{
    @synchronized(_imageArray) {
        
        if (_imageArray.count > 0) {
            _rgb = _imageArray[0];
            [_imageArray removeObjectAtIndex:0];
        }
    }
    
    return [self asImage];
}

- (void)freeImageArray
{
    @synchronized(_imageArray) {
        [_imageArray removeAllObjects];
    }
}

@end
