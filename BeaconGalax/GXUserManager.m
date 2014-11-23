//
//  GXUserManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/01.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXUserManager.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"

@implementation GXUserManager

+ (GXUserManager *)sharedManager
{
    static GXUserManager *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXUserManager alloc]initSharedInstance];
    });
    
    return sharedSingleton;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        //init
        self.gxUser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
    }
    
    return self;
}



- (int)getUserPoint
{
    int ret = 0;
    KiiBucket *pointBuket = [[KiiUser currentUser] bucketWithName:@"point"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    NSError *error;
    KiiQuery *nxQuery;
    NSArray *results = [pointBuket executeQuerySynchronous:query withError:&error andNext:&nxQuery];
    if (results.firstObject != nil) {
        KiiObject *pointObj = results.firstObject;
        ret = [[pointObj getObjectForKey:@"point"] intValue];
    } else {
        ret = 0;
    }
    
    
    return ret;
}

- (int)getUserRank
{
    int currRank = [[self.gxUser getObjectForKey:@"rank"] intValue];
    return currRank;
}


@end
