//
//  XMReqMgr.h
//  XMOpenPlatform
//
//  Created by nali on 15/8/24.
//
//

#import <Foundation/Foundation.h>
#import "XMSDKInfo.h"

#pragma mark - XMErrorModel

@interface XMErrorModel : NSObject
/** 错误编号 */
@property (nonatomic, assign) NSInteger error_no;
/** 错误代码 */
@property (nonatomic, strong) NSString *error_code;
/** 错误信息描述 */
@property (nonatomic, strong) NSString *error_desc;
@end

//------------------------------------------------------------------------------------

typedef void (^XMRequestHandler)(id result,XMErrorModel *error);

//------------------------------------------------------------------------------------

#pragma mark - XMReqDelegate

@protocol XMReqDelegate <NSObject>

-(void)didXMInitReqOK:(BOOL)result;
-(void)didXMInitReqFail:(XMErrorModel *)respModel;

@end

//------------------------------------------------------------------------------------

#pragma mark - XMReqMgr

@interface XMReqMgr : NSObject

@property (nonatomic,retain) NSString *proxyHost;  //http 代理 host
@property (nonatomic,assign) NSInteger proxyPort;  //http 代理 port
@property (nonatomic,retain) NSString *proxyUsername;  //http 代理 认证用户
@property (nonatomic,retain) NSString *proxyPassword;  //http 代理 认证密码

@property (nonatomic,assign) BOOL usingSynPost;
@property (nonatomic,retain) NSString *appkey;

//设为YES即仍旧使用HTTP请求api.ximalaya.com(默认使用HTTPS)
@property (nonatomic,assign) BOOL usingHttpWhenRequestApiDomain;

+ (XMReqMgr *)sharedInstance;

+ (NSString *)version;

@property (nonatomic,assign) id<XMReqDelegate> delegate;

///**
// *  注册使用http 代理
// *
// *  @param host 必填，

// *  @param port 必填
// */
- (void)useHttpProxy:(NSString*)host port:(NSInteger)port usrname:(NSString*)usrname passwd:(NSString*)passwd effectUrls:(NSArray*)urlStringArray;

///**
// *  取消http代理
// *
// */
- (void)cancelHttpProxy;

///**
// *  生成或更新动态口令（如没有则生成、有则更新）
// *
// *  @param appKey 必填，开放平台应用唯一Key

// *  @param appSecret     必填，APP的私钥，用于生产sig签名
// */
- (void)registerXMReqInfoWithKey:(NSString *)appKey appSecret:(NSString *)appSecret;

///**
// *  请求喜马拉雅的内容
// *
// *  @param reqType 必填，请求类型

// *  @param params  必填，请求参数字典
// *
// *  @param reqHandler 必填，请求完成后的回调block
// */
- (void)requestXMData:(XMReqType)reqType params:(NSDictionary*)params withCompletionHander:(XMRequestHandler)reqHandler;

- (void)postDataToXMSvr:(NSInteger)reqType params:(NSDictionary*)params withCompletionHander:(XMRequestHandler)reqHandler;

///**
// *  请在 AppDelegate的 - (void)applicationWillTerminate:(UIApplication *)application 中调用
// *
// */
- (void)closeXMReqMgr;

@end
