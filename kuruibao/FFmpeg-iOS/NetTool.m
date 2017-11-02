//
//  NetTool.m
//  FRIILENS
//
//  Created by 黎峰麟 on 16/1/23.
//  Copyright © 2016年 zorro. All rights reserved.
//

#import "NetTool.h"
//#import "NSString+SBJSON.h"
#import "GDataXMLNode.h"
#import "XMLDictionary.h"

@interface NetTool(){
    NSDictionary *_currentWifi;
}


@end


@implementation NetTool

DEF_SINGLETON(NetTool)


#pragma mark -快照
-(void)requestTakePictureSuccess:(void (^)(NSDictionary *dict))success
                          failed:(void (^)(NSError *error))failed{
    
    
    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=snapshot&"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}

#pragma mark -录像状态 0 停止录像  1 开始录像
-(void)requestRecordingStatus:(NSInteger)index
                      Success:(void (^)(NSDictionary *dict))success
                       failed:(void (^)(NSError *error))failed{
    
    NSString * urlStr;
    if (index == 3) {
        
        urlStr= @"cgi-bin/Control.cgi?type=system&action=getrecstatus";
        
    }else{
        urlStr= [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=system&action=setrecstatus&recstat=%ld",(long)index];
    }
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}

#pragma mark -文件 图片搜索
-(void)requestSearch:(NSInteger)index
              Update:(int)update
             Success:(void (^)(NSDictionary *dict))success
              failed:(void (^)(NSError *error))failed{
    
    NSArray *arr =@[@"file",@"image",@"file"];
    NSArray *arr1 =@[@"searchfile",@"searchimg",@"searchevent"];
    
    NSString * urlStr ;
    

    urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=%@&action=%@&index=%d",arr[index],arr1[index],update*20];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    


        [self requestDefault:url success:^(NSString *str) {

//            ;
           NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
//             = str.JSONValue;
    
            if (success) {
                success(dic);
                NetToolManager.isSuccess = YES;
            }
            
        } failed:^(NSError *error) {
            
            if (failed) {
                failed(error);
                NetToolManager.isSuccess = NO;
            }
            
        }];
    
   }

#pragma mark -获取产品型号
-(void)requestGetversionSuccess:(void (^)(NSDictionary *dict))success
                         failed:(void (^)(NSError *error))failed{
    NSURL *url = [NSURL URLWithString:@"cgi-bin/Control.cgi?type=system&action=getversion"];
    
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}


#pragma mark -获取分辨率
-(void)requestGetRecordStausSuccess:(void (^)(NSDictionary *dict))success
                             failed:(void (^)(NSError *error))failed{
    NSURL *url = [NSURL URLWithString:@"cgi-bin/Control.cgi?type=param&action=getrecord"];
    
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}

#pragma mark -获取灵敏度
-(void)requestGetGsensorSuccess:(void (^)(NSDictionary *dict))success
                         failed:(void (^)(NSError *error))failed{
    
    NSURL *url = [NSURL URLWithString:@"cgi-bin/Control.cgi?type=param&action=getgsensor"];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
}


#pragma mark -灵敏度 0 low   1 normal  2 high
-(void)requestGsensor:(NSInteger)index
              Success:(void (^)(NSDictionary *dict))success
               failed:(void (^)(NSError *error))failed{
    
    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=param&action=setgsensor&gsensordpi=%ld",(long)index];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}
#pragma mark -分辨率 0 1080p  1 720p  2 360p
-(void)requestRecordResolution:(NSInteger)index
                       Success:(void (^)(NSDictionary *dict))success
                        failed:(void (^)(NSError *error))failed{
    
    
    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=param&action=setrecord&resolution=%ld",(long)index];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}
#pragma mark -录制时间 0: 1min   1: 3min   2: 5min
-(void)requestRecordRectime:(NSInteger)index
                    Success:(void (^)(NSDictionary *dict))success
                     failed:(void (^)(NSError *error))failed{
    
    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=param&action=setrecord&rectime=%ld",(long)index];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}
#pragma mark -帧率 0: 30   1: 25   2: 20  2: 15
-(void)requestRecordFrames:(NSInteger)index
                   Success:(void (^)(NSDictionary *dict))success
                    failed:(void (^)(NSError *error))failed{
    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=param&action=setrecord&frames=%ld",(long)index];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
}

#pragma mark -设置视频 type 0设置静音或开启  1获取声音状态  2设置声音
-(void)requestSetVideoRecMute:(NSInteger)index
                     WithType:(NSInteger)type
                      Success:(void (^)(NSDictionary *dict))success
                       failed:(void (^)(NSError *error))failed{
    NSString * urlStr;
    if (type == 0) {
        urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=param&action=setaudio&recmute=%ld",(long)index];
    }else if (type == 1){
        urlStr = @"cgi-bin/Control.cgi?type=param&action=getaudio";
    }else if (type == 2){
        urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=param&action=setaudio&volume=%ld",(long)index];
    }
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
}



#pragma mark -设置系统时间
-(void)requestSetTimeSuccess:(void (^)(NSDictionary *dict))success
                      failed:(void (^)(NSError *error))failed{
    
    
    NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
    dateFor.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
    
    NSString *dateStr = [dateFor stringFromDate:[NSDate date]];
    
    NSString *urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=system&action=setdatetime&%@",dateStr];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
}



#pragma mark -系统将重新启动
-(void)requestRebootSuccess:(void (^)(NSDictionary *dict))success
                     failed:(void (^)(NSError *error))failed{
    NSURL *url = [NSURL URLWithString:@"cgi-bin/Control.cgi?type=system&action=Restore"];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}


#pragma mark -摄像模式  0:自动 1:手动
-(void)requestCameraMode:(NSInteger)index
                 Success:(void (^)(NSDictionary *dict))success
                  failed:(void (^)(NSError *error))failed{
    
    //0:自动 1:手动 2 获取模式状态
    NSString * urlStr;
    if (index == 0 || index==1) {
        urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=system&action=setrecmode&recmode=%ld",(long)index];
    }else if (index==2){
        urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=system&action=getrecmode"];
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        NSLog(@"Httperror: %@%ld", error.localizedDescription, (long)error.code);
        if (failed) failed(error);
        
    }];
}



#pragma mark -加锁/不加锁/删除文件
-(void)requestSetFile:(NSInteger)index
             WithName:(NSString *)name Success:(void (^)(NSDictionary *dict))success
               failed:(void (^)(NSError *error))failed{
    
    NSArray *arr =@[@"lockfile",@"unlockfile",@"deletefile",@"deleteimg"];
    
    NSString *str =[name substringWithRange:NSMakeRange(0, name.length-4)];
    NSString * urlStr;
    NSLog(@"name%@,str%@",name,str);
    if (index ==0||index ==1) {
        urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=file&action=%@&name=%@",arr[index],name];
    }else  if (index ==2){
         urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=file&action=%@&name=%@",arr[index],str];
    }else  if (index ==3){
        //http://192.168.63.9/cgi-bin/Control.cgi?type=image&action=deleteimg&name=201600606110101.jpg
        urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=image&action=%@&name=%@",arr[index],name];
        NSLog(@"urlStr-%@",urlStr);
    }
    
  
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
//    NSLog(@"deletefile  ==%@",url);
//    http://192.168.63.9/cgi-bin/Control.cgi?type=image&action=deleteimg&name=20160625154929.jpg
    
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        NSLog(@"dic--%@",dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
         NSLog(@"error--%@",error);
    }];
}
#pragma mark -获取图片
-(void)requestGetImageSuccess:(void (^)(NSDictionary *dict))success
                       failed:(void (^)(NSError *error))failed{
    
    
    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=param&action=getimage"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}

#pragma mark -图片设置
-(void)requestSetImageBrightness:(NSInteger)brightness
                        Contrast:(NSInteger)contrast
                             Hue:(NSInteger)hue
                      Saturation:(NSInteger)saturation
                       Sharpness:(NSInteger)sharpness
                       Image_mirror:(NSInteger)image_mirror
                         Success:(void (^)(NSDictionary *dict))success
                          failed:(void (^)(NSError *error))failed{
    
    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=param&action=setimage&brightness=%ld&contrast=%ld&hue=%ld&saturation=%ld&sharpness=%ld&image_mirror=%ld",(long)brightness,(long)contrast,(long)hue,(long)saturation,(long)sharpness,(long)image_mirror];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}


////视频镜像
//-(void)requestSetImage_mirror:(NSInteger)index
//                      Success:(void (^)(NSDictionary *dict))success
//                       failed:(void (^)(NSError *error))failed{
//    
//    
//    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=param&action=setimage&image_mirror=%ld",(long)index];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//    
//    
//    
//}
#pragma mark -请求格式化SD卡
-(void)requestFormatSDSuccess:(void (^)(NSDictionary *dict))success
                       failed:(void (^)(NSError *error))failed{
    
    
    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=system&action=Formattf"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}


#pragma mark -请求检测SD卡
-(void)requestCheckTFSuccess:(void (^)(NSDictionary *dict))success
                      failed:(void (^)(NSError *error))failed{
    
    
    NSString * urlStr = [NSString stringWithFormat:@"cgi-bin/Control.cgi?type=system&action=CheckTF"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [self requestDefault:url success:^(NSString *str) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
        if (success) success(dic);
        
    } failed:^(NSError *error) {
        
        if (failed) failed(error);
        
    }];
    
}
#pragma mark -请求
-(void)requestDefault:(NSURL *)url success:(void (^)(NSString *str))success
               failed:(void (^)(NSError *error))failed{
    
    
        [self.requestHelper emptyCache];
        HttpRequest *hr = [self.requestHelper get:[NSString stringWithFormat:@"%@",url]];
//        NSLog(@"hr = %@", hr );
    
        [hr succeed:^(MKNetworkOperation *op) {
            
            NSString *str = [op responseString];
            
            NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//            NSLog(@"responseString %@",dic);
            
            if (success) success(str);
            
        } failed:^(MKNetworkOperation *op, NSError *err) {
            
            if (failed) failed(err);
            
        }];
        
        [self.requestHelper submit:hr];
        hr.shouldContinueWithInvalidCertificate = YES;
        
        
    
}

-(NSDateFormatter *)dateForm:(NSString *)dateFormat{
    
    static NSDateFormatter *dateFor = nil;
    
    dateFor = [[NSDateFormatter alloc] init];
    dateFor.dateFormat = dateFormat;
    
    return dateFor;
}

#pragma mark 根据CMTime生成一个时间字符串
- (NSString *)timeStringWithCMTime:(NSInteger)time {
    
    
    // 把seconds当作时间戳得到一个date
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    
    // 格林威治标准时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // 设置时间显示格式
    [formatter setDateFormat:(time / 3600 >= 1) ? @"h:mm:ss" : @"mm:ss"];
    
    // 返回这个date的字符串形式
    return [formatter stringFromDate:date];
}


-(BOOL)isCurrentWIFI{
    BOOL isCurrent;
    isCurrent = NO;
    _currentWifi = [self getSSIDInfo];
    
    NSString *SSID = _currentWifi[@"SSID"];
    if ([SSID hasPrefix:@"DVR"]||[SSID hasPrefix:@"UBI"]) {
        isCurrent =YES;
    }
    return isCurrent;
}
-(BOOL)isCurrentUBIWIFI{
    BOOL isCurrent;
    isCurrent = NO;
    _currentWifi = [self getSSIDInfo];
    
    NSString *SSID = _currentWifi[@"SSID"];
    if ([SSID hasPrefix:@"UBI"]||[SSID hasPrefix:@"DVR2"]) {
        isCurrent =YES;
    }
    return isCurrent;
}
- (id)getSSIDInfo
{
//    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    id info = nil;
//    for (NSString *ifnam in ifs) {
//        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        if (info && [info count]) {
//            break;
//        }
//    }
//    
    return nil;
}




@end
