//
//  GXBeacon.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXBeacon.h"
#import "GXBeaconRegion.h"

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

#pragma mark - デバイス管理
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

#pragma mark - リージョンマネジメント
//リージョンを登録
- (GXBeaconRegion *)registerRegion:(NSString *)UUIDString identifier:(NSString *)identifier
{
    if (self.regions.count >= kGXBeaconRegionMax) {
        return nil;
    }
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:UUIDString];
    GXBeaconRegion *region = [[GXBeaconRegion alloc]initWithProximityUUID:uuid identifier:identifier];
    
    [region clearFlags];
    [self.regions addObject:region];
    
    return region;
    
}

- (GXBeaconRegion *)registerRegion:(NSString *)UUIDString major:(CLBeaconMajorValue)major identifier:(NSString *)identifier
{
    if (self.regions.count >= kGXBeaconRegionMax) {
        return nil;
    }
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:UUIDString];
    GXBeaconRegion *region = [[GXBeaconRegion alloc]initWithProximityUUID:uuid major:major identifier:identifier];
    
    [region clearFlags];
    [self.regions addObject:region];
    
    return region;
}

- (GXBeaconRegion *)registerRegion:(NSString *)UUIDString major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor identifier:(NSString *)identifier
{
    if (self.regions.count >= kGXBeaconRegionMax) {
        return nil;
    }
    
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:UUIDString];
    GXBeaconRegion *region = [[GXBeaconRegion alloc]initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
    
    [region clearFlags];
    [self.regions addObject:region];
    
    return region;
}

#pragma mark - リージョン監視処理(リージョンイベント)
//リージョン監視の開始ができるかどうか
- (BOOL)isMonitoringCapable
{
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        return NO;
    }
    
    //bluetoothがoffになっていた
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return NO;
    }
    
    //位置情報サービスがoff
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return NO;
    }
    
    return YES;
}

//モニタリング開始
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //既に領域内にいた場合に呼ばれないため、requestStateForRegionを呼んで今の状態をリクエスト
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        
    }
    
    [self.locationManager requestStateForRegion:region];
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        //なにかする
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        switch (state) {
            case CLRegionStateInside:
                //なにかする
                break;
            case CLRegionStateOutside:
            case CLRegionStateUnknown:
                //なにかする
                break;
                
            default:
                break;
        }
    }
}




@end
