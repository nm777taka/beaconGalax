//
//  GXBeacon.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GXBeaconRegion.h"

@import CoreBluetooth;

#define kGXBeaconRegionMax 20

@interface GXBeacon : NSObject<CLLocationManagerDelegate,CBPeripheralManagerDelegate>

@property (nonatomic) NSMutableArray *regions;

+ (GXBeacon *)sharedManager;
- (GXBeaconRegion *)registerRegion:(NSString *)UUIDString identifier:(NSString *)identifier;
- (GXBeaconRegion *)registerRegion:(NSString *)UUIDString major:(CLBeaconMajorValue)major identifier:(NSString *)identifier;
- (GXBeaconRegion *)registerRegion:(NSString *)UUIDString major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor identifier:(NSString *)identifier;



@end
