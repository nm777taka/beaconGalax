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

@implementation GXBucketManager

+ (GXBucketManager *)sharedMager
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
        self.nearUser = [Kii bucketWithName:@"near_user"];
        
    }
    
    return self;
}

//ApplicationBucket

- (void)registerGalaxUser:(KiiUser *)user
{
    
//    KiiClause *clause = [KiiClause equals:@"email" value:user.email];
//    KiiQuery *query = [KiiQuery queryWithClause:clause];
    
    KiiObject *object = [self.galaxUser createObject];
    
    [object setObject:user.username forKey:@"name"];
    [object setObject:user.email forKey:@"email"];
    [object setObject:user.objectURI forKey:@"uri"];
    [object setObject:@YES forKey:@"isNear"];
    [object setObject:@YES forKey:@"iSMember"];
    
    NSError *error = nil;
    [object saveSynchronous:&error];
    
    if (error != nil) {
        NSLog(@"error:%@",error);
    } else {
        NSLog(@"ギャラックスユーザバケットへ登録完了");
    }

}

//UserBucket
- (void)registerNearUser:(KiiUser *)user
{
    //ApplicatiaonBucketからparam=nearのやつをひっぱってくる
    //ユーザ（自分)はのぞく(まだ実装してない)
    NSError *error = nil;
    KiiClause *clause1 = [KiiClause equals:@"isNear" value:@YES];
    KiiClause *clause2 = [KiiClause notEquals:@"email" value:user.email];
    KiiClause *totalClause = [KiiClause and:clause1,clause2,nil];

    KiiQuery *query = [KiiQuery queryWithClause:totalClause];
    NSMutableArray *allResults = [NSMutableArray new];
    KiiQuery *nextQuery;
    
    NSArray *results = [self.galaxUser executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    
    [allResults addObjectsFromArray:results];
    
    NSLog(@"registerdUser : %d",allResults.count);
    
    for (KiiObject *obj in allResults) {
        KiiObject *newObj = [self.nearUser createObject];
        
    }
    
    
    
}

- (KiiObject *)getMeFromAppBucket:(KiiUser *)user
{
    NSError *error = nil;
    
    KiiClause *clause = [KiiClause equals:@"email" value:user.email];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    NSMutableArray *allResults = [NSMutableArray new];
    KiiQuery *nextQuery;
    
    NSArray *results = [self.galaxUser executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    
    [allResults addObjectsFromArray:results];
    if (allResults.count == 1) {
        
        KiiObject *obj = allResults.firstObject;
        return obj;
    }
    
    return nil;
}

@end