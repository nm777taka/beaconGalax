//
//  UILocalNotification+GXNotification.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "UILocalNotification+GXNotification.h"

@implementation UILocalNotification (GXNotification)

//LocalNotification Information Dictionary Keys
NSString * const GXNotificationInfoNotificationKind = @"GXNotificationInfoNotificationKind";
NSString * const GXNotificationInfoKindQuestDeliver = @"GXNotificationInfoKindQuestDeliver";

+ (void)setQuestDeliverLocalNotification
{
    //以前に作成していたら削除
    [UILocalNotification cancelQuestDeliverNotification];
    
    //曜日指定 (月〜金)
    NSArray *weekAry = @[@2,@3,@4,@5,@6];
    
    //通知時間生成
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    UILocalNotification *notification = [UILocalNotification new];
    NSInteger repeart = 60; //繰り返し日数
    NSDate *today = [NSDate date];
    NSDate *date;
    NSDateComponents *compontentsForFireDate;
    for (int i = 0; i < repeart; i++) {
        date = [today dateByAddingTimeInterval:i * 24 * 60 * 60];
        compontentsForFireDate = [calendar components:(NSYearCalendarUnit |
                                                      NSMonthCalendarUnit |
                                                      NSDayCalendarUnit |
                                                      NSWeekdayCalendarUnit) fromDate:date];
        
        //8:30を指定
        [compontentsForFireDate setHour:8];
        [compontentsForFireDate setMinute:30];
        [compontentsForFireDate setSecond:0];
        NSDate *fireDateOfNotification = [calendar dateFromComponents:compontentsForFireDate];
        
        if ([weekAry containsObject:[NSNumber numberWithInteger:compontentsForFireDate.weekday]]) {
            if ([[NSDate date] compare:fireDateOfNotification] == NSOrderedAscending) { //今よりも未来であること
                notification.fireDate = fireDateOfNotification;
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.alertBody = @"今日のクエストが配信されました";
                notification.alertAction = @"開く";
                notification.soundName = UILocalNotificationDefaultSoundName;
                
                NSDictionary *infoDictionary = @{GXNotificationInfoNotificationKind:GXNotificationInfoKindQuestDeliver};
                notification.userInfo = infoDictionary;
                
                //通知を登録
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                NSLog(@"通知登録完了");
            }
        }
    }
}

+ (BOOL)cancelQuestDeliverNotification
{
    BOOL isSucceed = NO;
    
    for(UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([[notification.userInfo objectForKey:GXNotificationInfoNotificationKind] isEqualToString:GXNotificationInfoKindQuestDeliver]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            isSucceed = YES;
        }
    }
    
    return isSucceed;
}

+ (BOOL)isQuestDeliverLocalNotification:(UILocalNotification *)notification
{
    return [[notification.userInfo objectForKey:GXNotificationInfoNotificationKind] isEqualToString:GXNotificationInfoKindQuestDeliver];
}

@end
