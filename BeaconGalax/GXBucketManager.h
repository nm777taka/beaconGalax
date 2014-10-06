//
//  GXBucketManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/30.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>
#import "GXQuest.h"

@interface GXBucketManager : NSObject
//AppScope
@property (nonatomic) KiiBucket *galaxUser;
@property (nonatomic) KiiBucket *questBoard;

//GroupScope
@property (nonatomic) KiiBucket *questMember;

//UserScope
@property (nonatomic) KiiBucket *missionBoard;
@property (nonatomic) KiiBucket *nearUser;
@property (nonatomic) KiiBucket *joinedQuest;
@property (nonatomic) KiiBucket *myQuestParticipants;

+ (GXBucketManager *)sharedManager;
- (void)registerGalaxUser:(KiiUser *)user;
- (void)registerQuest:(GXQuest *)quest;
- (void)fetchQuestWithNotComplited;
- (void)fetchMissionWithNotCompleted;
- (KiiObject *)getMeFromGalaxUserBucket;
- (BOOL)isJoinedQuest:(NSString *)questTitile;
- (BOOL)isExitedQuest:(NSString *)questTitle;
- (void)getJoinedQuest;
- (NSMutableArray *)getNearUser:(KiiUser *)user;
- (void)registerJoinedQuest:(KiiObject *)obj;
- (void)getOwnerQuest;

- (KiiObject *)getGalaxUser:(NSString *)userURI;


- (NSMutableArray *)getQuestMembers:(NSArray *)members;



//データ操作用
- (void)deleteAllObject:(KiiBucket *)bucket;
- (void)displayAllObject:(KiiBucket *)bucket;



@end
