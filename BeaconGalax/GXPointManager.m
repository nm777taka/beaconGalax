//
//  GXPointManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/06.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXPointManager.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"
#import <CWStatusBarNotification.h>

@implementation GXPointManager

+ (GXPointManager *)sharedInstance
{
    static GXPointManager *sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXPointManager alloc] initSingleton];
    });
    
    return sharedSingleton;
    
}

- (id)initSingleton
{
    self = [super init];
    if (self) {
        //init
        self.userPointBucket = [[KiiUser currentUser] bucketWithName:@"point"];
        NSNumber *initPoint = @0;
        KiiObject *initObj = [self.userPointBucket createObject];
        [initObj setObject:initPoint forKey:@"point"];
        [initObj saveWithBlock:^(KiiObject *object, NSError *error) {
            
        }];
    }
    
    return self;
}

#pragma makr Action Reward
//クエスト作成したら
//1pt配布
- (void)getCreateQuestPoint
{
    [self refreshPoint:5];
}

//クエスト招待したら
//1pt配布
- (void)getInviteQuestPoint
{
    [self refreshPoint:3];
}

- (int)getCurrentPoint
{
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    NSError *error;
    KiiQuery *nextQuery;
    NSArray *results = [self.userPointBucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    KiiObject *obj = results.firstObject;
    NSLog(@"obj:%@",obj);
    int point = [[obj getObjectForKey:@"point"] intValue];
    NSLog(@"point:%d",point);
    return point;
}

//クエストクリア時のポイント配布メソッド
//クエストタイプ判定 + ポイント登録
//return : ゲットしたポイント(viewcontrollerで表示するため)
- (float)getQuestClearPoint:(KiiObject *)cleardQuest
{
    KiiObject *quest = cleardQuest;
    NSString *type = [quest getObjectForKey:quest_type];
    float retPoint = 0.0f;
    NSError *error;
    
    if ([type isEqualToString:@"user"]) {
        //これはuserクエスト
        //[self refreshPoint:30];
        NSString *groupURI = [cleardQuest getObjectForKey:quest_groupURI];
        KiiGroup *group = [KiiGroup groupWithURI:groupURI];
        [group refreshSynchronous:&error];
        NSArray *members = [group getMemberListSynchronous:&error];
        retPoint = (members.count * 10) + 25; //人数ボーナス＋基本ポイント
        
    } else {
        //one or multi
        int playerNum = [[quest getObjectForKey:quest_player_num] intValue];
        if (playerNum > 1) {
            //協力クエスト
           // [self refreshPoint:25];
            //グループメンバを取得
            NSString *groupURI = [cleardQuest getObjectForKey:quest_groupURI];
            KiiGroup *group = [KiiGroup groupWithURI:groupURI];
            [group refreshSynchronous:&error];
            NSArray *members = [group getMemberListSynchronous:&error];
            retPoint = (members.count * 10) + 20; //人数ボーナス＋基本ポイント
        } else {
            //一人用クエスト
           // [self refreshPoint:20];
            retPoint = 20;
        }
    }
    
    return retPoint;
}


- (NSDictionary *)checkNextRank
{
    int currentPoint = [self getCurrentPoint];
    NSDictionary *retDict;
    NSError *error;
    KiiClause *clause = [KiiClause greaterThan:@"point" value:[NSNumber numberWithInt:currentPoint]];
    KiiQuery *nextRankQuery = [KiiQuery queryWithClause:clause];
    KiiQuery *nextQuery;
    [nextRankQuery sortByAsc:@"point"];
    KiiBucket *rankBucket = [GXBucketManager sharedManager].rank_bucket;
    NSArray *results =  [rankBucket executeQuerySynchronous:nextRankQuery withError:&error andNext:&nextQuery];
    if (error) {
        //カンスト？
    } else {
        KiiObject *firstObj = results.firstObject;
        NSString *nextRank = [firstObj getObjectForKey:@"rank"];
        NSLog(@"checkNextRank:%@",nextRank);
        NSNumber *nextReqPoint = [firstObj getObjectForKey:@"point"];
        retDict = @{@"nextRank":nextRank,@"nextPoint":nextReqPoint};
    }
    
    return retDict;
}

#pragma mark - Internal
- (void)userQuestClearPoint
{
    NSLog(@"userQuestClearPoint");
    int point = 20;
    [self refreshPoint:point];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getPoint" object:[NSNumber numberWithInt:point]];
    
}

//取得したポイントを反映させる
- (void)refreshPoint:(int)point
{
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [self.userPointBucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            [self showAlert:point];
            KiiObject *obj = results.firstObject;
            int curPoint = [[obj getObjectForKey:@"point"] intValue];
            curPoint += point;
            
            [obj setObject:[NSNumber numberWithInt:curPoint] forKey:@"point"];
            [obj saveWithBlock:^(KiiObject *object, NSError *error) {
                if (!error) {
                    //ここでチェックいれる
                    [self checkRank:curPoint];
                }
            }];
            
            //gxuserにもポイントを反映させる
            KiiObject *gxusr = [GXUserManager sharedManager].gxUser;
            [gxusr setObject:[NSNumber numberWithInt:curPoint] forKey:@"point"];
            [gxusr saveWithBlock:^(KiiObject *object, NSError *error) {
                
            }];
        }
    }];
    
}

//ポイントに応じたランク設定とランクアップ処理
- (void)checkRank:(int)point
{
    int currentPoint = point;
    NSLog(@"chekcRank");
    NSLog(@"currntPoint:%d",currentPoint);
    //次のランクを現在の所持ポイントから取得する
    
    KiiClause *clause = [KiiClause lessThanOrEqual:@"point" value:[NSNumber numberWithInt:currentPoint]];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [query sortByAsc:@"point"];
    KiiBucket *bucket = [GXBucketManager sharedManager].rank_bucket;
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        //ポイントから算出したランク
        KiiObject *firstObj = results.lastObject;
        NSString *gotRank = [firstObj getObjectForKey:@"rank"];
        
        //まだユーザのランクは確定してない(ランクアップ前)
        KiiObject *gxuser = [GXUserManager sharedManager].gxUser;
        NSString *gxuserRank = [gxuser getObjectForKey:@"rank"];
        NSLog(@"gotRank:%@",gotRank);
        if ([gxuserRank isEqualToString:gotRank]) {
            //特になにもしない
        } else {
            //ランクアップが必要
            NSLog(@"rankUP!!");
            [gxuser setObject:gotRank forKey:@"rank"];
            [gxuser saveWithBlock:^(KiiObject *object, NSError *error) {
                if (!error) {

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"rankUp" object:gotRank];
                    
                    CWStatusBarNotification *notis = [CWStatusBarNotification new];
                    notis.notificationLabelBackgroundColor = [UIColor sunflowerColor];
                    notis.notificationStyle = CWNotificationStyleNavigationBarNotification;
                    NSString *msg = [NSString stringWithFormat:@"%@ランクになりました！",gotRank];
                    [notis displayNotificationWithMessage:msg forDuration:2.0f];
                } else {
                    NSLog(@"RankSettingError:%@",error);
                }
            }];
        }
        
    }];
}

- (void)showAlert:(int)point
{
    CWStatusBarNotification *notis = [CWStatusBarNotification new];
    notis.notificationLabelBackgroundColor = [UIColor sunflowerColor];
    NSString *msg = [NSString stringWithFormat:@"%d ゲット！",point];
    [notis displayNotificationWithMessage:msg forDuration:3.0f];
}


@end
