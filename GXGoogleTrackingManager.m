//
//  GXGoogleTrackingManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/02.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXGoogleTrackingManager.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@implementation GXGoogleTrackingManager

//スクリーン名をGAに送信
+ (void)sendScreenTracking:(NSString *)screenName
{
    /*
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    //スクリーン名を設定
    [tracker set:kGAIScreenName value:screenName];
    
    //トラッキング情報を送信
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    //送信を終わったらtrackerに設定されてるスクリーン名を初期化
    [tracker set:kGAIScreenName value:nil];
    
    NSLog(@"送信完了");
     */
    
}

//イベントをGAに送信
+ (void)sendEventTracking:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value screen:(NSString *)screen
{
    /*
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:screen];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:value] build]];
     */
     
     
}

@end
