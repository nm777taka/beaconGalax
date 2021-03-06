//
//  GXAppDelegate.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXAppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "GXBucketManager.h"
#import "GXQuest.h"
#import "GXQuestList.h"
#import "GXUserManager.h"
#import "GXTopicManager.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "UILocalNotification+GXNotification.h"
#import "NSObject+BlocksWait.h"
#import "GXUserDefaults.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] \
compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface GXAppDelegate() <GXQuestListDelegate>

@property KiiUser *joinUser;
@property KiiGroup *joinedGroup;

@property (strong, nonatomic) NSUUID *proximityUUID;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *region;

@property (nonatomic,strong) GXQuestList *questList;
@property (nonatomic) BOOL isEntered;

@end

@implementation GXAppDelegate{
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[CrashlyticsKit]];
    //GoogleAnalytics初期化
    //[self initializeGoogleAnalytics];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [self registerUserNotificationSettings];
    }

    //kiiCloudの設定
    [Kii beginWithID:@"89c1cddc" andKey:@"b84c451265c396ea57d3eb50784cc29a" andSite:kiiSiteJP];
    
    //kiiCloud - faceboookLogin
    [KiiSocialConnect setupNetwork:kiiSCNFacebook
                           withKey:@"559613677480642"
                         andSecret:nil
                        andOptions:nil];
    
     [Kii enableAPNSWithDevelopmentMode:YES andNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge];
    
    //beaconの設定
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    NSString *uuid = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    //NSString *uuid = @"C318D059-F9F2-4DE8-AB0B-0701ADB7078F";
    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:uuid];
    //region作成
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID major:0001 identifier:@"研究室"];
    self.region.notifyOnEntry = YES;
    self.region.notifyOnExit = YES;
    self.region.notifyEntryStateOnDisplay = NO;
  
    //accessTokenを使ったログイン
    NSError *error;
    NSString *accessToken = [GXUserDefaults getAccessToken];
    if (accessToken) {
        
        [KiiUser authenticateWithTokenSynchronous:accessToken andError:&error];
        if (!error) {
            //[[NSNotificationCenter defaultCenter] postNotificationName:GXLoginSuccessedNotification object:nil];
            
            [self startMonitaring];
            
            KiiTopic *applicationTopic = [Kii topicWithName:@"SendingAlert"];
            [KiiPushSubscription checkSubscription:applicationTopic withBlock:^(id<KiiSubscribable> subscribable, BOOL result, NSError *error) {
                if (result) {
                    //購読済み
                } else {
                    //購読
                    [KiiPushSubscription subscribe:applicationTopic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
                        if (error) {
                            NSLog(@"error:%@",error);
                        } else {
                            NSLog(@"app-topic購読完了");
                        }
                    }];
                }
            }];

        }
    }
    
    //初回起動時のInit(一回しか呼ばれない)
    if (![GXUserDefaults isFirstLaunch]) {
        NSLog(@"初回起動");
        
        //questDeliverNotification設定
        [UILocalNotification setQuestDeliverLocalNotification];
        
        //初回起動したよフラグを書き込み
        [GXUserDefaults doneLaunchFirst];
        
    }
    
    
    //background fetch
   //x [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    
    //アプリがForegrondに無いときにこちらが呼ばれる
    //Local Notificationから起動したかどうか
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        
        //どの通知なのか
//        if ([UILocalNotification isQuestDeliverLocalNotification:notification]) {
//            NSNotification *notification = [NSNotification notificationWithName:GXRefreshDataFromLocalNotification object:nil];
//            //すぐに通知すると良くない?
//            [NSObject performBlock:^{
//                [defaultCenter postNotification:notification];
//            } afterDelay:2.5f];
//            
//        }
        
        NSNotification *notification = [NSNotification notificationWithName:GXRefreshDataFromLocalNotification object:nil];
        //すぐに通知すると良くない?
        [NSObject performBlock:^{
            [defaultCenter postNotification:notification];
        } afterDelay:2.5f];

    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signuped:) name:@"singUpSuccessed" object:nil];
    
    return YES;
}


