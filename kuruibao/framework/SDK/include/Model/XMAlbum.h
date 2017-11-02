//
//	XMAlbum.h
//
//	Create by 王瑞 on 28/8/2015
//	Copyright © 2015. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>
#import "XMAnnouncer.h"
#import "XMLastUptrack.h"

@interface XMAlbum : NSObject

@property (nonatomic, strong) NSString * albumIntro;
@property (nonatomic, strong) NSString * albumTags;
@property (nonatomic, strong) NSString * albumTitle;
@property (nonatomic, strong) XMAnnouncer * announcer;
@property (nonatomic, strong) NSString * coverUrlLarge;
@property (nonatomic, strong) NSString * coverUrlMiddle;
@property (nonatomic, strong) NSString * coverUrlSmall;
@property (nonatomic, assign) NSInteger favoriteCount;
@property (nonatomic, assign) NSInteger albumId;
@property (nonatomic, assign) NSInteger includeTrackCount;
@property (nonatomic, assign) NSInteger isFinished;
@property (nonatomic, strong) NSString * kind;
@property (nonatomic, strong) XMLastUptrack * lastUptrack;
@property (nonatomic, assign) NSInteger playCount;
@property (nonatomic, assign) NSInteger subscribeCount;

@property (nonatomic, assign) double createdAt;
@property (nonatomic, assign) double updatedAt;

//可否下载，YES-可下载，NO-不可下载
@property (nonatomic, assign) BOOL canDownload;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;

@end
