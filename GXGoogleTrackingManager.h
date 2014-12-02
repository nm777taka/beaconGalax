//
//  GXGoogleTrackingManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/02.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXGoogleTrackingManager : NSObject

//スクリーン名計測用メソッド
+ (void)sendScreenTracking:(NSString *)screenName;

//イベント計測用メソッド
+ (void)sendEventTracking:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value screen:(NSString *)screen;

@end
