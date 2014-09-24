//
//  GXAppDelegate.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXAppDelegate.h"
#import "GXDictonaryKeys.h"

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
    
    
//    //Todo:クラス化
//    //フォラグラウンド時
//    UIMutableUserNotificationAction *firstAction = [UIMutableUserNotificationAction new];
//    firstAction.identifier = @"FIRST_ACTION";
//    firstAction.title = @"ActionA";
//    //ボタンを押した時にアプリを起動するかしないか
//    firstAction.activationMode = UIUserNotificationActivationModeForeground;
//    firstAction.destructive = false;
//    firstAction.authenticationRequired = false;
//    
//    UIMutableUserNotificationAction *secondAction = [UIMutableUserNotificationAction new];
//    secondAction.identifier = @"SECOND_ACTION";
//    secondAction.title = @"Action B";
//    secondAction.activationMode = UIUserNotificationActivationModeForeground;
//    secondAction.destructive = false;
//    secondAction.authenticationRequired = false;
//    
//    //バックグラウンド
//    UIMutableUserNotificationAction *thirdAction = [UIMutableUserNotificationAction new];
//    thirdAction.identifier = @"THIRD_ACTION";
//    thirdAction.title = @"Action C";
//    thirdAction.activationMode = UIUserNotificationActivationModeBackground;
//    thirdAction.destructive = false;
//    thirdAction.authenticationRequired = false;
//    
//    UIMutableUserNotificationCategory *firstCategory = [UIMutableUserNotificationCategory new];
//    firstCategory.identifier = @"FIRST_CATEGORY";
//    
//    NSArray *defaultActions = @[firstAction,secondAction,thirdAction];
//    NSArray *minimalActions = @[firstAction,secondAction];
//    
//    [firstCategory setActions:defaultActions forContext:UIUserNotificationActionContextDefault];
//    [firstCategory setActions:minimalActions forContext:UIUserNotificationActionContextMinimal];
//    
//    NSSet *categories = [NSSet setWithObject:firstCategory];
//    
//    //UserNotificationの設定
//    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
//    UIUserNotificationTypeSound;
//    UIUserNotificationSettings *mySetting = [UIUserNotificationSettings settingsForTypes:types categories:categories];
//    [application registerUserNotificationSettings:mySetting];
    
   
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
    KiiPushMessage *message = [KiiPushMessage messageFromAPNS:userInfo];
    
    // Get Topic string using getValueOfKiiMessageField.
    // "KiiMessage_TOPIC" is enum that is defined in KiiMessageField.
    NSString *topicName = [message getValueOfKiiMessageField:KiiMessage_TOPIC];
    
    NSDictionary *dict = [NSDictionary dictionary];
    dict = userInfo;
    groupURI = dict[@"group"];
    
    
    //アプリがフォアグランドで起動している時にPush通知を受信した場合
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"push通知受信@フォアグランド");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test" message:@"test2" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        
    }
                                    
                                    
    //バックグランドからPUSH通知でアクティブになったとき
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"プッシュ通知からアクティブ");
    }
    
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
        
        NSLog(@"notification!!");
    }
    if ([identifier isEqualToString:@"SECOND_ACTION"]) {
        
    }
    if ([identifier isEqualToString:@"THIRD_ACTION"]) {
        
    }
    
    //終了時に絶対呼ぶ
    completionHandler();
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

@end
