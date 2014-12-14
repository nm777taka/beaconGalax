//
//  GXUserAttendAnalytics.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXUserAttendAnalytics.h"
#import "GXBucketManager.h"

@implementation GXUserAttendAnalytics

+ (GXUserAttendAnalytics *)sharedInstance
{
    static GXUserAttendAnalytics *sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXUserAttendAnalytics alloc] initSingleton];
    });
    
    return sharedSingleton;
}

- (id)initSingleton
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

//研究室への出席
- (void)attend
{
    NSLog(@"call-attend");
    KiiBucket *bucket = [GXBucketManager sharedManager].attendBucket;
    
    //バケットがなかったら
    if (bucket == nil) {
        KiiObject *obj = [bucket createObject];
        NSDate *date = [NSDate date];
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd 'at' HH:mm";
        NSString *dfString = [df stringFromDate:date];
        [obj setObject:dfString forKey:@"attendDate"];
        [obj saveWithBlock:^(KiiObject *object, NSError *error) {
            if (!error) {
                NSLog(@"出席");
            }
        }];
        
    } else {
        
        //すでにその日に出席しているかバリデ
        NSDate *date = [NSDate date];
        //9時間前の日付を求める（UTCに合わせる)
        NSCalendar *calender = [NSCalendar currentCalendar] ;
        NSDateComponents *comp = [NSDateComponents new];
        comp.hour  = -9;
        NSDate *utcDate = [calender dateByAddingComponents:comp toDate:date options:0];
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd 'at' HH:mm";
        
        //utcDateを使ってqueryをたてる
        //一番最近の出席をとってくる
        KiiQuery *query = [KiiQuery queryWithClause:nil];
        [query sortByDesc:@"_created"];
        [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
            
            if (results.count == 0) {
                //何もなかったら
                KiiObject *obj = [bucket createObject];
                NSDate *date = [NSDate date];
                NSDateFormatter *df = [NSDateFormatter new];
                df.dateFormat = @"yyyy-MM-dd 'at' HH:mm";
                NSString *dfString = [df stringFromDate:date];
                [obj setObject:dfString forKey:@"attendDate"];
                [obj saveWithBlock:^(KiiObject *object, NSError *error) {
                    if (!error) {
                    }
                }];
                
                return ;
            }
            
            if (!error) {
                KiiObject *obj = results.lastObject;
                NSDate *created = obj.created;
                
                NSDateComponents *createdComps
                = [calender components:NSYearCalendarUnit   |
                   NSMonthCalendarUnit  |
                   NSDayCalendarUnit    |
                   NSHourCalendarUnit   |
                   NSMinuteCalendarUnit | 
                   NSSecondCalendarUnit
                              fromDate:created];
                
                NSDateComponents *currentDateComp
                = [calender components:NSYearCalendarUnit   |
                   NSMonthCalendarUnit  |
                   NSDayCalendarUnit    |
                   NSHourCalendarUnit   |
                   NSMinuteCalendarUnit |
                   NSSecondCalendarUnit
                              fromDate:utcDate];
                //日付だけ抜き出す
                
                if (createdComps.day == currentDateComp.day) {
                    return ;
                } else {
                    //出席データを送信
                    NSString *dfString = [df stringFromDate:date];
                    [obj setObject:dfString forKey:@"attendDate"];
                    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
                        if (!error) {
                            NSLog(@"出席完了");
                        }
                    }];
                }
                
            } else{
                NSLog(@"error:%@",error);
                
            }
        }];
        
    }
}


@end
