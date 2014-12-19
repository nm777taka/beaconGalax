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
#import "GXUserAttendAnalytics.h"
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

- (void)setLocation:(NSString *)beaconName
{
    NSDate *timeStamp = [NSDate date];
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd 'at' HH:mm";
    NSString *stringDate = [df stringFromDate:timeStamp];
    [self.gxUser setObject:beaconName forKey:@"location"];
    [self.gxUser setObject:stringDate forKey:@"locationTimeStamp"];
    [self.gxUser setObject:@YES forKey:@"isOnline"];
    [self.gxUser saveWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            NSLog(@"ロケーションアップデート");
            //出席データをとっとく
            [self sendNotification:@"Enter:研究室"];
            [[GXUserAttendAnalytics sharedInstance] attend];
        }
    }];
    
    //研究室エンタートリガーでクエストを生成
   // [self exeServerCode];
}

- (void)exitCommunitySpace
{
    NSDate *timeStamp = [NSDate date];
    NSDateFormatter *df = [NSDateFormatter new];
    df.timeStyle = NSDateFormatterShortStyle;
    NSString *stringDate = [df stringFromDate:timeStamp];
    NSLog(@"%@",stringDate);

    [self.gxUser setObject:@"オフライン" forKey:@"location"];
    [self.gxUser setObject:@NO forKey:@"isOnline"];
    [self.gxUser setObject:stringDate forKey:@"locationTimeStamp" ];
    [self.gxUser saveWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            [self sendNotification:@"Exit:研究室"];
        }
    }];
}

- (void)exeServerCode
{
    KiiUser *currentUser = [KiiUser currentUser];
    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"didEnterCommunitySpace"];
    NSDictionary *dict = @{@"userID":currentUser.objectURI,
                           @"objectURI":self.gxUser.objectURI};
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:dict];
    [entry execute:argument withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
        NSDictionary *retDict = [result returnedValue];
        NSLog(@"returned:%@",retDict);
    }];
}

- (void)sendNotification:(NSString*)message
{
    // 通知を作成する
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [NSDate date];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    notification.alertAction = @"Open";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // 通知を登録する
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
