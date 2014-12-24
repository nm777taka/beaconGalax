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
#import "GXDictonaryKeys.h"
#import "GXFacebook.h"
#import "GXUserDefaults.h"

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
        
        [KiiPushInstallation installSynchronous:&error];
        
        if (error != nil) {
            NSLog(@"push install error:%@",error);
        } else {
            NSLog(@"push install!!");
        }
        
        if ([GXUserDefaults isFirstLaunch]) {
            [[GXFacebook sharedManager] initGxUserWithFacebook:user];
            //Topic初期化
            [[GXTopicManager sharedManager] createDefaultUserTopic];
            [[GXTopicManager sharedManager] subscribeInfoTopic];
            [[GXTopicManager sharedManager] setACL];
            
            //accesstokenの保存
            NSString *accessToken = [user accessToken];
            [GXUserDefaults setAccessToken:accessToken];
            
            //userdefaultに保存する(基本的なuser情報)
            KiiObject *gxuser = [[GXBucketManager sharedManager] getMeFromGalaxUserBucket];
            [GXUserDefaults setUserInfomation:[gxuser getObjectForKey:user_fb_id] name:[gxuser getObjectForKey:user_name]];
            
            [self createFirstQuest:user];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GXLoginSuccessedNotification object:nil];
            
        } else {
            
        }

    } else {
        NSLog(@"error : %@",error);
    }
}

- (void)createFirstQuest:(KiiUser *)user
{
    NSError *error;
    KiiBucket *bucket = [user bucketWithName:@"notJoined_quest"];
    //一人用
    KiiObject *newQuest1 = [bucket createObject];
    [newQuest1 setObject:@"最初のクエスト" forKey:@"title"];
    [newQuest1 setObject:@"研究室のビーコンに近づいてみよう" forKey:@"description"];
    [newQuest1 setObject:@"クリア条件:研究室のビーコンに一定時間近づく" forKey:@"requirement"];
    [newQuest1 setObject:@28319 forKey:@"major"];
    [newQuest1 setObject:@1 forKey:@"player_num"];
    [newQuest1 setObject:@NO forKey:@"isCompleted"];
    [newQuest1 setObject:@0 forKey:@"success_cnt"];
    [newQuest1 saveSynchronous:&error];
    if (error) NSLog(@"init quest error:%@",error);
    else NSLog(@"newQuest1 suc");
    
    //協力クエスト
    KiiObject *newQuest2 = [bucket createObject];
    [newQuest2 setObject:@"はじめての協力" forKey:@"title"];
    [newQuest2 setObject:@"メンバーと一緒にクエストをやってみよう" forKey:@"description"];
    [newQuest2 setObject:@"クリア条件：研究室のビーコンに一定時間近づく" forKey:@"requirement"];
    [newQuest2 setObject:@28319 forKey:@"major"];
    [newQuest2 setObject:@2 forKey:@"player_num"];
    [newQuest2 setObject:@NO forKey:@"isCompleted"];
    [newQuest2 setObject:@0 forKey:@"success_cnt"];
    [newQuest2 saveSynchronous:&error];
    if (error) NSLog(@"init quest error:%@",error);
    else NSLog(@"newQuest1 suc");
}

@end
