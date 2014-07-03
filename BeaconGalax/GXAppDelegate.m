//
//  GXAppDelegate.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXAppDelegate.h"
#import <FacebookSDK.h>

@implementation GXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //facebook SDK 対応クラスをロード
    [FBLoginView class];
    
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
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    return [KiiSocialConnect handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
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
    
    NSLog(@"push");
    //パース
    NSString *name = userInfo[@"From"];
    NSString *description = userInfo[@"msgBody"];
    
    FUIAlertView *loggedInAlertView = [[FUIAlertView alloc] initWithTitle:name message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    loggedInAlertView.titleLabel.textColor = [UIColor cloudsColor];
    loggedInAlertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    
    loggedInAlertView.messageLabel.textColor = [UIColor cloudsColor];
    loggedInAlertView.messageLabel.font = [UIFont boldFlatFontOfSize:14];
    
    loggedInAlertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    loggedInAlertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    
    loggedInAlertView.defaultButtonColor = [UIColor cloudsColor];
    loggedInAlertView.defaultButtonShadowColor = [UIColor asbestosColor];
    loggedInAlertView.defaultButtonTitleColor = [UIColor asbestosColor];
    loggedInAlertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        
    [loggedInAlertView show];
    
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

@end
