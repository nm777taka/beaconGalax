//
//  GXEventManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/06.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import "GXEventManager.h"
#import "GXBucketManager.h"

#import "GXDictonaryKeys.h"

@implementation GXEventManager

+ (instancetype)sharedInstance
{
    static GXEventManager *sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXEventManager alloc] initSharedSingleton];
    });
    
    return sharedSingleton;
}

- (id)initSharedSingleton
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

- (void)currentEventCommit
{
    KiiBucket *bucket = [Kii bucketWithName:@"Event"];
    KiiClause *clause = [KiiClause equals:@"isCompleted" value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            KiiObject *obj = results.firstObject;
            
            //クエストカウントを増やす
            int commitCount = [[obj getObjectForKey:@"clear_cnt"] intValue];
            if (commitCount < 100) {
                commitCount++;
            }
            [obj setObject:[NSNumber numberWithInt:commitCount] forKey:@"clear_cnt"];
            [obj saveWithBlock:^(KiiObject *object, NSError *error) {
                if (!error) {
                    //[self registerCommiterUser];
                }
            }];
            
        }
    }];
}

- (void)registerCommiterUser:(BOOL)isOwner type:(NSString *)cleardType
{
    int getPoint = 0;
    
    if ([cleardType isEqualToString:@"system"]) {
        getPoint = 20;
    } else {
        
        if (isOwner) {
            getPoint = 100;
        } else {
            getPoint = 60;
        }
    }
    
    KiiBucket *bucket = [Kii bucketWithName:@"Event"];
    KiiClause *clause = [KiiClause equals:@"name" value:[KiiUser currentUser].displayName];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            if (results.count == 0) {
                //firstCommit
                KiiObject *obj = [bucket createObject];
                KiiObject *gxuser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
               
                [obj setObject:[KiiUser currentUser].displayName forKey:user_name];
                [obj setObject:[gxuser getObjectForKey:user_fb_id] forKey:user_fb_id];
                [obj setObject:[NSNumber numberWithInt:getPoint] forKey:@"event_point"];
                
                [obj saveWithBlock:^(KiiObject *object, NSError *error) {
                    
                }];
                
            } else {
                //commit
                KiiObject *obj = results.firstObject;
                int eventPoint = [[obj getObjectForKey:@"event_point"]intValue];
                eventPoint+= getPoint;
                
                [obj setObject:[NSNumber numberWithInt:eventPoint] forKey:@"event_point"];
                [obj saveWithBlock:^(KiiObject *object, NSError *error) {
                    if (!error) {
                        
                    }
                }];
            }
        }
    }];
}

- (void)registerSystemQuestCleard
{
    
    

}

@end
