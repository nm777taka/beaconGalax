//
//  GXBeacon.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXBeacon.h"
#import "GXBeaconRegion.h"
#import "GXNotification.h"

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
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(applicationDidBecomeActive)
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    }
    
    return self;
}

#pragma mark - GXNotificationCenterハンドラ
- (void)applicationDidBecomeActive
{
    //アプリがフォアグランドになった時にリージョンのステータスをアップデートする
    
    [NSTimer bk_scheduledTimerWithTimeInterval:1.0f block:^(NSTimer *timer) {
        for (GXBeaconRegion *region in self.regions) {
            if (region.isMonitoring) {
                [self.locationManager requestStateForRegion:region];
                
                NSLog(@"フォアグランドハンドラ");
            }
        }
    } repeats:NO];
}

#pragma mark - デバイス管理
#pragma mark - CoreBluetoothデリゲート処理
//bluetooh設定状況の通知先
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"bluetooth update");
    
    if ([self isMonitoringCapable]) {
        [self startMonitoringAllRegion];
    } else {
        //stopモニタリング
        NSLog(@"stopモニタリング");
        [self stopMonitoringAllRegion];
    }
    
    if ([self.delegate respondsToSelector:@selector(didUpdatePeripheralState:)]) {
        
        [self.delegate didUpdatePeripheralState:[self peripheralStateWithString:peripheral.state]];
    }
    
    [self updateMonitoringStatus];
}

#pragma mark - TODO : リファクタリングしたい
//リファクタリングしたい
- (NSString *)peripheralStateWithString:(CBPeripheralManagerState)state
{
    switch (state) {
        case CBPeripheralManagerStatePoweredOn:
            return @"On";
            break;
        case CBPeripheralManagerStatePoweredOff:
            return @"Off";
            break;
        case CBPeripheralManagerStateUnauthorized:
            return @"Unauthorized";
            break;
        case CBPeripheralManagerStateResetting:
            return @"Resetting";
            break;
        case CBPeripheralManagerStateUnknown:
            return @"Unknown";
            break;
        case CBPeripheralManagerStateUnsupported:
            return @"UnSupported";
            break;
            
        default:
            break;
    }
}

#pragma mark - CoreLocationデリゲート通知
//位置情報設定状況の通知先
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                
                [_locationManager requestAlwaysAuthorization];
            }
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            [self startMonitoring];
            break;
            
        default:
            break;
    }
    
    
    
//    if ([self isMonitoringCapable]) {
//        [self startMonitoringAllRegion];
//    } else {
//        //モニタリングストップ
//        [self stopMonitoringAllRegion];
//    }
//    
//    if ([self.delegate respondsToSelector:@selector(didUpdateLocationStatus:)]) {
//        [self.delegate didUpdateLocationStatus:[self locationAuthorizationStateString:status]];
//    }
//    
//    [self updateMonitoringStatus];
}

- (NSString *)locationAuthorizationStateString:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
            return @"Authorized";
            break;
        case kCLAuthorizationStatusDenied:
            return @"Denied";
            break;
        case kCLAuthorizationStatusNotDetermined:
            return @"NotDetermined";
            break;
        case kCLAuthorizationStatusRestricted:
            return @"Restricted";
            break;
            
        default:
            return nil;
            break;
    }
}

#pragma mark - Utility - モニタリング
- (void)startMonitoring
{
    self.monitoringEnabled = YES;
    [self startMonitoringAllRegion];
}

- (void)stopMonitoring
{
    self.monitoringEnabled = NO;
    [self stopMonitoringAllRegion];
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
    
    [self updateMonitoringStatus];

}


- (void)startMonitoringRegion:(GXBeaconRegion *)region
{
    if (!self.monitoringEnabled) {
        NSLog(@"return 1");
        return;
    }
    if (![self isMonitoringCapable]) {
        NSLog(@"return 2");
        return;
    }
    if (self.isMonitoring) {
        NSLog(@"return 3");
        return;
    }
    
    NSLog(@"monitoring : %@",region.identifier);
    NSLog(@"region-major:%d",[region.major intValue]);
    NSLog(@"region-minor:%d",[region.minor intValue]);
    
    [self.locationManager startMonitoringForRegion:region];
    
    region.isMonitoring = YES;
    
}

- (void)stopMonitoringAllRegion
{
    if (!self.isMonitoring) {
        return;
    }
    
    for (GXBeaconRegion *region in self.regions) {
        [self stopMonitoringRegion:region];
    }
    
    self.isMonitoring = NO;
    
    [self updateMonitoringStatus];
}

- (void)stopMonitoringRegion:(GXBeaconRegion *)region
{
    [self.locationManager stopMonitoringForRegion:region];
    [self stopRanging:region];
    region.isMonitoring = NO;
    if (region.hasEntered) {
        region.hasEntered = NO;
        
        //notification用のデリゲート
    }
    
}

- (GXBeaconMonitoringStatus)getUpdateMonitoringStatus
{
    if (![self isMonitoringCapable]) {
        return kGXBeaconMonitoringStatusDisabled;
    }
    if (self.isMonitoring) {
        return kGXBeaconMonitoringStatusMonitoring;
    } else {
        return kGXBeaconMonitoringStatusStopped;
    }
}

- (void)updateMonitoringStatus
{
    GXBeaconMonitoringStatus current = self.monitoringStatus;
    GXBeaconMonitoringStatus newStatus = [self getUpdateMonitoringStatus];
    if (current != newStatus) {
        if ([self.delegate respondsToSelector:@selector(didUpdateMonitoringStatus:)]) {
            [self.delegate didUpdateMonitoringStatus:newStatus];
        }
    }
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
    NSLog(@"%d",major);
    if (self.regions.count >= kGXBeaconRegionMax) {
        return nil;
    }
    
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:UUIDString];
    GXBeaconRegion *region = [[GXBeaconRegion alloc]initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
    
    [region clearFlags];
    [self.regions addObject:region];
    NSLog(@"regionscount:%d",self.regions.count);
    
    return region;
}

//ロック画面へのノーティフィケーションデリゲート呼び出し
- (void)enterRegion:(CLBeaconRegion *)region
{
    //GXBeaconRegionを探す
    GXBeaconRegion *gxRegion = [self lookupRegion:region];
    
    //NSLog(@"major : %d",[gxRegion.major intValue]);
    if (!gxRegion) {
        NSLog(@"no region");
        return;
    }
    
    //既に領域内にいた
    if (gxRegion.hasEntered) {
        NSLog(@"hasEntered");
        return;
    }
    
    if (gxRegion.rangingEnabled) {
        //レンジングを開始
        [self startRanging:gxRegion];
    }
    
    
    NSLog(@"enterRegion");
    
    gxRegion.hasEntered = YES;
    //デリゲート処理
    
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
                
        }else{
            
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
    
    NSLog(@"didStartMonitring");
    
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
                [self exitRegion:(CLBeaconRegion *)region];
                break;
                
            default:
                break;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    
    NSLog(@"monitoringDidFailForRegion");
    
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        GXBeaconRegion *gxRegion = [self lookupRegion:(CLBeaconRegion *)region];
        
        if (!gxRegion) {
            return;
        }
        
        [self stopMonitoringRegion:gxRegion];
        self.isMonitoring = NO;
        
        if (gxRegion.failCount < GXBeaconRegionFailCountMax) {
            gxRegion.failCount++;
            
            [NSTimer bk_scheduledTimerWithTimeInterval:1.0f block:^(NSTimer *timer) {
                
                //モニタリングをトライ
                NSLog(@"モニタリングtry");
                [self startMonitoringRegion:gxRegion];
                
            } repeats:NO];
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
