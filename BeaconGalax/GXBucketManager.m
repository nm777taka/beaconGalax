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
    
    NSError *error = nil;
    [object saveSynchronous:&error];
    
    if (error != nil) {
        NSLog(@"error:%@",error);
    } else {
        NSLog(@"ギャラックスユーザバケットへ登録完了");
    }

}

@end