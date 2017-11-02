//
//  XMCarInfoViewController.m
//  kuruibao
//
//  Created by x on 16/8/4.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//

/***********************************************************************************************
 展示车辆信息相关的界面
 
 
 ************************************************************************************************/
#import "XMQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XMQRCodeWriteInfoViewController.h"


@interface XMQRCodeViewController()<AVCaptureMetadataOutputObjectsDelegate,CALayerDelegate>
/**
 * 扫描区域
 */
@property (weak, nonatomic)  UIView *scanView;

/**
 *  扫描结果
 */
@property (weak, nonatomic)  UILabel *resultLabel;

/**
 * 抽象的硬件设备
 */
@property (nonatomic,strong)AVCaptureDevice* device;

/**
 *  输入源
 */
@property (nonatomic,strong)AVCaptureDeviceInput* input;


/**
 *  输出源
 */
@property (nonatomic,strong)AVCaptureMetadataOutput* output;

/**
 *  图层类，快速显示摄像头捕获的信息
 */
@property (nonatomic,strong)AVCaptureVideoPreviewLayer* preview;

/**
 *  视频会话
 */
@property (nonatomic,strong)AVCaptureSession* session;

@property (nonatomic,weak)CALayer* blackLayer;


@property (nonatomic,weak)UIButton* writeBtn;
@property (nonatomic,weak)UIView * line;

@property (nonatomic,weak)UIView* backView;

@end

@implementation XMQRCodeViewController

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    
    [self setupSubViews];
    
    
    
    
}




- (void)setupSubViews
{
    
    self.message = @"添加设备";
    
    //!< 手动填写按钮
 
    UIButton *writeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [writeBtn setBackgroundImage:[UIImage imageNamed:@"setCar_add"] forState:UIControlStateNormal];
    [writeBtn setBackgroundImage:[UIImage imageNamed:@"setCar_add_highlighted"] forState:UIControlStateHighlighted];
    CGFloat btn_w = 55;
    CGFloat btn_h = btn_w;
    CGFloat btn_x = mainSize.width - btn_w - 15;
    CGFloat btn_y = backImageH - btn_h * 0.5;
    writeBtn.frame = CGRectMake(btn_x, btn_y, btn_w, btn_h);
    [writeBtn addTarget:self action:@selector(writeBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:writeBtn];
    self.writeBtn = writeBtn;
    

    //!< 背景
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH)];
    [self.view addSubview:backView];
    self.backView = backView;

    //!< 扫描区域
    UIView *scanView = [[UIView alloc]init];
    [backView addSubview:scanView];
    self.scanView = scanView;
    CGFloat sacnView_w = mainSize.width - FITWIDTH(115);
    [scanView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backView).offset(FITWIDTH(57.5));
        make.width.equalTo(sacnView_w);
        make.height.equalTo(sacnView_w);
        make.bottom.equalTo(backView).offset(-FITHEIGHT(136));
        
        
    }];
    
    //!< 扫描边角图片
    UIImageView *leftTopImageView = [UIImageView new];
    leftTopImageView.image = [UIImage imageNamed:@"ScanQR1"];
    [scanView addSubview:leftTopImageView];
    [leftTopImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(scanView);
        make.top.equalTo(scanView);
        make.size.equalTo(CGSizeMake(32, 32));
    }];
    
    UIImageView *rightTopImageView = [UIImageView new];
    rightTopImageView.image = [UIImage imageNamed:@"ScanQR2"];
    [scanView addSubview:rightTopImageView];
    [rightTopImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(scanView);
        make.top.equalTo(scanView);
        make.size.equalTo(CGSizeMake(32, 32));
    }];
    
    UIImageView *leftBottomImageView = [UIImageView new];
    leftBottomImageView.image = [UIImage imageNamed:@"ScanQR3"];
    [scanView addSubview:leftBottomImageView];
    [leftBottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(scanView);
        make.bottom.equalTo(scanView);
        make.size.equalTo(CGSizeMake(32, 32));
    }];
    
    UIImageView *rigthBottomImageView = [UIImageView new];
    rigthBottomImageView.image = [UIImage imageNamed:@"ScanQR4"];
    [scanView addSubview:rigthBottomImageView];
    [rigthBottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(scanView);
        make.bottom.equalTo(scanView);
        make.size.equalTo(CGSizeMake(32, 32));
    }];
    
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor redColor];
    [scanView addSubview:line];
    self.line = line;
   
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(2);
        make.top.equalTo(scanView).offset(3);
        make.left.equalTo(scanView).offset(4);
        make.right.equalTo(scanView).offset(-4);
        
    }];
    
    
    
    /*
     //->>动画方式一：核心动画之基础动画
     CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
     anima.duration = 2;
     anima.toValue = @(self.showView.frame.size.height);
     anima.removedOnCompletion = NO;
     anima.fillMode = kCAFillModeForwards;
     anima.repeatCount = INT_MAX;
     [line.layer addAnimation:anima forKey:@"line"];
     */
    
    //->>动画方式二 UIView动画
    [UIView animateWithDuration:1.5f delay:0.0f options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        
        line.transform = CGAffineTransformTranslate(line.transform, 0, sacnView_w - 9);
        
    } completion:nil];
    
    
    //!< 提示lable
    UILabel *prompMessage = [UILabel new];
    prompMessage.text = NSLocalizedString(@"请将产品串码放入扫描区域", nil);
    prompMessage.textAlignment = NSTextAlignmentCenter;
    prompMessage.textColor = [UIColor whiteColor];
    prompMessage.font = [UIFont systemFontOfSize:12];
    [backView addSubview:prompMessage];
    [prompMessage mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(backView);
        make.height.equalTo(20);
        make.top.equalTo(scanView.mas_bottom).offset(17);
        make.width.equalTo(backView);
        
    }];
    
    
    self.session = [[AVCaptureSession alloc]init];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    //->>设置为高质量采集
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    //->>设置扫码类型
    [_output setMetadataObjectTypes:_output.availableMetadataObjectTypes];
    [self setOutputInterest]; //->>设置扫码范围
    
    
    //->>实时获取摄像头原始数据显示在屏幕上
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = backView.frame;
    [self.view.layer insertSublayer:_preview atIndex:0];
    //    self.view.layer.backgroundColor = [UIColor blackColor].CGColor;
