//
//  GXUserAttendAnalytics.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXUserAttendAnalytics : NSObject

+ (GXUserAttendAnalytics *)sharedInstance;

- (void)attend;

@end
