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
#import "GXActivityList.h"
#import "GXNotification.h"
#import "GXFacebook.h"
#import "GXDictonaryKeys.h"
#import "GXExeQuestManager.h"

#define GXQUEST_TYPE_ONE 1
#define GXQUEST_TYPE_MULTI 2

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
        //Appスコープ
        self.galaxUser = [Kii bucketWithName:@"galax_user"];
        self.questBoard = [Kii bucketWithName:@"quest_board"];
        self.inviteBoard = [Kii bucketWithName:@"invite_board"];
        self.activityBucket = [Kii bucketWithName:@"activity"];
        self.user_beacons = [Kii bucketWithName:@"user_beacons"];
        
        //Userスコープ
        self.notJoinedQuest = [[KiiUser currentUser] bucketWithName:@"notJoined_quest"];
        self.joinedQuest = [[KiiUser currentUser] bucketWithName:@"joined_quest"];//消す
        self.joinedOnePersonQuest = [[KiiUser currentUser] bucketWithName:@"joined_onePersonQuest"];
        self.joinedMultiPersonQuest = [[KiiUser currentUser] bucketWithName:@"joined_multiPersonQuest"];
        
        self.pointBucket = [[KiiUser currentUser] bucketWithName:@"point"];
        self.clearedBucket = [[KiiUser currentUser] bucketWithName:@"cleard"];
        self.notis_questDeliver = [[KiiUser currentUser] bucketWithName:@"notis_questDeliver"];
    }
    
    return self;
}

#pragma mark - AppScope

- (void)registerGalaxUser:(KiiUser *)user
{
    
    [[GXFacebook sharedManager] initGxUserWithFacebook:user];
    
//    KiiObject *object = [self.galaxUser createObject];
//    [object setObject:user.uuid forKey:@"userID"];
//    [object setObject:user.objectURI forKey:@"uri"];
//    [object setObject:@YES forKey:@"isMember"];
//    [object setObject:[NSNumber numberWithInt:1] forKey:@"rank"];    
//    
//    NSError *error = nil;
//    [object saveSynchronous:&error];
//    
//    if (error != nil) {
//        NSLog(@"error:%@",error);
//    } else {
//        NSLog(@"ギャラックスユーザバケットへ登録完了");
//        [[GXFacebook sharedManager] getUserFacebookID];
//    }

}

- (KiiObject *)getGalaxUser:(NSString *)userURI
{
    NSError *error;
    KiiClause *clause = [KiiClause equals:@"uri" value:userURI];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    KiiQuery *nextQuery;
  NSArray *result  = [self.galaxUser executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    
    if (result.count == 1) {
        return result.firstObject;
    }
    
    return nil;
}

/*クエストに含める要素
 タイトル:
 詳細:
 報酬:
 制約:
 タイプ:
 lv:
 */
- (void)registerQuest:(GXQuest *)quest
{
    KiiObject *object = [self.questBoard createObject];
    [object setObject:quest.title forKey:quest_title];
    [object setObject:quest.description forKey:quest_description];
    [object setObject:quest.createUserURI forKey:quest_createUserURI];
    [object setObject:quest.fb_id forKey:quest_createdUser_fbid];
    [object setObject:quest.group_uri forKey:quest_groupURI];
    [object setObject:quest.isStarted forKey:quest_isStarted];
    [object setObject:quest.isCompleted forKey:quest_isCompleted];
    [object setObject:quest.createdUserName forKey:quest_createdUserName];
    
    NSError *error  = nil;
    [object saveSynchronous:&error];
    
    if (error != nil) {
        NSLog(@"error : %@",error);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestCreatedNotification object:nil];
    }
}

