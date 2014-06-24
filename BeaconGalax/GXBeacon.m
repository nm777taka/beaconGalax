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

@property BOOL monitoringEnabled;
@property BOOL isMonitoring;

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
        
        self.regions = [NSMutableArray new];
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

#pragma mark - Utility - モニタリング
- (void)startMonitoring
{
    self.monitoringEnabled = YES;
    [self startMonitoringAllRegion];
}

- (void)stopMonitoring
{
    
}

- (void)startMonitoringAllRegion
{
    if (! self.monitoringEnabled) {
        return;
    }
    if (! [self isMonitoringCapable]) {
        return;
    }
    if (self.isMonitoring) {
        return;
    }
    NSLog(@"start Monitoring");
    for (GXBeaconRegion *region in self.regions) {
        [self startMonitoringRegion:region];
    }
    self.isMonitoring = YES;
    
}

- (void)startMonitoringRegion:(GXBeaconRegion *)region
{
    [self.locationManager startMonitoringForRegion:region];
    region.isMonitoring = YES;
}

- (void)stopMonitoringAllRegion
{
    
}

- (void)stopMonitoringRegion:(GXBeaconRegion *)region
{
    
}

#pragma mark - Utility -レンジング
- (void)startRanging:(GXBeaconRegion *)region
{
    if (!region.isRanging) {
        [self.locationManager startRangingBeaconsInRegion:region];
        region.isRanging = YES;
    }
}

- (void)stopRanging:(GXBeaconRegion *)region
{
    if (region.isRanging) {
        [self.locationManager stopRangingBeaconsInRegion:region];
        region.beacons = nil;
        region.isRanging = NO;
    }
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
    NSLog(@"登録");
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

//ロック画面へのノーティフィケーションデリゲート呼び出し
- (void)enterRegion:(CLBeaconRegion *)region
{
    //GXBeaconRegionを探す
    GXBeaconRegion *gxRegion = [self lookupRegion:region];
    if (!gxRegion) {
        NSLog(@"no region");
        return;
    }
    
    //既に領域内にいた
    if (gxRegion.hasEntered) {
        return;
    }
    
    if (gxRegion.rangingEnabled) {
        //レンジングを開始
        [self startRanging:gxRegion];
    }
    
    gxRegion.hasEntered = YES;
    //デリゲート処理
    
    NSLog(@"enter");
}

//レンジング停止
- (void)exitRegion:(CLBeaconRegion *)region
{
    GXBeaconRegion *gxRegion = [self lookupRegion:region];
    
    if (!gxRegion) {
        return;
    }
    if (! gxRegion.hasEntered) {
        return;
    }
    if (gxRegion.rangingEnabled) {
        
        [self stopRanging:gxRegion];
    }
    
    gxRegion.hasEntered = YES;
    //デリゲート
}

- (GXBeaconRegion *)lookupRegion:(CLBeaconRegion *)region
{
    for (GXBeaconRegion *gxRegion in self.regions) {
        if ([gxRegion.proximityUUID.UUIDString isEqualToString:region.proximityUUID.UUIDString] &&
            [gxRegion.identifier isEqualToString:region.identifier]&&
            gxRegion.major == region.major &&
             gxRegion.minor == region.minor) {
            
            return gxRegion;
                
        }
    }
    
    return nil;
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

//モニタリング開始用デリゲート
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //既に領域内にいた場合に呼ばれないため、requestStateForRegionを呼んで今の状態をリクエスト
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        
        GXBeaconRegion *gxRegion = [self lookupRegion:(CLBeaconRegion *)region];
        if (gxRegion) {
            gxRegion.failCount = 0;
        }
    }
    
    [self.locationManager requestStateForRegion:region];
}

//領域に入ったイベントをキャッチ
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        
        [self enterRegion:(CLBeaconRegion *)region];
    }
}

//領域をでたイベントをキャッチ
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        
        //exit
        [self exitRegion:(CLBeaconRegion *)region];
    }
}

//既に領域内にいた場合対策
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        switch (state) {
            case CLRegionStateInside:
                //なにかする
                [self enterRegion:(CLBeaconRegion *)region];
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

#pragma mark - レンジングイベント
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"レンジング");
    GXBeaconRegion *gxRegion = [self lookupRegion:(CLBeaconRegion *)region];
    if (!gxRegion) {
        return;
    }
    gxRegion.beacons = beacons;
    
    NSLog(@"beacon count : %d",gxRegion.beacons.count);
    
    //デリゲート
    //リロードデータ呼ばないといけないフラグ
    if ([self.delegate respondsToSelector:@selector(didRangeBeacons:)]) {
        [self.delegate didRangeBeacons:gxRegion];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    GXBeaconRegion *gxRegion = [self lookupRegion:region];
    if (!gxRegion) {
        return;
    }
    
    //レンジングを停止
    [self stopRanging:gxRegion];
}

@end
