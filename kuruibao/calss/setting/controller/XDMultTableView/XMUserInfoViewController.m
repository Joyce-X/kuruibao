//
//  XMUserInfoViewController.m
//  kuruibao
//
//  Created by x on 16/9/6.
//  Copyright © 2016年 ChexXiaoMi. All rights reserved.
//
/***********************************************************************************************
 展示个人资料设置界面的详细选择项
 
 
 ************************************************************************************************/
#import "XMUserInfoViewController.h"
#import "XMUserInfoView.h"
//#import "XMHeaderSetViewController.h"
#import "XMSetAddressViewController.h"
#import "XMSetBirthdayViewController.h"
#import "XMSetNickNameViewController.h"
#import "XMSetSignNameViewController.h"
#import "XMCutImageViewController.h"
#import "RSKImageCropViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "XMUser.h"




 @interface XMUserInfoViewController ()<XMUserInfoViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate,RSKImageCropViewControllerDataSource>

@property (nonatomic,weak)XMUserInfoView* infoView;//!< 显示具体设置界面

@property (nonatomic,strong)UIImagePickerController* picker;

@property (strong, nonatomic) AFHTTPSessionManager *session;

@end

@implementation XMUserInfoViewController


#pragma mark --- life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    //->>设置子视图
    [self setupSubViews];
    
    
 }


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MobClickBegain(@"用户资料页面");

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    MobClickEnd(@"用户资料页面");
    
}


- (void)setupSubViews
{
    self.message = @"个人资料";
    
    self.view.backgroundColor = XMColorFromRGB(0xF8F8F8);
  
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, backImageH, mainSize.width, mainSize.height - backImageH)];
 
    //->>底部设置选项
    XMUserInfoView *infoView = [[[NSBundle mainBundle] loadNibNamed:@"XMInfoView" owner:nil options:nil] firstObject];
    
    infoView.delegate = self;
    
    infoView.frame = CGRectMake(0, 0, mainSize.width, mainSize.height - backImageH);
    
    self.infoView = infoView;
    
    [tableView setTableHeaderView:infoView];
    
    [self.view addSubview:tableView];
    
}




#pragma mark --- lazy

- (AFHTTPSessionManager *)session
{
    if (!_session)
    {
        _session = [AFHTTPSessionManager manager];
        
        _session.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        _session.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _session.requestSerializer.timeoutInterval = 10;
    }
    
    return _session;

}

#pragma mark --- XMUserInfoViewDelegate

/**
 *  点击头像 跳转到设置头像界面 底部弹出actionsheet 显示相机拍照or取消
 */
- (void)userInfoViewHeaderDidClick:(XMUserInfoView *)userInfoView
{

    //->>弹出表格供用户选择
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [sheet showInView:self.view];

}

/**
 *  点击各项签名界面 跳转到个性签名界面
 */
- (void)userInfoViewSignNameDidClick:(XMUserInfoView *)userInfoView
{
    XMSetSignNameViewController *vc = [XMSetSignNameViewController new];
    
    vc.completion = ^(id result)
    {
        _infoView.sign = result;
    
    };
    
     [self.navigationController pushViewController:vc animated:YES];


}


/**
 *  点击昵称 跳转到设置昵称界面
 */
- (void)userInfoViewNickNameDidClick:(XMUserInfoView *)userInfoView
{
    XMSetNickNameViewController *vc =[XMSetNickNameViewController new];
    
    vc.completion = ^(NSString *result){
    
        _infoView.nickName = result;
    };
    
    [self.navigationController pushViewController:vc animated:YES];
    

}

/**
 *  点击生日 跳转到设置生日界面
 */
- (void)userInfoViewBirthdayDidClick:(XMUserInfoView *)userInfoView
{
    XMSetBirthdayViewController *vc =[XMSetBirthdayViewController new];
    
    vc.completion = ^(id result)
    {
        _infoView.birthday = result;
    
    };
    
    [self.navigationController pushViewController:vc animated:YES];

}

/**
 *  点击地址 跳转到设置地址界面
 */
- (void)userInfoViewAddressDidClick:(XMUserInfoView *)userInfoView
{
    XMSetAddressViewController *vc =[XMSetAddressViewController new];
    
    vc.completion = ^(id result)
    {
        _infoView.address= result;
        
    };
    
    [self.navigationController pushViewController:vc animated:YES];
    


}



#pragma mark --- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 2)
    {
         //->点击取消
        return;
    }
    
    UIImagePickerController *pickVC = [[UIImagePickerController alloc]init];
    pickVC.delegate = self;
    
    if (buttonIndex == 0)
    {
        //->>点击相机
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            
            return;
        }
        
        pickVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    }else
    {
        //->>点击图库
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
             return;
        }
        
        pickVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    }
    
    
    [self presentViewController:pickVC animated:YES completion:nil];
    

}



