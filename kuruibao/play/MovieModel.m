//
//  MovieModel.m
//  FRIILENS
//
//  Created by 智恒创 on 15/11/5.
//  Copyright © 2015年 zorro. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel



@end
////快照
//-(void)requestTakePictureSuccess:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=snapshot&"];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//    
//}
//
////录像状态 0 停止录像  1 开始录像
//-(void)requestRecordingStatus:(NSInteger)index Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    NSString * urlStr;
//    if (index == 3) {
//        
//        urlStr= @"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=getrecstatus";
//        
//    }else{
//        urlStr= [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=setrecstatus&recstat=%ld",(long)index];
//    }
//    
//    
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
//}
////文件 图片搜索
//-(void)requestSearch:(NSInteger)index Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    NSArray *arr =@[@"file",@"image"];
//    NSArray *arr1 =@[@"searchfile",@"searchimg"];
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=%@&action=%@&index=0",arr[index],arr1[index]];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    _timeVdArray =[NSMutableArray array];
//    _videoArray =[NSMutableArray array];
//    
//    _timeImgArray =[NSMutableArray array];
//    _imageArray =[NSMutableArray array];
//    
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        
//        //        NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSDictionary *dic = str.JSONValue;
//        NSLog(@"responseString %@",dic);
//        if (index == 0) {
//            
//            NSMutableArray *tempArray=[NSMutableArray array];
//            if ([dic[@"result"] isEqualToString:@"ok"]) {
//                
//                for (NSDictionary *dictionary in dic[@"prevideo"]) {
//                    
//                    _videoModel = [[VideoModel alloc] init];
//                    _videoModel.videoid     = dictionary[@"videoid"];
//                    _videoModel.videotitle  = dictionary[@"videotitle"];
//                    _videoModel.videoname   = dictionary[@"videoname"];
//                    _videoModel.videostatus = dictionary[@"videostatus"];
//                    _videoModel.videoduration = dictionary[@"videoduration"];
//                    
//                    NSString *timeStr=[_videoModel.videotitle  substringWithRange:NSMakeRange(0, 8)];
//                    if (![self setTimeStr:timeStr With:1]) {
//                        
//                        [_timeVdArray addObject:timeStr];
//                    }
//                    
//                    [tempArray addObject:_videoModel];
//                }
//            }
//            
//            //根据时间分组
//            for (int i=0; i<_timeVdArray.count; i++) {
//                
//                NSMutableArray *singleArray=[NSMutableArray array];
//                
//                for (int j=0; j<tempArray.count; j++) {
//                    
//                    VideoModel *model= tempArray[j];
//                    
//                    NSString *timeStr=[model.videotitle  substringWithRange:NSMakeRange(0, 8)];
//                    
//                    if ([_timeVdArray[i] isEqualToString:timeStr]) {
//                        
//                        
//                        [singleArray addObject:model];
//                        
//                    }
//                    
//                }
//                [_videoArray addObject:singleArray];
//                NSLog(@"_videoArray  count==%d",_videoArray.count);
//                NSLog(@"_videoArray==%@",_videoArray);
//                
//            }
//            
//            
//            
//        }else{
//            
//            NSMutableArray *tempArray=[NSMutableArray array];
//            if ([dic[@"result"] isEqualToString:@"ok"]) {
//                
//                for (NSDictionary *dictionary in dic[@"preimage"]) {
//                    _imageModel = [[ImageModel alloc] init];
//                    _imageModel.imageid     = dictionary[@"imageid"];
//                    _imageModel.imagetitle  = dictionary[@"imagetitle"];
//                    _imageModel.imagename   = dictionary[@"imagename"];
//                    _imageModel.imagestatus = dictionary[@"imagestatus"];
//                    
//                    NSString *timeStr=[_imageModel.imagetitle  substringWithRange:NSMakeRange(0, 8)];
//                    if (![self setTimeStr:timeStr With:0]) {
//                        
//                        [_timeImgArray addObject:timeStr];
//                    }
//                    
//                    [tempArray addObject:_imageModel];
//                    
//                    
//                }
//            }
//            
//            
//            //根据时间分组
//            for (int i=0; i<_timeImgArray.count; i++) {
//                
//                NSMutableArray *singleArray=[NSMutableArray array];
//                
//                for (int j=0; j<tempArray.count; j++) {
//                    
//                    ImageModel *model= tempArray[j];
//                    
//                    NSString *timeStr=[model.imagetitle  substringWithRange:NSMakeRange(0, 8)];
//                    
//                    if ([_timeImgArray[i] isEqualToString:timeStr]) {
//                        
//                        
//                        [singleArray addObject:model];
//                        
//                    }
//                }
//                [_imageArray addObject:singleArray];
//                
//            }
//            
//            
//        }
//        
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//}
//
////获取产品型号
//-(void)requestGetversionSuccess:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    NSURL *url = [NSURL URLWithString:@"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=getversion"];
//    
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
//}
//
//
////获取分辨率
//-(void)requestGetRecordStausSuccess:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    NSURL *url = [NSURL URLWithString:@"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=getrecord"];
//    
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//    
//}
//
////获取灵敏度
//-(void)requestGetGsensorSuccess:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    NSURL *url = [NSURL URLWithString:@"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=getgsensor"];
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//}
//
//
////灵敏度 0 low   1 normal  2 high
//-(void)requestGsensor:(NSInteger)index Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setgsensor&gsensordpi=%ld",(long)index];
//    
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//    
//}
////分辨率 0 1080p  1 720p  2 360p
//-(void)requestRecordResolution:(NSInteger)index Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setrecord&resolution=%ld",(long)index];
//    
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//    
//}
////录制时间 0: 1min   1: 3min   2: 5min
//-(void)requestRecordRectime:(NSInteger)index Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setrecord&rectime=%ld",(long)index];
//    
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//    
//}
////帧率 0: 30   1: 25   2: 20  2: 15
//-(void)requestRecordFrames:(NSInteger)index Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setrecord&frames=%ld",(long)index];
//    
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//}
//
////设置视频格式
//-(void)requestSetVideoFormat:(NSInteger)index WithType:(NSInteger)type Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    NSString * urlStr;
//    if (type == 0) {
//        urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setimage&videoformat=%ld",(long)index];
//    }else{
//        urlStr = @"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=getimage";
//    }
//    
//    
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//}
//
//
//
////设置系统时间
//-(void)requestSetTimeSuccess:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    
//    NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
//    dateFor.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
//    
//    NSString *dateStr = [dateFor stringFromDate:[NSDate date]];
//    
//    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=setdatetime&%@",dateStr];
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
//}
//
//
//
////系统将重新启动
//-(void)requestRebootSuccess:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    NSURL *url = [NSURL URLWithString:@"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=Restore"];
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
//}
//
//
////摄像模式  0:自动 1:手动
//-(void)requestCameraMode:(NSInteger)index Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    //0:自动 1:手动 2 获取模式状态
//    NSString * urlStr;
//    if (index == 0 || index==1) {
//        urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=setrecmode&recmode=%ld",(long)index];
//    }else if (index==2){
//        urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=getrecmode"];
//    }
//    
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        NSLog(@"Httperror: %@%ld", error.localizedDescription, (long)error.code);
//        if (failed) failed(error);
//        
//    }];
//}
//
//
//
//
//
//
//
////获取图片
//-(void)requestGetImageSuccess:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=getimage"];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//    
//}
//
////加锁/不加锁/删除文件
//-(void)requestSetFile:(NSInteger)index WithName:(NSString *)name Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    NSArray *arr =@[@"lockfile",@"unlockfile",@"deletefile"];
//    
//    NSString *str =[name substringWithRange:NSMakeRange(0, name.length-4)];
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=file&action=%@&name=%@",arr[index],str];
//    
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    NSLog(@"deletefile  ==%@",url);
//    
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//}
//
////图片设置
//-(void)requestSetImageHud:(NSInteger)hud WithBrightness:(NSInteger )brightness Success:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=param&action=setimage&hue=%ld&brightness=%ld",(long)hud,(long)brightness];
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
//}
//
//
//
////请求格式化SD卡
//-(void)requestFormatSDSuccess:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=Formattf"];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//    
//}
//
//
////请求检测SD卡
//-(void)requestCheckTFSuccess:(void (^)(NSDictionary *dict))success failed:(void (^)(NSError *error))failed{
//    
//    
//    NSString * urlStr = [NSString stringWithFormat:@"http://192.168.63.9/cgi-bin/Control.cgi?type=system&action=CheckTF"];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    
//    [self requestDefault:url success:^(NSString *str) {
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:str];
//        if (success) success(dic);
//        
//    } failed:^(NSError *error) {
//        
//        if (failed) failed(error);
//        
//    }];
//    
//}
//
//-(void)requestDefault:(NSURL *)url success:(void (^)(NSString *str))success failed:(void (^)(NSError *error))failed{
//    
//    if ([self isCurrentWIFI]) {
//        
//        
//        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//        __weak ASIHTTPRequest *weakRequest = request;
//        [weakRequest setCompletionBlock:^{
//            
//            NSString *str = weakRequest.responseString;
//            
//            if (success)
//            {
//                success(str);
//            }
//        }];
//        [weakRequest setFailedBlock:^{
//            if (failed)
//            {
//                failed(nil);
//            }
//        }];
//        
//        [weakRequest startAsynchronous];
//        
//        
//        
//        //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
//        //
//        ////    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
//        //    [request setHTTPMethod:@"GET"];
//        //    [NSURLConnection sendAsynchronousRequest: request queue: [NSOperationQueue mainQueue] completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
//        //
//        //        if (error) {
//        //            NSLog(@"Httperror: %@%ld", error.localizedDescription, (long)error.code);
//        //
//        //            if (failed) failed(error);
//        //
//        //        } else {
//        //
//        //            NSDictionary *dic = [NSDictionary dictionaryWithXMLData:data];
//        //             NSLog(@"responseString %@",dic);
//        //            if (success) success(data);
//        //        }
//        //    }];
//    }else{
//        [MBHUDHelper showMessag:@"WIFI已断开"];
//    }
//}
//-(NSDateFormatter *)dateForm:(NSString *)dateFormat{
//    
//    static NSDateFormatter *dateFor = nil;
//    
//    dateFor = [[NSDateFormatter alloc] init];
//    dateFor.dateFormat = dateFormat;
//    
//    return dateFor;
//}
//
//#pragma mark 根据CMTime生成一个时间字符串
//- (NSString *)timeStringWithCMTime:(NSInteger)time {
//    
//    
//    // 把seconds当作时间戳得到一个date
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
//    
//    // 格林威治标准时间
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//    
//    // 设置时间显示格式
//    [formatter setDateFormat:(time / 3600 >= 1) ? @"h:mm:ss" : @"mm:ss"];
//    
//    // 返回这个date的字符串形式
//    return [formatter stringFromDate:date];
//}
//#pragma mark 判断时间
//-(BOOL)setTimeStr:(NSString *)str With:(NSInteger)type{
//    BOOL isEqual;
//    isEqual =NO;
//    if (type == 0) {
//        for (int i=0; i<_timeImgArray.count; i++) {
//            
//            if ([str isEqualToString:_timeImgArray[i]]) {
//                isEqual=YES;
//                break;
//            }
//        }
//    }else{
//        for (int i=0; i<_timeVdArray.count; i++) {
//            
//            if ([str isEqualToString:_timeVdArray[i]]) {
//                isEqual=YES;
//                break;
//            }
//        }
//    }
//    
//    return isEqual;
//}
//
//-(BOOL)isCurrentWIFI{
//    BOOL isCurrent;
//    isCurrent = NO;
//    _currentWifi = [self getSSIDInfo];
//    
//    NSString *SSID = _currentWifi[@"SSID"];
//    if ([SSID hasPrefix:@"DVR"]) {
//        isCurrent =YES;
//    }
//    return isCurrent;
//}
//
//- (id)getSSIDInfo
//{
//    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    id info = nil;
//    for (NSString *ifnam in ifs) {
//        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        if (info && [info count]) {
//            break;
//        }
//    }
//    
//    return info;
//}