- (void)registerInviteBoard:(KiiObject *)obj //obj → not_joinedBucket
{
    //group作成
    NSError *error;
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *groupName = uuid;
    KiiGroup *group = [KiiGroup groupWithName:groupName];
    [group saveSynchronous:&error];
    if (error) {
        NSLog(@"error:%@",error);
    } else {
        NSLog(@"グループ作成");
    }
    
    //Groupのmemberバケットに自分を登録
    KiiObject *ownerUser =  [self getGalaxUser:[KiiUser currentUser].objectURI];
    KiiBucket *bucket = [group bucketWithName:@"member"];
    KiiObject *newMember = [bucket createObject];
    [newMember setObject:[ownerUser getObjectForKey:user_fb_id] forKey:user_fb_id];
    [newMember setObject:[ownerUser getObjectForKey:user_name] forKey:user_name];
    [newMember setObject:[ownerUser getObjectForKey:user_uri] forKey:user_uri];
    [newMember setObject:@YES forKey:user_isOwner];
    [newMember saveWithBlock:^(KiiObject *object, NSError *error) {
        
        //member参加を知るためにsubscribe
        [KiiPushSubscription subscribe:bucket withBlock:^(KiiPushSubscription *subscription, NSError *error) {
            if (error == nil) {
            }
        }];
    }];
    
    
    //グループtopicを作成(みんなで購読する)
    KiiTopic *groupTopic = [group topicWithName:@"quest_start"];
    [groupTopic saveWithBlock:^(KiiTopic *topic, NSError *error) {
        if (!error) {
            NSLog(@"トピック作成完了");
            [KiiPushSubscription subscribe:groupTopic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
                if (error == nil) {
                    NSLog(@"startTopic購読");
                }
            }];
        }

    }];
    
    //募集用クエスト
    NSDictionary *dict = obj.dictionaryValue;
    NSArray *allKeys = dict.allKeys;
    KiiObject *newObj = [self.inviteBoard createObject]; //募集掲示板のやつ
    
    for (NSString *key in allKeys) {
        [newObj setObject:dict[key] forKey:key];
    }
    [newObj setObject:group.objectURI forKey:quest_groupURI];
    [newObj setObject:[ownerUser getObjectForKey:user_fb_id] forKey:quest_owner_fbid];
    [newObj setObject:[ownerUser getObjectForKey:user_name] forKey:quest_owner];
    
    [newObj saveWithBlock:^(KiiObject *object, NSError *error) {
        
        //グループに入れとく
        KiiBucket *groupQuestBucket = [group bucketWithName:@"quest"];
        KiiObject *groupQuest = [groupQuestBucket createObject]; //groupにいれる
        for (NSString *key in allKeys) {
            [groupQuest setObject:dict[key] forKey:key];
        }
        [groupQuest setObject:group.objectURI forKey:quest_groupURI];
        [groupQuest setObject:[ownerUser getObjectForKey:user_fb_id] forKey:quest_owner_fbid];
        [groupQuest setObject:[ownerUser getObjectForKey:user_name] forKey:quest_owner];

        [groupQuest saveWithBlock:^(KiiObject *object, NSError *error) {
            
        }];
        
        CWStatusBarNotification *notis = [CWStatusBarNotification new];
        [notis displayNotificationWithMessage:@"クエスト募集完了" forDuration:2.0f];
        
        //activity
        KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
        NSString *questName = [newObj getObjectForKey:quest_title];
        NSString *text = [NSString stringWithFormat:@"%@クエストを募集しました",questName];
        [[GXActivityList sharedInstance] registerQuestActivity:[gxUser getObjectForKey:user_name] title:text fbid:[gxUser getObjectForKey:user_fb_id]];
        
        //[[NSNotificationCenter defaultCenter ] postNotificationName:GXRegisteredInvitedBoardNotification object:nil];

    }];
    
    
    KiiBucket *clearJudgeBucket = [group bucketWithName:@"clear_judge"];
    KiiObject *judgment= [clearJudgeBucket createObject];
    [judgment setObject:@NO forKey:@"isClear"];
    [judgment saveWithBlock:^(KiiObject *object, NSError *error) {
        
        //bucketを購読
        [KiiPushSubscription subscribe:clearJudgeBucket withBlock:^(KiiPushSubscription *subscription, NSError *error) {
            if (error == nil) {
            }
        }];
    }];
    
}

