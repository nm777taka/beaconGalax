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

typedef enum {
    
    kGXBeaconMonitoringStatusDisabled,
    kGXBeaconMonitoringStatusStopped,
    kGXBeaconMonitoringStatusMonitoring
    
}GXBeaconMonitoringStatus;

@protocol GXBeaconDelegate <NSObject>

//ビーコンがレンジング対象になった場合にテーブルビューを更新する
- (void)didRangeBeacons:(GXBeaconRegion *)region;

//bluetooth設定をラベルに反映
- (void)didUpdatePeripheralState:(NSString *)state;

//位置情報サービス設定をラベルに反映
- (void)didUpdateLocationStatus:(NSString *)status;

//tableViewのモニタリングボタンの状態管理
- (void)didUpdateMonitoringStatus:(GXBeaconMonitoringStatus)status;

@end



@interface GXBeacon : NSObject<CLLocationManagerDelegate,CBPeripheralManagerDelegate>

@property (nonatomic) NSMutableArray *regions;
@property (nonatomic,weak) id <GXBeaconDelegate> delegate;
@property GXBeaconMonitoringStatus monitoringStatus;


+ (GXBeacon *)sharedManager;
- (GXBeaconRegion *)registerRegion:(NSString *)UUIDString identifier:(NSString *)identifier;
- (GXBeaconRegion *)registerRegion:(NSString *)UUIDString major:(CLBeaconMajorValue)major identifier:(NSString *)identifier;
- (GXBeaconRegion *)registerRegion:(NSString *)UUIDString major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor identifier:(NSString *)identifier;

- (void)requestUpdatgeForStatus;
- (void)startMonitoring;
- (void)stopMonitoring;

@end

