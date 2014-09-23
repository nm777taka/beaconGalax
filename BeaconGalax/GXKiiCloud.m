//
//  GXKiiCloud.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXKiiCloud.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXTopicManager.h"
#import "GXUserManager.h"
#import "GXFacebook.h"

@implementation GXKiiCloud

+ (GXKiiCloud *)sharedManager
{
    static GXKiiCloud *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXKiiCloud alloc]initSharedInstance];
    });
    
    return sharedSingleton;
    
}

- (id)initSharedInstance
{
    self = [super init];
    
    if (self) {
        //init
        
    }
    
    return self;
}

#pragma mark - KiiCloud
- (void)kiiCloudLogin
{
    [KiiSocialConnect setupNetwork:kiiSCNFacebook withKey:@"559613677480642" andSecret:nil andOptions:nil];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSArray arrayWithObject:@"email"],@"permissions", nil];
    
    [KiiSocialConnect logIn:kiiSCNFacebook usingOptions:options withDelegate:self andCallback:@selector(loginFinished:usingNetwork:withError:)];
    
}

- (void)loginFinished:(KiiUser *)user usingNetwork:(KiiSocialNetworkName)network withError:(NSError *)error {
    
    if (error == nil) {
        
        //初回ログイン時か調べる（サインアップorサインイン)
        
        KiiBucket *bucket = [GXBucketManager sharedManager].galaxUser;
        NSError *erorr = nil;
        KiiClause *clause = [KiiClause equals:@"uri" value:user.objectURI];
        KiiQuery *query = [KiiQuery queryWithClause:clause];
        NSMutableArray *allResult = [NSMutableArray new];
        KiiQuery *nextQuery;
        
        NSArray *results = [bucket executeQuerySynchronous:query withError:&erorr andNext:&nextQuery];
        
        [allResult addObjectsFromArray:results];
        
        if (allResult.count == 0) { //サインアップ
            NSLog(@"signUp!!");
            
            //ユーザ登録
            [[GXBucketManager sharedManager] registerGalaxUser:user];
            //ユーザ領域にトピックを作成
            [[GXTopicManager sharedManager] createDefaultUserTopic];
            
            
        } else {
            NSLog(@"login");
            
            //バケット購読処理
            //購読の確認
            KiiBucket *bucket = [Kii bucketWithName:@"quest_board"];
            BOOL isSubscribed = [KiiPushSubscription checkSubscriptionSynchronous:bucket withError:&error];
            if (isSubscribed) {
                NSLog(@"quest_boardバケット購読済み");
            } else {
                //購読処理
                [KiiPushSubscription subscribeSynchronous:bucket withError:&error];
                if (error != nil) {
                    NSLog(@"error:%@",error);
                } else {
                    NSLog(@"quest_boardバケット購読完了");
                }
            }
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GXLoginSuccessedNotification object:nil];
        
    } else {
        NSLog(@"error : %@",error);
    }
}

@end
