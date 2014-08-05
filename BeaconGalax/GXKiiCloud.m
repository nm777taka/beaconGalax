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
        
        NSDictionary *dict = [KiiSocialConnect getAccessTokenDictionaryForNetwork:kiiSCNFacebook];
        NSLog(@"%@",dict);
        
        //AFnetworkingでユーザの情報をとってくる
        NSString *api_url = [NSString stringWithFormat:@"https://graph.facebook.com/me?access_token=%@",[dict objectForKey:@"access_token"]];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager GET:api_url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //成功
            NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error:%@",error);
        }];
        
        KiiBucket *bucket = [GXBucketManager sharedManager].galaxUser;
        NSError *erorr = nil;
        KiiClause *clause = [KiiClause equals:@"uri" value:user.objectURI];
        KiiQuery *query = [KiiQuery queryWithClause:clause];
        NSMutableArray *allResult = [NSMutableArray new];
        KiiQuery *nextQuery;
        
        NSArray *results = [bucket executeQuerySynchronous:query withError:&erorr andNext:&nextQuery];
        
        [allResult addObjectsFromArray:results];
        
        if (allResult.count == 0) {
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
        
        //push通知
        [Kii enableAPNSWithDevelopmentMode:TRUE andNotificationTypes:UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeBadge];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GXLoginSuccessedNotification object:nil];
        
    } else {
        NSLog(@"error : %@",error);
    }
}

@end
