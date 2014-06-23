//
//  GXBeacon.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@import CoreBluetooth;

@interface GXBeacon : NSObject<CLLocationManagerDelegate,CBPeripheralManagerDelegate>

+ (GXBeacon *)sharedManager;

@end
