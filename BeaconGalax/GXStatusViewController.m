//
//  GXStatusViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/06.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXStatusViewController.h"
#import "GXBeacon.h"
#import "GXBeaconRegion.h"
#import "GXNotification.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXStatusViewController ()<GXBeaconDelegate>

@property (weak, nonatomic) IBOutlet UILabel *locationStatusLable;
@property (weak, nonatomic) IBOutlet UILabel *bluetoothStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *monitoringStatusLabel;
@property GXBeacon *beacon;
@property GXBeaconMonitoringStatus monitoringStatus;
@property (nonatomic) NSUUID *proximityUUID;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIcon;

@end

@implementation GXStatusViewController{
    CLProximity _privProximity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    self.userIcon.layer.cornerRadius = 50.0;
    self.userIcon.layer.borderColor = FlatMint.CGColor;
    self.userIcon.layer.borderWidth = 2.0;
    
    //ibeacon
    self.beacon = [GXBeacon sharedManager];
    self.beacon.delegate = self;
    GXBeaconRegion *region;
    region = [self.beacon registerRegion:kBeaconUUID identifier:kIdentifier];
    if (region) region.rangingEnabled = YES;
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbIconHandler:) name:GXFBProfilePictNotification object:nil];
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

#pragma mark - Gxbeacon Delegate
//レンジングが開始されると呼ばれる
- (void)didRangeBeacons:(GXBeaconRegion *)region
{
    
}

//location(位置情報関連)の設定状況
- (void)didUpdateLocationStatus:(NSString *)status
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"Location:"];
    [string appendString:status];
    self.locationStatusLable.text = string;
}

//bluetooth設定状況
- (void)didUpdatePeripheralState:(NSString *)state
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"Bluethooth:"];
    [string appendString:state];
    self.bluetoothStatusLabel.text = string;
}

//モニタリングのステータス
- (void)didUpdateMonitoringStatus:(GXBeaconMonitoringStatus)status
{
    self.monitoringStatus = status;
    
    switch (status) {
        case kGXBeaconMonitoringStatusDisabled:
            self.monitoringStatusLabel.text = @"Disable";
            break;
            
        case kGXBeaconMonitoringStatusStopped:
            self.monitoringStatusLabel.text = @"Stop";
            break;
            
        case kGXBeaconMonitoringStatusMonitoring:
            self.monitoringStatusLabel.text = @"Monitoring";
            break;
            
        default:
            break;
    }
}

#pragma mark - Notification
- (void)fbIconHandler:(NSNotification *)info
{
    NSString *userID = info.object;
    self.userIcon.profileID = userID;
}

@end
