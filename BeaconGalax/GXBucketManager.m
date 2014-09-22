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
#import "GXDictonaryKeys.h"

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
        
        //Userスコープ
        self.joinedQuest = [[KiiUser currentUser] bucketWithName:@"joined_quest"];
        self.myQuestParticipants = [[KiiUser currentUser] bucketWithName:@"myQuest_participants"];
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
    [object setObject:quest.createdUserName forKey:quest_createdUserName];

    
    NSError *error  = nil;
    [object saveSynchronous:&error];
    
    if (error != nil) {
        NSLog(@"error : %@",error);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestCreatedNotification object:nil];
    }
}

- (BOOL)isExitedQuest:(NSString *)questTitle
{
    BOOL ret = false;
    
    KiiClause *clause1 = [KiiClause equals:@"title" value:questTitle];
    KiiClause *clause2 = [KiiClause equals:@"isCompleted" value:@NO];
    KiiClause *totalClause = [KiiClause and:clause1,clause2,nil];
    KiiQuery *query = [KiiQuery queryWithClause:totalClause];
    
    KiiQuery *nextQuery;
    NSError *error = nil;
    
    NSArray *result = [self.questBoard executeQuerySynchronous:query
                                                     withError:&error
                                                       andNext:&nextQuery];
    
    NSMutableArray *allResults = [NSMutableArray new];
    [allResults addObjectsFromArray:result];
    
    if (allResults.count != 0) {
        ret = true;
        NSLog(@"ret is true");
    }
    
    return ret;
}


#pragma mark - GroupScope
- (void)registerQuestMember:(KiiUser *)user
{
    
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

//参加したクエストを自分スコープのバケットに保存
- (void)registerJoinedQuest:(KiiObject *)obj
{
    NSString *title = [obj getObjectForKey:quest_title];
    NSString *groupURI = [obj getObjectForKey:quest_groupURI];
    NSString *ownerFBID = [obj getObjectForKey:quest_createdUser_fbid];
    NSString *owner = [obj getObjectForKey:quest_createdUserName];
    NSNumber *isStarted = [obj getObjectForKey:quest_isStarted];
    NSNumber *isCompleted = [obj getObjectForKey:quest_isCompleted];
    
    KiiObject *newObj = [self.joinedQuest createObject];
    [newObj setObject:title forKey:quest_title];
    [newObj setObject:groupURI forKey:quest_groupURI];
    [newObj setObject:ownerFBID forKey:quest_createdUser_fbid];
    [newObj setObject:owner forKey:quest_createdUserName];
    [newObj setObject:isStarted forKey:quest_isStarted];
    [newObj setObject:isCompleted forKey:quest_isCompleted];
    
    [newObj saveWithBlock:^(KiiObject *object, NSError *error) {
        if (error) NSLog(@"---->eeror:%@",error);
        else NSLog(@"---->自分のバケットに参加クエストを登録");
    }];
}

//joinしたクエストを取得
- (NSMutableArray *)getJoinedQuest
{
    KiiQuery *allQuery = [KiiQuery queryWithClause:nil];
    NSMutableArray *allResutls = [NSMutableArray new];
    NSError *error = nil;
    KiiQuery *nextQuery;
    
    [self.joinedQuest executeQuerySynchronous:allQuery withError:&error andNext:&nextQuery];
    
    if(error != nil) NSLog(@"----->error:%@",error);
    
    return allResutls;
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

- (BOOL)isJoinedQuest:(NSString *)questTitile
{
    BOOL ret = false;
    
    KiiClause *clause = [KiiClause equals:@"title" value:questTitile];
    KiiQuery *query =[KiiQuery queryWithClause:clause];
    NSMutableArray *allResults = [NSMutableArray new];
    KiiQuery *nextQuery;
    NSError *error = nil;
    
    NSArray *result = [self.joinedQuest executeQuerySynchronous:query
                                                      withError:&error
                                                        andNext:&nextQuery];
    [allResults addObject:result];
    
    if (allResults.count == 0) {
        ret = false;
    } else {
        ret = true;
    }
    return ret;
}

#pragma mark Quest Method
- (NSMutableArray *)fetchQuestWithNotComplited
{
    NSError *error = nil;
    NSMutableArray *allResult = [NSMutableArray new];
    KiiClause *clause = [KiiClause equals:@"isCompleted" value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [query sortByDesc:@"_created"];
    KiiQuery *nextQuery;
    
    [self.questBoard executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error :%@",error);
        } else {
           
            [allResult addObjectsFromArray:results];
            
            //notification
            [[NSNotificationCenter defaultCenter] postNotificationName:GXFetchQuestNotComplitedNotification object:nil userInfo:nil];
        }
    }];
    return allResult;
}



#pragma mark - データ操作用

//指定バケットのすべてのデータを取得
- (NSMutableArray *)getAllObject:(KiiBucket *)bucket
{
    NSError *error = nil;
    
    KiiQuery *all_query = [KiiQuery queryWithClause:nil];
    
    NSMutableArray *allResults = [NSMutableArray array];
    
    KiiQuery *nextQuery;
    
    NSArray *results = [bucket executeQuerySynchronous:all_query
                                             withError:&error
                                               andNext:&nextQuery];
    
    [allResults addObjectsFromArray:results];
    
    return allResults;
}

//指定バケットのオブジェクトの名前を
//コンソールに出力(確認用)
- (void)displayAllObject:(KiiBucket *)bucket
{
    
    NSMutableArray *allResults = [self getAllObject:bucket];
    
    for (KiiObject *obj in allResults) {
        NSLog(@"%@",[obj getObjectForKey:quest_title]);
        NSLog(@"%@",[obj getObjectForKey:quest_createUserURI]);
    }
 
}

//指定バケットのすべてのデータを削除
- (void)deleteAllObject:(KiiBucket *)bucket
{
    NSMutableArray *allResults = [self getAllObject:bucket];
    NSError *error = nil;
    for (KiiObject *obj in allResults) {
        [obj deleteSynchronous:&error];
        if (error == nil) {
            NSLog(@"バケット内のすべてのデータを削除");
        } else {
            NSLog(@"%s",__PRETTY_FUNCTION__);
            NSLog(@"error : %@",error);
        }
    }
}


@end