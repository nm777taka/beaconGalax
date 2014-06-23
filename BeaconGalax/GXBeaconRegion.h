//
//  GXBeaconRegion.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface GXBeaconRegion : CLBeaconRegion

@property (nonatomic) BOOL rangingEnabled;
@property (nonatomic) BOOL isMonitoring;
@property (nonatomic) BOOL hasEntered;
@property (nonatomic) BOOL isRanging;
@property (nonatomic) NSUInteger failCount;
@property (nonatomic) NSArray *beacons;

- (void)clearFlags;

@end