//    self.title = @"设备连接";
    
    
    //->>设置外围黑色蒙版
    CALayer *blackLayer = [CALayer layer];
    blackLayer.delegate = self;
    blackLayer.frame = backView.frame;
    [self.view.layer insertSublayer:blackLayer above:_preview];
    self.blackLayer = blackLayer;
    [blackLayer setNeedsDisplay];

    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self.session startRunning];
    [self.view bringSubviewToFront:_writeBtn];
    
    MobClickBegain(@"扫描二维码页面");
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    MobClickEnd(@"扫描二维码界面");

}

- (void)writeBtnDidClick
{
    //!< 点击手动填写按钮，跳转到手动填写界面
    [self.navigationController popViewControllerAnimated:NO];
    if (self.writeImeiBlack)
    {
        self.writeImeiBlack();
    }
    
    
}




/**
 *  设置扫码范围
 */
- (void)setOutputInterest
{
    
    /*
     关于扫描范围，这是一个坑，稍稍不注意，就会踩进去了。扫描的范围是通过这个参数rectOfInterest来设置的，但这个参数不是普通的CGRect，而是0~1的一个范围比例。正确的创建为CGRectMake(y/Height,x/Width,height/Height,width/Width)，这里左边是扫描区域的x，y，width，height，右边的是当前控制器view的Width和Height
     */
    CGSize size = self.backView.bounds.size;
    
    CGFloat scanViewWidth = mainSize.width - FITWIDTH(115);
    CGFloat scanViewHeight = mainSize.width - FITWIDTH(115);
    CGFloat scanViewX = (size.width - scanViewWidth) / 2;
    CGFloat scanViewY = mainSize.height - backImageH - scanViewHeight - FITHEIGHT(136);   //(size.height - scanViewHeight) / 2;
    CGFloat p1 = size.height / size.width;
    CGFloat p2 = 1920. / 1080.;
    if (p1 < p2) {
        CGFloat fixHeight = self.backView.bounds.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        _output.rectOfInterest = CGRectMake((scanViewY + fixPadding) / fixHeight,
                                            scanViewX / size.width,
                                            scanViewHeight / fixHeight,
                                            scanViewWidth / size.width);
    } else {
        CGFloat fixWidth = self.backView.bounds.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        _output.rectOfInterest = CGRectMake(scanViewY / size.height,
                                            (scanViewX + fixPadding) / fixWidth,
                                            scanViewHeight / size.height,
                                            scanViewWidth / fixWidth);
    }
}



#pragma mark ---lazy
- (AVCaptureDevice *)device
{
    if (!_device)
    {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;

}


- (AVCaptureDeviceInput *)input
{
    if (!_input)
    {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;


}


- (AVCaptureMetadataOutput *)output
{
    if (!_output)
    {
        _output = [[AVCaptureMetadataOutput alloc]init];
        
       [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
       
    }

    return _output;


}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, NO, 1);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f].CGColor);
    CGContextFillRect(ctx, layer.bounds);
    CGRect scanFrame = [self.backView convertRect:self.scanView.frame toView:self.scanView.superview];
    CGContextClearRect(ctx, scanFrame);
    


}

#pragma mark ---AVCaptureMetadataOutputObjectsDelegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    [MBProgressHUD showMessage:@"正在解析"];
    NSString *result = @"";
    //->>扫描到信息时候进行回调
    if(metadataObjects.count > 0)
    {
    
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        
         result = metadataObject.stringValue;
        [self.line removeFromSuperview];
        
        if (result == nil)
        {
            result = @"";
        }
        
        if (result.length != 15)
        {
            
            [MBProgressHUD hideHUD];
            
            [MBProgressHUD showError:@"请扫描长度为15的条形码"];
            
            [_session startRunning];
            
            return;
        }
        
    }
    
    [MBProgressHUD hideHUD];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kCHEXIAOMISETTINGQRCODIDIDFINISHSCANNOTIFICATION object:self userInfo:@{@"info":result}];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.navigationController popViewControllerAnimated:YES];
        
        
    });

}

-  (void)backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    
    self.blackLayer.delegate = nil;
    if (_preview)
    {
        [_preview removeFromSuperlayer];
    }
    
}
@end