//シングルサインオンの有効
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    return [KiiSocialConnect handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [Kii setAPNSDeviceToken:deviceToken];
    
//    [KiiPushInstallation installSynchronous:&error];
//    
//    if (error != nil) {
//        NSLog(@"push install error:%@",error);
//    } else {
//        NSLog(@"push install!!");
//    }
//    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"register errror:%@",error);
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //[self sendLocalNotificationForMessage:@"test"];
}

- (void)registerUserNotificationSettings
{
    //Aciton生成
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"FIRST_ACTION";
    acceptAction.title = @"FirstAction";
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;
    acceptAction.authenticationRequired = NO;
    acceptAction.destructive = NO;
    
    UIMutableUserNotificationCategory *testCategory = [[UIMutableUserNotificationCategory alloc] init];
    testCategory.identifier = @"TEST_CATEGORY";
    [testCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    NSSet *categories = [NSSet setWithObjects:testCategory, nil];
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
}

#pragma mark - BackgroundFetch
// バックグラウンド実行の際に呼び出される
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
//    // ここにバックグラウンド処理
//    KiiBucket *bucket = [GXBucketManager sharedManager].notJoinedQuest;
//    [bucket count:^(KiiBucket *bucket, KiiQuery *query, NSUInteger result, NSError *error) {
//        if (error) {
//            completionHandler(UIBackgroundFetchResultFailed);
//        } else {
//            NSUInteger preNum = [GXUserDefaults getCurrentNotJoinQuest];
//            if (result > preNum) {
//                //新しいデータあり
//                GXQuestList *questList = [[GXQuestList alloc] initWithDelegate:self];
//                [questList requestAsyncronous:0];
//                [self sendNotification:@"あたなへの新しいクエストがあります。挑戦してみませんか?"];
//                completionHandler(UIBackgroundFetchResultNewData);
//            } else {
//                completionHandler(UIBackgroundFetchResultNoData);
//            }
//        }
//    }];
}

#pragma mark RemoteNotificationhandler

//slient push からの backgroundFetch
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    if(![userInfo[@"aps"][@"content-available"] intValue])
    {
        KiiPushMessage *msg = [KiiPushMessage messageFromAPNS:userInfo];
        NSString *topicName = [msg getValueOfKiiMessageField:KiiMessage_TOPIC];
        NSString *msgType = [msg getValueOfKiiMessageField:KiiMessage_TYPE];
        NSString *bucketName = [msg getValueOfKiiMessageField:KiiMessage_BUCKET_ID];
        
        if ([topicName isEqualToString:@"invite_notify"]) {
            if (application.applicationState == UIApplicationStateActive) {
                //TSMessage表示用
                [[NSNotificationCenter defaultCenter] postNotificationName:GXAddGroupSuccessedNotification object:userInfo[@"group_uri"]];
                
            }
            if (application.applicationState == UIApplicationStateBackground) {
            }
        }
        
        if ([topicName isEqualToString:@"quest_start"]) {
            if (application.applicationState == UIApplicationStateActive) {
                NSLog(@"きちゃった☆");
                [[NSNotificationCenter defaultCenter] postNotificationName:GXStartQuestNotification object:nil];
            }
            
        }
        
        //パーティーへの参加
        if ([bucketName isEqualToString:@"member"]) {
            if (application.applicationState == UIApplicationStateActive) {
                
                CWStatusBarNotification *notis = [CWStatusBarNotification new];
                notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
                notis.notificationStyle = CWNotificationStyleNavigationBarNotification;
                if ([msgType isEqualToString:@"DATA_OBJECT_CREATED"]) {
                    [notis displayNotificationWithMessage:@"新しいメンバーが参加しました" forDuration:2.0f];
                    
                } else if ([msgType isEqualToString:@"DATA_OBJECT_DELETED"]) {
                    [notis displayNotificationWithMessage:@"メンバーが抜けました" forDuration:2.0f];

                }
                
                
            }
        }
        
        //グループのバケット購読によるpushハンドリング
        if ([bucketName isEqualToString:@"clear_judge"]) {
            if (application.applicationState == UIApplicationStateActive) {
                NSLog(@"stand by ready,setup");
                [[NSNotificationCenter defaultCenter] postNotificationName:GXCommitQuestNotification object:nil];
            }
        }
        
        if ([topicName isEqualToString:@"newQuestInfo"]) {
            if (application.applicationState == UIApplicationStateActive) {
                NSLog(@"きたよ");
                CWStatusBarNotification *notis = [CWStatusBarNotification new];
                notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
                [notis displayNotificationWithMessage:@"新しいクエストが届きました" forDuration:2.0f];
            }
        }
        
        
        completionHandler(UIBackgroundFetchResultNewData);
        return;
    }
    
}

