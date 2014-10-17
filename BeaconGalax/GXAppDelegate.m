//
//  GXAppDelegate.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXAppDelegate.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"

@interface GXAppDelegate()

@property KiiUser *joinUser;
@property KiiGroup *joinedGroup;
@property CLLocationManager *locationManager;

@end

@implementation GXAppDelegate{
    NSString *groupURI;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //kiiCloudの設定
    [Kii beginWithID:@"89c1cddc" andKey:@"b84c451265c396ea57d3eb50784cc29a" andSite:kiiSiteJP];
    
    //kiiCloud - faceboookLogin
    [KiiSocialConnect setupNetwork:kiiSCNFacebook
                           withKey:@"559613677480642"
                         andSecret:nil
                        andOptions:nil];
    
     [Kii enableAPNSWithDevelopmentMode:YES andNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
   
    return YES;
}


//シングルサインオンの有効
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    return [KiiSocialConnect handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"device token :%@",deviceToken);
    [Kii setAPNSDeviceToken:deviceToken];
    NSError *error = nil;
    
    [KiiPushInstallation installSynchronous:&error];
    
    if (error != nil) {
        NSLog(@"push install error:%@",error);
    } else {
        NSLog(@"push install!!");
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"register errror:%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    //アプリがフォアグランドで起動している時にPush通知を受信した場合
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"push通知受信@フォアグランド");
        UIAlertController *alertConroller = [UIAlertController alertControllerWithTitle:@"info" message:@"○○をクエストメンバーに追加します" preferredStyle:UIAlertControllerStyleAlert];
        [alertConroller addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self addGroupMember];
            
        }]];
        
        [self.window.rootViewController presentViewController:alertConroller animated:YES completion:nil];


    }
    
    
    //バックグランドからPUSH通知でアクティブになったとき
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"プッシュ通知からアクティブ");
    }
    
    if (application.applicationState == UIApplicationStateBackground) {
        NSLog(@"バックグランドでpushを受信" );
        
        
    }
    
}

//slient push からの backgroundFetch
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if(![userInfo[@"aps"][@"content-available"] intValue])
    {
        NSLog(@"push受信");
        KiiPushMessage *msg = [KiiPushMessage messageFromAPNS:userInfo];
        NSString *topicName = [msg getValueOfKiiMessageField:KiiMessage_TOPIC];
        
        if ([topicName isEqualToString:@"invite_notify"]) {
            NSLog(@"きたよ☆");
            if (application.applicationState == UIApplicationStateActive) {
                NSLog(@"アクティブで受けっとたよ☆");
                //TSMessage表示用
                [[NSNotificationCenter defaultCenter] postNotificationName:GXAddGroupSuccessedNotification object:userInfo[@"group_uri"]];
                
            }
            if (application.applicationState == UIApplicationStateBackground) {
                NSLog(@"後ろで受け取ったよ♪");
                [self pushTest];
            }
        }
        
        if ([topicName isEqualToString:@"quest_start"]) {
            if (application.applicationState == UIApplicationStateActive) {
                NSLog(@"きちゃった☆");
                [[NSNotificationCenter defaultCenter] postNotificationName:GXStartQuestNotification object:nil];
            }
            
        }
        
        completionHandler(UIBackgroundFetchResultNewData);
        return;
    }
    
    //グループ再インスタンス化
    NSError *error;
    KiiUser *joinUser = [KiiUser userWithURI:userInfo[@"join_user"]];
    KiiGroup *questGroup = [KiiGroup groupWithURI:userInfo[@"group"]];
    [questGroup refreshSynchronous:&error];
    
    if (error) {
        NSLog(@"error:%@",error);
    } else {
        NSLog(@"グループリフレッシュ");
        NSLog(@"group:%@",questGroup);
    }
    [questGroup addUser:joinUser];
    [questGroup saveSynchronous:&error];
    
    if (error) {
        NSLog(@"error:%@",error);
        completionHandler(UIBackgroundFetchResultFailed);
    } else {
        NSLog(@"ユーザ追加");
        //追加されたのを知らせる
        KiiBucket *bucket = [questGroup bucketWithName:@"member"];
        KiiObject *newMember = [bucket createObject];
        //kiiuser情報からgxUserを取得
        KiiObject *gxUser = [[GXBucketManager sharedManager] getGalaxUser:joinUser.objectURI];
        [newMember setObject:[gxUser getObjectForKey:user_fb_id] forKey:user_fb_id];
        [newMember setObject:[gxUser getObjectForKey:user_name] forKey:user_name];
        [newMember setObject:[gxUser getObjectForKey:user_uri] forKey:user_uri];
        [newMember setObject:@NO forKey:user_isReady];
        [newMember saveSynchronous:&error];
        
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            
            //push通知を送る
            KiiTopic *topic = [joinUser topicWithName:topic_invite];
            KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
            NSDictionary *dict = @{
                                   @"group_uri":questGroup.objectURI
                                   };
            
            [apnsFields setSpecificData:dict];
            
            KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
            
            [topic sendMessageSynchronous:message withError:&error  ];
            if (error) NSLog(@"error:%@",error);
            else NSLog(@"参加者にpush通知送信完了");
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
    
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    if ([identifier isEqualToString:@"FIRST_ACTION"]) {
        // "Accept"した時の処理
    }
    if ([identifier isEqualToString:@"SECOND_ACTION"]) {
        // Declineした時の処理
    }
    
    
    // 終了時に呼ばれなければならない
    completionHandler();
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"FIRST_ACTION"]) {
        
        [self addGroupMember];
        
    }
    if ([identifier isEqualToString:@"SECOND_ACTION"]) {
        
    }
    if ([identifier isEqualToString:@"THIRD_ACTION"]) {
        
    }
    
    //終了時に絶対呼ぶ
    completionHandler();
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                
                [_locationManager requestAlwaysAuthorization];
            }
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            break;
            
        default:
            break;
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark FBDelegate
- (void)requestLoading:(FBRequest *)request
{
    
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"%@", result);
}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    
}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"click 0 ");
            NSError *error;
            
            KiiGroup *group = [KiiGroup groupWithURI:groupURI];
            NSLog(@"参加グループ:%@",group);
            
            [group refreshSynchronous:&error];
            
            if (error != NULL) {
            }
            
            break;
            
    }
}

#pragma mark - グループ追加処理
- (void)addGroupMember
{
 
}

- (void)pushTest
{
    //localNotification
    UILocalNotification *notification = [UILocalNotification new];
    notification.category = @"INVITE_CATEGORY";
    notification.alertBody = @"クエストの参加者が現れました";
    notification.fireDate = [NSDate date];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

}




@end
