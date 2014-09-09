//
//  GXBeaconViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/09.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXBeaconViewController.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXBeaconViewController ()

@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@end

@implementation GXBeaconViewController{
    CLProximity _privProximity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:self.view.bounds andColors:@[FlatMint,FlatMintDark]];
    
    //ibeacon
        
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"test"];

    
    //Label Init
    _proximityLabel.textColor = FlatWhite;
    _proximityLabel.layer.borderWidth = 2;
    _proximityLabel.layer.borderColor = FlatWhite.CGColor;
    _proximityLabel.layer.cornerRadius = 5.0;
   
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_locationManager startMonitoringForRegion:_beaconRegion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            break;
            
        default:
            break;
    }
}

#pragma mark LocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //既に領域内にいた場合に呼ばれないのでそれに対応
    //DeterminStateの実装が必須
    NSLog(@"call");
    [self.locationManager requestStateForRegion:region];
}

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{
    //インタラクティブノーティフィケーション
    //とりあえず普通の
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody  = @"研究室へ入ったよ！";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(ESTBeaconRegion *)region
{
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopMonitoringForRegion:(CLBeaconRegion *)region];
    }
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"帰るの?";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        switch (state) {
            case CLRegionStateInside:
                NSLog(@"inside");
                if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                    [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
                }
                
                break;
                
            case CLRegionStateOutside:
                NSLog(@"outside");
                break;
            case CLRegionStateUnknown:
                NSLog(@"unknown");
                break;
                
            default:
                break;
        }
    }
        
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        
        if (_privProximity != nearestBeacon.proximity) {
            switch (nearestBeacon.proximity) {
                case CLProximityImmediate:
                    NSLog(@"めっちゃ近い");
                    break;
                    
                case CLProximityNear:
                    NSLog(@"まあまあ近い");
                    break;
                    
                case CLProximityFar:
                    NSLog(@"遠い");
                    break;
                    
                case CLProximityUnknown:
                    NSLog(@"不明");
                    break;
                    
                default:
                    break;
            }
            _privProximity = nearestBeacon.proximity;
        } else NSLog(@"no beacon");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"error:%@",error);
}

@end
