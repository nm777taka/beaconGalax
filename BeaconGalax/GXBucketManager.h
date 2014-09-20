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
@property (nonatomic) KiiBucket *nearUser;
@property (nonatomic) KiiBucket *joinedQuest;
@property (nonatomic) KiiBucket *myQuestParticipants;

+ (GXBucketManager *)sharedManager;
- (void)registerGalaxUser:(KiiUser *)user;
- (void)registerQuest:(GXQuest *)quest;
- (NSMutableArray *)fetchQuestWithNotComplited;
- (KiiObject *)getMeFromGalaxUserBucket;
- (BOOL)isJoinedQuest:(NSString *)questTitile;
- (BOOL)isExitedQuest:(NSString *)questTitle;
- (NSMutableArray *)getJoinedQuest;

- (NSMutableArray *)getNearUser:(KiiUser *)user;


//データ操作用
- (void)deleteAllObject:(KiiBucket *)bucket;
- (void)displayAllObject:(KiiBucket *)bucket;



@end