- (void)getInvitedQuest
{
    KiiClause *clause = [KiiClause equals:quest_isCompleted value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [self.inviteBoard executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GXInvitedQuestFetchedNotification object:results];
        }
        
    }];
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

//クエストがすでに募集済みかどうかチェック
- (BOOL)isInvitedQuest:(KiiObject *)obj
{
    BOOL ret = false;
    KiiClause *clause1 = [KiiClause equals:@"id" value:[obj getObjectForKey:@"id"]];
    KiiClause *clause2 = [KiiClause equals:quest_isCompleted value:@NO];
    KiiClause *totalClause = [KiiClause andClauses:@[clause1,clause2]];
    KiiQuery *query = [KiiQuery queryWithClause:totalClause];
    KiiQuery *nextQuery;
    NSError *error;
    NSArray *result = [self.inviteBoard executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    if (result.count != 0) ret = true;
    else ret = false;
    
    return ret;
    
}

- (void)questStart:(KiiGroup *)groupURI
{
    KiiClause *clause = [KiiClause equals:quest_groupURI value:groupURI];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [self.questBoard executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        KiiObject *object = results.firstObject;
        [object refreshWithBlock:^(KiiObject *object, NSError *error) {
            
            [object setObject:@YES forKey:quest_isStarted];
            
            [object saveWithBlock:^(KiiObject *object, NSError *error) {
                if (!error) {
                    //クエスト開始に更新
                    NSLog(@"クエスト開始処理に更新");
                }
            }];
        }];
    }];
}

//自分がオーナーのクエストを返す
- (void)getOwnerQuest
{
    NSString *ownerURI = [KiiUser currentUser].objectURI;
    KiiClause *clause = [KiiClause equals:quest_createUserURI value:ownerURI];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [self.questBoard executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GXFetchQuestWithOwnerNotification object:results];
        
    }];
}


#pragma mark - GroupScope
- (void)getQuestMember:(KiiGroup *)group
{
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    KiiBucket *groupBucket = [group bucketWithName:@"member"];
    [groupBucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) NSLog(@"error:%@",error);
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:GXGroupMemberFetchedNotification object:results];
    }];
}

- (KiiObject *)getGroupQuest:(KiiGroup *)group
{
    //参加したクエストを取得
    NSError *error = nil;
    KiiBucket *bucket = [group bucketWithName:@"quest"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    KiiQuery *nextQuery;
    NSArray *results = [bucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    KiiObject *obj = results.firstObject;
    
    return obj;

}

#pragma mark - UserScope

//参加したクエストをnotJoinBucketから消す
- (void)deleteJoinedQuest:(KiiObject *)obj
{
    [obj deleteWithBlock:^(KiiObject *object, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteQuest" object:nil];
        }
    }];
}

- (void)registerJoinedMultiQuest:(KiiObject *)obj
{
    NSError *error;
    NSDictionary *dict = obj.dictionaryValue;
    NSArray *allKeys = dict.allKeys;
    KiiObject *newObj = [self.joinedMultiPersonQuest createObject];
    for (NSString *key in allKeys) {
        [newObj setObject:dict[key] forKey:key];
    }
    
    [newObj saveSynchronous:&error];
}

//Quest_boardからnot_joinedにフェッチ
//そのうちサーバーコードで実現する
#pragma  mark- ここ修正する!

- (void)getQuestForQuestBoard
{
    //全件取得
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    
    [self.questBoard executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            //resultsからnotJoinedBucketにいれる
            for (KiiObject *obj in results) {
                
                NSDictionary *dict = obj.dictionaryValue;
                NSArray *allKeys = dict.allKeys;
                
                KiiObject *newObj = [self.notJoinedQuest createObject];
                for (NSString *key in allKeys) {
                    [newObj setObject:dict[key] forKey:key];
                }
                [newObj saveWithBlock:^(KiiObject *object, NSError *error) {
                    
                    if (!error) {
                        NSLog(@"quest_board→not_joinedBoard");
                    }
                }];
            }
            [self fetchQuestWithNotComplited];
        }
    }];
}


