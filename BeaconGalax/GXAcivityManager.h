//
//  GXAcivityManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>


@interface GXAcivityManager : NSObject

@property KiiBucket *activityBucket;

+ (GXAcivityManager *)sharedManager;

@end
