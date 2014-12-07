//
//  GXPointManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/06.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXPointManager.h"
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
- (int)getQuestClearPoint:(KiiObject *)cleardQuest
{
    KiiObject *quest = cleardQuest;
    NSString *type = [quest getObjectForKey:quest_type];
    int retPoint = 0;
    
    if ([type isEqualToString:@"user"]) {
        //これはuserクエスト
        [self refreshPoint:30];
        retPoint = 30;
    } else {
        //one or multi
        int playerNum = [[quest getObjectForKey:quest_player_num] intValue];
        if (playerNum > 1) {
            //協力クエスト
            [self refreshPoint:25];
            retPoint = 25;
        } else {
            //一人用クエスト
            [self refreshPoint:20];
            retPoint = 20;
        }
    }
    
    return retPoint;
}


#pragma mark - Internal
- (void)userQuestClearPoint
{
    NSLog(@"userQuestClearPoint");
    int point = 20;
    [self refreshPoint:point];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getPoint" object:[NSNumber numberWithInt:point]];
    
}

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
                }
            }];
            
            //gxuserにもポイント
            KiiObject *gxusr = [GXUserManager sharedManager].gxUser;
            [gxusr setObject:[NSNumber numberWithInt:curPoint] forKey:@"point"];
            [gxusr saveWithBlock:^(KiiObject *object, NSError *error) {
                
            }];
        }
    }];
    
}

- (void)showAlert:(int)point
{
    CWStatusBarNotification *notis = [CWStatusBarNotification new];
    notis.notificationLabelBackgroundColor = [UIColor sunflowerColor];
    NSString *msg = [NSString stringWithFormat:@"%d ゲット！",point];
    [notis displayNotificationWithMessage:msg forDuration:5.0f];
}


@end
