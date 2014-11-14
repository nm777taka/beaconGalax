//
//  GXAcivityManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXAcivityManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"


@implementation GXAcivityManager

+ (GXAcivityManager *)sharedManager
{
    static GXAcivityManager *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXAcivityManager alloc] initSharedSingleton];
    });
    
    return sharedSingleton;
}

- (id)initSharedSingleton
{
    self = [super init];
    
    if (self) {
        //init
        self.activityBucket = [Kii bucketWithName:@"activity"];
    }
    
    return self;
}

#pragma mark - API
#pragma mark - データ取得
- (void)getActivity
{
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByAsc:@"_created"];
    [query setLimit:10];
    [self.activityBucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        //
    }];
}

#pragma - クエスト関連
//クエスト作成
- (void)questCreated:(KiiObject *)quest
{
    NSString *activeUser = [[GXUserManager sharedManager].gxUser getObjectForKey:user_name];
    NSString *questName = [quest getObjectForKey:quest_title];
    NSString *message = [NSString stringWithFormat:@"%@が%@クエストを作成しました",activeUser,questName];
    
    KiiObject *obj = [self.activityBucket createObject];
    [obj setObject:message forKey:@"msg"];
    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
        //
    }];
    
}

//クエスト参加
- (void)joinedQuest:(KiiObject *)obj
{
    NSString *questTitle = [obj getObjectForKey:quest_title];
    NSString *activeUser = [[GXUserManager sharedManager].gxUser getObjectForKey:user_name];
    NSString *message = [NSString stringWithFormat:@"%@が%@クエストに参加しました",activeUser,questTitle];
    KiiObject *newObj = [self.activityBucket createObject];
    [newObj setObject:message forKey:@"msg"];
    [newObj saveWithBlock:^(KiiObject *object, NSError *error) {
        //
    }];
}

//クエスト達成
- (void)clearedQuest:(KiiObject *)obj
{
    NSString *questTitle = [obj getObjectForKey:quest_title];
    NSString *activeUser = [[GXUserManager sharedManager].gxUser getObjectForKey:user_name];
    NSString *message = [NSString stringWithFormat:@"%@が%@クエストを達成しました",activeUser,questTitle];
    KiiObject *newObj = [self.activityBucket createObject];
    [newObj setObject:message forKey:@"msg"];
    [newObj saveWithBlock:^(KiiObject *object, NSError *error) {
        //
    }];
}

#pragma mark - ユーザ関連
//レベルアップ
- (void)levelUP
{
    
}


@end
