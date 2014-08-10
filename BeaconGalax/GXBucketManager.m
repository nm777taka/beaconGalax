//
//  GXBucketManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/30.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXTopicManager.h"
#import "GXNotification.h"
#import "GXFacebook.h"

@implementation GXBucketManager

+ (GXBucketManager *)sharedManager
{
    static GXBucketManager *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXBucketManager alloc] initSharedInstance];
    });
    
    return sharedSingleton;
}

- (id)initSharedInstance
{
    self = [super init];
    
    if (self) {
        //init
        self.galaxUser = [Kii bucketWithName:@"galax_user"];
        self.questBoard = [Kii bucketWithName:@"quest_board"];
        
        self.questMember = [Kii bucketWithName:@"quest_member"];
        
        self.nearUser = [Kii bucketWithName:@"near_user"];
        self.joinedQuest = [Kii bucketWithName:@"joined_quest"];
    }
    
    return self;
}

#pragma mark - AppScope

- (void)registerGalaxUser:(KiiUser *)user
{
    
    KiiObject *object = [self.galaxUser createObject];
    
    [object setObject:user.objectURI forKey:@"uri"];
    [object setObject:@YES forKey:@"isNear"];
    [object setObject:@YES forKey:@"isMember"];
    
    
    NSError *error = nil;
    [object saveSynchronous:&error];
    
    if (error != nil) {
        NSLog(@"error:%@",error);
    } else {
        NSLog(@"ギャラックスユーザバケットへ登録完了");
        [[GXFacebook sharedManager] getUserFacebookID];
    }

}

- (void)registerQuest:(GXQuest *)quest
{
    KiiObject *object = [self.questBoard createObject];
    [object setObject:quest.title forKey:@"title"];
    [object setObject:quest.description forKey:@"description"];
    [object setObject:quest.createUserURI forKey:@"created_user_uri"];
    [object setObject:quest.fb_id forKey:@"facebook_id"];
    [object setObject:quest.group_uri forKey:@"group_uri"];
    [object setObject:quest.isStarted forKey:@"isStarted"];
    [object setObject:quest.isCompleted forKey:@"isCompleted"];
    
    NSError *error  = nil;
    [object saveSynchronous:&error];
    
    if (error != nil) {
        NSLog(@"error : %@",error);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestCreatedNotification object:nil];
    }
    
}

#pragma mark - GroupScope
- (void)registerQuestMember:(KiiUser *)user
{
    KiiObject *object = [self.questMember createObject];
    
}

#pragma mark - UserScope
- (NSMutableArray *)getNearUser:(KiiUser *)user
{
    //ApplicatiaonBucketからparam=nearのやつをひっぱってくる

    NSError *error = nil;
    KiiClause *clause1 = [KiiClause equals:@"isNear" value:@YES];
    KiiClause *clause2 = [KiiClause notEquals:@"uri" value:user.objectURI];
    KiiClause *totalClause = [KiiClause and:clause1,clause2,nil];

    KiiQuery *query = [KiiQuery queryWithClause:totalClause];
    NSMutableArray *allResults = [NSMutableArray new];
    KiiQuery *nextQuery;
    
    NSArray *results = [self.galaxUser executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    
    [allResults addObjectsFromArray:results];
    
    NSLog(@"registerdUser : %lu",(unsigned long)allResults.count);
    
    KiiObject *obj = allResults.firstObject;
    NSLog(@"near user uri : %@",[obj getObjectForKey:@"uri"]);
    
    return allResults;
    
}

- (KiiObject *)getMeFromGalaxUserBucket;
{
    KiiBucket *bucket = [GXBucketManager sharedManager].galaxUser;
    NSError *error = nil;
    KiiClause *clause = [KiiClause equals:@"uri" value:[KiiUser currentUser].objectURI];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    NSMutableArray *allResult = [NSMutableArray new];
    KiiQuery *nextQuery;
    
    NSArray *results = [bucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    
    KiiObject *current_userObject = results.firstObject;
    
    return current_userObject;
}

#pragma mark Quest Method
- (NSMutableArray *)fetchQuestWithNotComplited
{
    NSError *error = nil;
    NSMutableArray *allResult = [NSMutableArray new];
    KiiClause *clause = [KiiClause equals:@"isCompleted" value:NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    KiiQuery *nextQuery;
    
//   NSArray *results = [self.questBoard executeQuerySynchronous:query withError:&error andNext:&nextQuery];
//    
//    if (error == nil) {
//        [allResult addObjectsFromArray:results];
//    }
    
    [self.questBoard executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error :%@",error);
        } else {
            NSLog(@"resutls-count %u",results.count
                  );
            [allResult addObjectsFromArray:results];
            
            //notification
            [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestFetchedNotification object:nil userInfo:nil];
        }
    }];
    return allResult;
}


@end