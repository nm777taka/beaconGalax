//
//  GXQuest.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>

@interface GXQuest : NSObject

- (instancetype)initWithTitle:(NSString *)title fbID:(NSString *)fbID;

//表示する要素
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *fb_id;

//サーバーリクエストキー
@property (nonatomic,retain) NSString *quest_id;
@property (nonatomic,retain) KiiBucket *bucket;





//lagacy
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *createUserURI;
@property (nonatomic,retain) NSString *group_uri;
@property (nonatomic,assign) NSNumber *isStarted;
@property (nonatomic,assign) NSNumber *isCompleted;
@property (nonatomic,assign) NSString *createdDate;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,retain) NSString *createdUserName;


@end
