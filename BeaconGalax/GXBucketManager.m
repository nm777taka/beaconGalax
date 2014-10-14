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
        
        //Userスコープ
        self.missionBoard = [[KiiUser currentUser] bucketWithName:@"mission_board"]; //消す
        self.notJoinedQuest = [[KiiUser currentUser] bucketWithName:@"notJoined_quest"];
        self.joinedQuest = [[KiiUser currentUser] bucketWithName:@"joined_quest"];//消す
        self.joinedOnePersonQuest = [[KiiUser currentUser] bucketWithName:@"joined_onePersonQuest"];
        self.joinedMultiPersonQuest = [[KiiUser currentUser] bucketWithName:@"joined_multiPersonQuest"];
        self.myQuestParticipants = [[KiiUser currentUser] bucketWithName:@"myQuest_participants"];
        self.pointBucket = [[KiiUser currentUser] bucketWithName:@"point"];
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

- (void)registerInviteBoard:(KiiObject *)obj
{
    //group作成
    NSError *error;
    NSString *groupName = obj.uuid;
    KiiGroup *group = [KiiGroup groupWithName:groupName];
    [group saveSynchronous:&error];
    
    NSDictionary *dict = obj.dictionaryValue;
    NSArray *allKeys = dict.allKeys;
    KiiObject *newObj = [self.inviteBoard createObject];
    for (NSString *key in allKeys) {
        [newObj setObject:dict[key] forKey:key];
    }
    [newObj setObject:group.objectURI forKey:quest_groupURI];
    
    [newObj saveWithBlock:^(KiiObject *object, NSError *error) {
        //通知とか飛ばす
        NSLog(@"招待完了");
    }];

}

- (void)getInvitedQuest
{
    KiiQuery *query = [KiiQuery queryWithClause:nil];
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
    KiiClause *clause = [KiiClause equals:@"uri" value:[obj getObjectForKey:@"uri"]];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
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
- (void)registerQuestMember:(KiiUser *)user
{
    
}

- (NSMutableArray *)getQuestMembers:(NSArray *)members
{
    NSMutableArray *resutls = [NSMutableArray new];
    for (KiiUser *user in members) {
       KiiObject *obj =  [[GXBucketManager sharedManager] getGalaxUser:user.objectURI];
        
        [resutls addObject:obj];
    }
    
    return resutls;
}

#pragma mark - UserScope

//参加したクエストをnotJoinから消す
- (void)deleteJoinedQuest:(KiiObject *)obj
{
    KiiClause *clause = [KiiClause equals:@"uri" value:[obj getObjectForKey:@"uri"]];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [self.notJoinedQuest executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        KiiObject *deleteObjt = results.firstObject;
        [deleteObjt deleteWithBlock:^(KiiObject *object, NSError *error) {
            if (error) {
                NSLog(@"error:%@",error);
            } else {
                NSLog(@"delete完了");
            }
        }];
    }];
}

//Quest_boardからnot_joinedにフェッチ
//そのうちサーバーコードで実現する
- (void)getQuestForQuestBoard
{
    //全件取得
    NSLog(@"call");
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    
    [self.questBoard executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            NSLog(@"フェッチ完了");
            //resultsからnotJoinedBucketにいれる
            for (KiiObject *obj in results) {
                
                NSDictionary *dict = obj.dictionaryValue;
                NSArray *allKeys = dict.allKeys;
                
                KiiObject *newObj = [self.notJoinedQuest createObject];
                for (NSString *key in allKeys) {
                    [newObj setObject:dict[key] forKey:key];
                }
                
                //object特定用にidを追加
                [newObj setObject:obj.objectURI forKey:@"uri"];
                
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
- (void)registerJoinedQuest:(KiiObject *)obj
{
    KiiObject *newQuest = obj;
    int playerNum = [[newQuest getObjectForKey:quest_player_num] intValue];
    if (playerNum > 1) {
        //マルチ
        NSLog(@"マルチ");
        [self copyObject:self.joinedMultiPersonQuest object:newQuest];
        //tsmessageとかだす
    } else {
        if (playerNum != 0) {
            //一人用
            NSLog(@"ひとり");
            [self copyObject:self.joinedOnePersonQuest object:newQuest];
            //tsmessageとかだす
        }
    }
        

}

//一人用クエストを取得
- (void)getJoinedOnePersonQuest
{
    KiiQuery *query = [KiiQuery queryWithClause:nil];
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
    KiiQuery *query = [KiiQuery queryWithClause:nil];
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

#pragma mark - Mission Method
- (void)fetchMissionWithNotCompleted
{
    NSLog(@"call---fetchmission");
    KiiClause *clause = [KiiClause equals:@"isCompleted" value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [query sortByDesc:@"_created"];
    
    [self.missionBoard executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            //notis
            NSLog(@"misson-count:%d",results.count);
            [[NSNotificationCenter defaultCenter] postNotificationName:GXFetchMissionWithNotCompletedNotification object:results];
        }
    }];
}

#pragma mark - クリア判定
- (BOOL)isClear:(KiiObject *)obj
{
    NSError *error;
    BOOL ret = false;
    int successCnt = [[obj getObjectForKey:quest_success_cnt] intValue];
    successCnt ++;
    
    if ([[obj getObjectForKey:quest_clear_cnt]intValue] == successCnt) {
        //clear
        ret = true;
        [obj setObject:[NSNumber numberWithBool:YES] forKey:quest_isCompleted];
        [obj setObject:[NSNumber numberWithInt:successCnt] forKey:quest_success_cnt];
        [obj saveSynchronous:&error];
        
        if (error) {
            NSLog(@"error:%@",error);
        }
        
        
    } else {
        ret = false;
    }
    
    return ret;
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