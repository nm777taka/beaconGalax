
//
//  GXTestBeaconViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXTestBeaconViewController.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXTestBeaconViewController ()<CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;


@end

@implementation GXTestBeaconViewController{
    CLProximity _privPriximity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:kBeaconUUID];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID major:0x0003 minor:0x0127 identifier:kIdentifier];
        
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"call");
    [self.locationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch(state) {
            case CLRegionStateInside:
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [self enterRegion];
            }
            break;
            
            case CLRegionStateOutside:
            case CLRegionStateUnknown:
            break;
            
            default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.category = @"FIRST_CATEGORY";
    notification.alertBody = @"研究室へようこそ";
    notification.fireDate = [NSDate date];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    UILocalNotification *exitNotis = [UILocalNotification new];
    exitNotis.category = @"FIRST_CATEGORY";
    exitNotis.alertBody = @"どこいくの？";
    exitNotis.fireDate = [NSDate date];
    exitNotis.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:exitNotis];
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"error:%@",error);
}

- (void)enterRegion
{
    NSLog(@"enter");
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
