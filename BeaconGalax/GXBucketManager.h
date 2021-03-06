//
//  GXBucketManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/30.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import "GXQuest.h"

@interface GXBucketManager : NSObject
//AppScope
@property (nonatomic) KiiBucket *galaxUser;
@property (nonatomic) KiiBucket *questBoard;
@property (nonatomic) KiiBucket *inviteBoard;
@property (nonatomic) KiiBucket *activityBucket;
@property (nonatomic) KiiBucket *user_beacons;
@property (nonatomic) KiiBucket *rank_bucket;

//GroupScope
@property (nonatomic) KiiBucket *questMember;

//UserScope
@property (nonatomic) KiiBucket *notJoinedQuest;
@property (nonatomic) KiiBucket *nearUser; //消す
@property (nonatomic) KiiBucket *joinedQuest;
@property (nonatomic) KiiBucket *joinedOnePersonQuest; //一人用
@property (nonatomic) KiiBucket *joinedMultiPersonQuest; //複数用
@property (nonatomic) KiiBucket *pointBucket;
@property (nonatomic) KiiBucket *clearedBucket;
@property (nonatomic) KiiBucket *notis_questDeliver;
@property (nonatomic) KiiBucket *attendBucket; //研究室への出席をとる

//Analytics
@property (nonatomic) KiiBucket *pageViewBucket;
@property (nonatomic) KiiBucket *userActionBucket;

+ (GXBucketManager *)sharedManager;

//登録
- (void)registerQuest:(GXQuest *)quest;
- (void)registerInviteBoard:(KiiObject *)obj;
- (void)registerJoinedMultiQuest:(KiiObject *)obj;

- (void)fetchQuestWithNotComplited;
- (void)fetchMissionWithNotCompleted;

//参加した一人用クエストフェッチ
- (void)getJoinedOnePersonQuest;

//マルチ用クエストフェッチ
- (void)getJoinedMultiPersonQuest;

//招待されたクエストをフェッチ
- (void)getInvitedQuest;

//クエストメンバーをフェッチ
- (void)getQuestMember:(KiiGroup *)group;
//グループでやってるクエストをフェッチ
- (KiiObject *)getGroupQuest:(KiiGroup *)group;

- (KiiObject *)getMeFromGalaxUserBucket;

- (BOOL)isJoinedQuest:(NSString *)questTitile;
- (BOOL)isExitedQuest:(NSString *)questTitle;
- (BOOL)isInvitedQuest:(KiiObject *)obj;

- (void)getJoinedQuest;
- (NSMutableArray *)getNearUser:(KiiUser *)user;
- (void)registerJoinedQuest:(KiiObject *)obj;
- (void)getOwnerQuest;

- (void)acceptNewQuest:(KiiObject *)obj;
- (void)deleteJoinedQuest:(KiiObject *)obj;

- (KiiObject *)getGalaxUser:(NSString *)userURI;
- (NSMutableArray *)getQuestMembers:(NSArray *)members;

//近づく、集まる対象のbeaconに紐付いたユーザfbidを取得する
- (void)getTargetBeaconUserFbid:(NSNumber *)major;

//その内サーバー側で処理できるようにする
- (void)getQuestForQuestBoard;

//クリア判定
- (BOOL)isClear:(KiiObject *)obj;

//データ操作用
- (void)deleteAllObject:(KiiBucket *)bucket;
- (void)displayAllObject:(KiiBucket *)bucket;

- (void)countNotJoinBucket;
- (void)countJoinedBucket;
- (void)countInviteBucket;


//購読
- (void)subscribeNotJoinBucket;

@end