//参加したクエストを自分スコープのバケットに保存
- (void)registerJoinedQuest:(KiiObject *)obj // obj → quest_group
{
    KiiObject *newQuest = obj;
    int playerNum = [[newQuest getObjectForKey:quest_player_num] intValue];
    if (playerNum > 1) {
        //マルチ
        NSLog(@"マルチ");
        NSDictionary *dict = obj.dictionaryValue;
        NSArray *allKeys = dict.allKeys;
        
        KiiObject *newObj = [self.joinedMultiPersonQuest createObject];
        for (NSString *key in allKeys) {
            [newObj setObject:dict[key] forKey:key];
        }
        [newObj saveWithBlock:^(KiiObject *object, NSError *error) {
            
        }];
        
        
    } else {
        if (playerNum != 0) {
            //一人用
            NSLog(@"ひとり");
            NSDictionary *dict = obj.dictionaryValue;
            NSArray *allKeys = dict.allKeys;
            KiiObject *newObj = [self.joinedOnePersonQuest createObject];
            for (NSString *key in allKeys) {
                [newObj setObject:dict[key] forKey:key];
            }
            [newObj setObject:obj.objectURI forKey:@"id"];
            [newObj saveWithBlock:^(KiiObject *object, NSError *error) {
                
                CWStatusBarNotification *notis = [CWStatusBarNotification new];
                notis.notificationStyle = CWNotificationStyleNavigationBarNotification;
                [notis displayNotificationWithMessage:@"クエスト受注" forDuration:2.0f];
                
            }];
        }
    }
        

}

//一人用クエストを取得
- (void)getJoinedOnePersonQuest
{
    KiiClause *clause = [KiiClause equals:@"isCompleted" value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [query sortByDesc:@"_created"];
    [self.joinedOnePersonQuest executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            NSLog(@"一人用クエストフェッチ完了");
            [[NSNotificationCenter defaultCenter] postNotificationName:GXJoinedQuestFetchedNotification object:results];
            
        }
        
    }];
}

//マルチ用クエストを取得
- (void)getJoinedMultiPersonQuest
{
    KiiClause *clause = [KiiClause equals:quest_isCompleted value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [self.joinedMultiPersonQuest executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            NSLog(@"マルチ用クエストフェッチ");
            [[NSNotificationCenter defaultCenter] postNotificationName:GXJoinedQuestFetchedNotification object:results];
        }
    }];
}

//objを別バケットのobjに変更
- (void)changeObjectTo:(KiiBucket *)toBucket andOriginObject:(KiiObject *) obj
{
    NSError *error;
    KiiObject *newObj = [toBucket createObject];
    
    NSDictionary *dict = obj.dictionaryValue;
    NSArray *allKeys = dict.allKeys;
    for (NSString *key in allKeys) {
        
        [newObj setObject:[obj getObjectForKey:key] forKey:key];
    }
    
    [newObj saveSynchronous:&error];
    if (error) NSLog(@"error:%@",error);
    else NSLog(@"コピー完了");
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
- (void)fetchQuestWithNotComplited
{
    KiiClause *clause = [KiiClause equals:@"isCompleted" value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [query sortByDesc:@"_created"];
    
    [self.notJoinedQuest executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error :%@",error);
        } else {
            
            //notification
            [[NSNotificationCenter defaultCenter] postNotificationName:GXFetchQuestNotComplitedNotification object:results userInfo:nil];
        }
    }];
}


#pragma mark - データ操作用

- (BOOL)copyObject:(KiiBucket *)toBucket object:(KiiObject *)obj
{
    NSError *error;
    BOOL ret = false;
    NSDictionary *dict = obj.dictionaryValue;
    NSArray *allKeys = dict.allKeys;
    
    KiiObject *newObj = [toBucket createObject];
    for (NSString *key in allKeys) {
        [newObj setObject:dict[key] forKey:key];
    }
    [newObj saveSynchronous:&error];
    
    if (!error) {
        ret = true;
    }else {
        ret = false;
    }
    
    return ret;

}

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