//
//  GXAppDelegate.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXAppDelegate.h"

@implementation GXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //kiiCloudの設定
    [Kii beginWithID:@"89c1cddc" andKey:@"b84c451265c396ea57d3eb50784cc29a" andSite:kiiSiteJP];
    
    //kiiCloud - faceboookLogin
    [KiiSocialConnect setupNetwork:kiiSCNFacebook
                           withKey:@"559613677480642"
                         andSecret:nil
                        andOptions:nil];
    
   
    return YES;
}


//シングルサインオンの有効
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    return [KiiSocialConnect handleOpenURL:url];
}

#pragma mark -ToDo:Pushのインストール周りの挙動がおかしい
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"device token :%@",deviceToken);
    [Kii setAPNSDeviceToken:deviceToken];
    [KiiPushInstallation installWithBlock:^(KiiPushInstallation *installation, NSError *error) {
        if (error == nil) {
            NSLog(@"push installed!");
        } else {
            NSLog(@"Error installing: %@",error);
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    KiiPushMessage *message = [KiiPushMessage messageFromAPNS:userInfo];
    
    // Get Topic string using getValueOfKiiMessageField.
    // "KiiMessage_TOPIC" is enum that is defined in KiiMessageField.
    NSString *topicName = [message getValueOfKiiMessageField:KiiMessage_TOPIC];
    
    // Show alert message
    [message showMessageAlertWithTitle:topicName];
    
    //アプリがフォアグランドで起動している時にPush通知を受信した場合
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"push通知受信@フォアグランド");
    }
    
    //バックグランドからPUSH通知でアクティブになったとき
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"プッシュ通知からアクティブ");
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



@end