#pragma mark UINavigationControllerDelegate, UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    //->>点击取消
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
     _picker = picker;

     UIImage *oldImage = info[UIImagePickerControllerOriginalImage];
    
     RSKImageCropViewController *vc = [[RSKImageCropViewController alloc]initWithImage:oldImage];
    
    vc.delegate = self;
    
    vc.dataSource = self;
    
    [picker pushViewController:vc animated:YES];
  
    
}

//->>压缩图片
- (UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)targetWidth {
    
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    
    [sourceImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
     return newImage;
}


#pragma mark --- RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [_picker dismissViewControllerAnimated:YES completion:nil];
}


//->>裁剪完成图片
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{

     croppedImage = [self compressImage:croppedImage toTargetWidth:600];
    
     //->>保存裁剪合格的头像图片
    UIImage *showImage = [UIImage circleImageWithName:croppedImage borderWide:20 color:XMColorFromRGB(0x7F7F7F)];
  
    
      [_picker dismissViewControllerAnimated:YES completion:^{
    
        [self uploadUserImageWithImage:showImage];
    
    }];
}







// Returns a custom rect for the mask.
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    CGSize maskSize;
    if ([controller isPortraitInterfaceOrientation]) {
        maskSize = CGSizeMake(250, 250);
    } else {
        maskSize = CGSizeMake(220, 220);
    }
    
    CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
    CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
    
    CGRect maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                 (viewHeight - maskSize.height) * 0.5f,
                                 maskSize.width,
                                 maskSize.height);
    
    
    
    return maskRect;
}

// Returns a custom path for the mask.
- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller
{
    CGRect rect = controller.maskRect;
    CGPoint point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint point2 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGPoint point3 = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:point1];
    [triangle addLineToPoint:point2];
    [triangle addLineToPoint:point3];
    [triangle closePath];
    
    return triangle;
}

// Returns a custom rect in which the image can be moved.
- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller
{
    // If the image is not rotated, then the movement rect coincides with the mask rect.
    return controller.maskRect;
}


//!< 上传头像到服务器
- (void)uploadUserImageWithImage:(UIImage *)image
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.labelText = @"正在上传";
    
    NSString *urlStr = [mainAddress stringByAppendingString:@"uploaduserimage"];
    
   [self.session POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
       
       NSData *imageData = UIImagePNGRepresentation(image);
       
       NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
       
       formatter.dateFormat =@"yyyyMMddHHmmss";
       
       NSString *str = [formatter stringFromDate:[NSDate date]];
       
       NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
       
       //上传的参数(上传图片，以文件流的格式)
       [formData appendPartWithFileData:imageData
                                   name:@"file"
                               fileName:fileName
                               mimeType:@"image/png"];
       
       
       
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
         hud.mode = MBProgressHUDModeText;
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        
        int statusCode = [dic[@"code"] intValue];
        
        if (statusCode == 1)
        {
             hud.labelText = @"上传成功";
            
            _infoView.image = image;
            
            NSData *data = UIImagePNGRepresentation(image);
            
            [data writeToFile:XIAOMI_HEADERLOCALPATH atomically:YES];
            
            
            //->>发送通知更新设置界面的头像 通知头部自定义视图更换头像
            [[NSNotificationCenter defaultCenter] postNotificationName:kXIAOMIHEADERIMAGEWRITEFINISHNOTIFICATION object:nil];
            
            NSString *address = dic[@"data"];
            
            [[NSUserDefaults standardUserDefaults] setObject:address forKey:@"userInfo_userImage"];
            
            XMLOG(@"%@",address);
            
        }else
        {
            hud.labelText = @"上传失败";
         
        }
        
         [hud hide:YES afterDelay:0.5];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        hud.mode = MBProgressHUDModeText;
        
        hud.labelText = @"上传失败";
        
        [hud hide:YES afterDelay:0.5];
        
        
    }];
   
    
 
    
    
}


- (void)backToLast
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (tempAppDelegate.sliderVC.closed)
    {
        [tempAppDelegate.sliderVC openLeftView];
    }
    
    
    //!< 参数准备
    
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //!< 用户编号
    XMUser *user = [XMUser user];
    
    //!< 图片访问地址
    NSString *headerImagePath = [defaults objectForKey:@"userInfo_userImage"];
    
    //!< 性别
    NSString *sex = [defaults objectForKey:@"userInfo_sex"];
    
    //!< 签名
    NSString *signName = [defaults objectForKey:@"userInfo_signName"];
    
    //!< 昵称
    NSString *nickName = [defaults objectForKey:@"userInfo_nickName"];
    
    //!< 生日
    NSString *birthday = [defaults objectForKey:@"userInfo_birthday"];
    
    //!< 地区
    NSString *area = [defaults objectForKey:@"userInfo_area"];
    
    
    NSString *urlStr = [mainAddress stringByAppendingFormat:@"setuserinfo&userid=%ld&userimage=%@&sex=%@&signname=%@&nickname=%@&birthday=%@&userarea=%@",(long)user.userid,headerImagePath,sex,signName,nickName,birthday,area];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.session GET:urlStr parameters:nil progress:nil success:nil failure:nil];
    
    [self.navigationController popViewControllerAnimated:YES];

}



@end
