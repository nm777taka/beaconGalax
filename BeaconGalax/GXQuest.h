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
@property (nonatomic,retain) NSString *quest_req; //クリア条件
@property (nonatomic,retain) NSString *quest_status; //クエストの状態
@property (nonatomic,retain) NSString *quest_des; //クエスト詳細

//サポート用
@property (nonatomic,retain) NSNumber *player_num; //クエストのタイプ(１orマルチ）判定用
@property (nonatomic,retain) NSString *owner; //募集クエストで判定につかう
@property (nonatomic,retain) NSNumber *major; //beaconのmajor値
@property (nonatomic,retain) NSString *groupURI; //協力クエスト用(グループ参加で使う)
@property (nonatomic,retain) NSDate *createdDate; //日時表示用

//サーバーリクエストキー
@property (nonatomic,retain) NSString *quest_id;
@property (nonatomic,retain) KiiBucket *bucket;





//lagacy
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *createUserURI;
@property (nonatomic,assign) NSNumber *isStarted;
@property (nonatomic,assign) NSNumber *isCompleted;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,retain) NSString *createdUserName;


@end