#pragma mark LocalNotificationHandler
//アプリがForeGroundにあるときにはこちらが呼ばれる
//LocalNotisから起動したかどうか
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    if ([UILocalNotification isQuestDeliverLocalNotification:notification]) {
        NSNotification *notification = [NSNotification notificationWithName:GXRefreshDataFromLocalNotification object:nil];
        [NSObject performBlock:^{
            [defaultCenter postNotification:notification];
        } afterDelay:2.5f];
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
    //ここ対応必要
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
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
    
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //badgeを消す
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    [self.locationManager requestStateForRegion:self.region];
    
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

#pragma mark - CLLocationManagerDelegate methods

// Beaconに入ったときに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    //[self sendNotification:@"Enter:研究室"];
    [self runBackgroundTask:0];
    NSLog(@"didenterRegion-------->");
    
}

// Beaconから出たときに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
   // [self sendNotification:@"Exit:研究室"];
    [self runBackgroundTask:1];
    NSLog(@"didExitRegion-------->");
}

#pragma mark - Other methods

- (void)sendNotification:(NSString*)message
{
    // 通知を作成する
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [NSDate dateWithTimeInterval:10 sinceDate:[NSDate new]];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    notification.alertAction = @"Open";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // 通知を登録する
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //[self.locationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        switch (state) {
            case CLRegionStateInside:
                //[self locationManager:manager didEnterRegion:region];
                //すでに居た場合は明示的によぶ
                //ここが二階くらい呼ばれてる気がする
                NSLog(@"didDetermainState---------->");
                //[self sendNotification:@"Enter:研究室"];
                [self runBackgroundTask:0];
                
                break;
                
            case CLRegionStateOutside:
               // [self runBackgroundTask:1];
                break;
                
            case CLRegionStateUnknown:
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Monitaring
- (void)startMonitaring
{
    if ([KiiUser loggedIn]) {
        //モニタリング開始
        NSLog(@"モニタリング開始");
        [self.locationManager startMonitoringForRegion:self.region];

    } else {
        NSLog(@"モニタリングできない");
        return;
    }
}

#pragma makr - QustListDidLoad
- (void)questListDidLoad
{
    NSLog(@"didLoad");
}


#pragma mark - SingUpedNotification
- (void)signuped:(NSNotification *)notis
{
    [self startMonitaring];
    KiiTopic *applicationTopic = [Kii topicWithName:@"SendingAlert"];
    [KiiPushSubscription checkSubscription:applicationTopic withBlock:^(id<KiiSubscribable> subscribable, BOOL result, NSError *error) {
        if (result) {
            //購読済み
        } else {
            //購読
            [KiiPushSubscription subscribe:applicationTopic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
                if (error) {
                    NSLog(@"error:%@",error);
                } else {
                    NSLog(@"app-topic購読完了");
                }
            }];
        }
    }];

}

#pragma makr - Background Task
//stateIndex = 0 → enter
//stateIndex = 1 → exit
- (void)runBackgroundTask:(NSInteger)stateIndex
{
    UIApplication *application = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //既に実行済みであれば終了
            if (bgTask != UIBackgroundTaskInvalid) {
                [application endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //出席データの送信やら
        switch (stateIndex) {
            case 0:
                [[GXUserManager sharedManager] setLocation:@"研究室"];
                break;
                
            case 1:
                [[GXUserManager sharedManager] exitCommunitySpace];
                break;
            default:
                break;
        }
    });
}

@end
