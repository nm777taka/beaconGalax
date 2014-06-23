//
//  GXBeacon.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXBeacon.h"

@interface GXBeacon()

@property CBPeripheralManager *peripheralManager;
@property CLLocationManager *locationManager;

@end

@implementation GXBeacon

+ (GXBeacon *)sharedManager
{
    static GXBeacon *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[GXBeacon alloc] initSharedInstance];
    });
    
    return sharedSingleton;
}

- (id)initSharedInstance
{
    self = [super init];
    
    if (self) {
        //init
        self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
    }
    
    return self;
}

#pragma mark - CoreBluetoothデリゲート処理
//bluetooh設定状況の通知先
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

#pragma mark - CoreLocationデリゲート通知
//位置情報設定状況の通知先
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{

}

@end
