//
//  XMLYAuthorize.h
//  AuthorizeDemo
//
//  Created by jude on 16/10/18.
//  Copyright © 2016年 ximalaya. All rights reserved.
//

#import <Foundation/Foundation.h>

//响应消息
typedef NS_ENUM(NSInteger, XmlyResponseType) {
    AuthorizeSuccess = 0,       //授权成功
    RefreshTokenSuccess,        //刷新accesstoken成功
    
    ErrorAuthorizeFail,         //授权失败
    ErrorRefreshTokenFail       //刷新accesstoken失败
};

//授权回调返回数据
@interface XMLYAuthorizeModel : NSObject

//授权后的access_token
@property (nonatomic, strong) NSString          *access_token;

//用来刷新access_token
@property (nonatomic, strong) NSString          *refresh_token;

//access_token的生命周期，单位是秒数
@property (nonatomic, assign) NSTimeInterval    expires_in;

//喜马拉雅用户id
@property (nonatomic, assign) long              uid;

//授权范围
@property (nonatomic, strong) NSString          *scope;

//设备号
@property (nonatomic, strong) NSString          *device_id;

@end

//授权回调代理
@protocol XMLYAuthorizeDelegate <NSObject>

/*
 *  成功回调
 *
 *  @param responseType       响应消息类型
 *  @param authorizeModel     响应数据
 */
- (void)onAuthorizeSuccess:(XmlyResponseType)responseType responseData:(XMLYAuthorizeModel *)authorizeModel;

/*
 *  失败回调
 *
 *  @param errorType       失败消息类型
 */
- (void)onAuthorizeFail:(XmlyResponseType)errorType;

@end


@interface XMLYAuthorize : NSObject

/*
 *  SDK单例对象
 */
+ (XMLYAuthorize *)shareInstance;

/*
 *  初始化
 *
 *  @param appKey           分配的appkey
 *  @param appSecret        分配的appsecret
 *  @param appRedirectUri   应用定义的回调地址
 *  @param appPackageId     应用定义的包名
 *  @param appName          应用名字
 *  @param appScheme        应用定义用来跳转的scheme
 *  @param delegate         回调
 */
- (void)initWithAppkey:(NSString *)appKey
             appSecret:(NSString *)appSecret
        appRedirectUri:(NSString *)appRedirectUri
          appPackageId:(NSString *)appPackageId
               appName:(NSString *)appName
             appScheme:(NSString *)appScheme
              delegate:(id<XMLYAuthorizeDelegate>)delegate;

/*
 *  授权接口
 */
- (void)authorize;

/*
 *  刷新授权信息接口
 */
- (void)refreshToken;

/*
 *  注册并授权接口
 */
- (void)registerAndAuthorize;

/*
 *  url跳转
 *
 *  @param url       跳转的url
 */
- (void)handleURL:(NSURL *)url;

@end
