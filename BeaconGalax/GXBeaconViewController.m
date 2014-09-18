//
//  GXBeaconViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/09.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXBeaconViewController.h"
#import "GXBeacon.h"
#import "GXBeaconRegion.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXBeaconViewController ()<GXBeaconDelegate>

@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationStatus;
@property (weak, nonatomic) IBOutlet UILabel *bluetoothStatus;
@property (weak, nonatomic) IBOutlet UILabel *monitoringStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationLabel;
@property GXBeacon *beacon;
@property GXBeaconMonitoringStatus monitoringStatus;
@property NSDictionary *beaconDict;

@property (nonatomic) NSUUID *proximityUUID;

@end

@implementation GXBeaconViewController{
    CLProximity _privProximity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:self.view.bounds andColors:@[FlatMint,FlatMintDark]];
    
    //ibeacon
    self.beacon = [GXBeacon sharedManager];
    self.beacon.delegate = self;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GXBeaconRegion *region;
        region = [self.beacon registerRegion:kBeaconUUID identifier:kIdentifier];
        //test用にparple01にしぼる
        //region = [self.beacon registerRegion:kBeaconUUID major:0x0003 minor:0x0127 identifier:kIdentifier];
        if (region) region.rangingEnabled = YES;
    });
        
    
    //Label Init
    [self gxThemeLabel:self.proximityLabel];
    [self gxThemeLabel:self.locationStatus];
    [self gxThemeLabel:self.monitoringStatusLabel];
    [self gxThemeLabel:self.bluetoothStatus];
    [self gxThemeLabel:self.currentLocationLabel];
   
    
    self.beaconDict = @{@55213:@"研究室の自分の机",@31751:@"ゼミ室"};
    
    
    //NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpText:) name:@"actionOnePressed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAMessage:) name:@"actionTwoPressed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAText:) name:@"actionThirdPressed" object:nil];
    
}

//todo:カテゴリにする
- (void)gxThemeLabel:(UILabel *)label
{
    label.textColor = FlatWhite;
    label.layer.cornerRadius = 5.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.beacon startMonitoring];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GXBeacon Delegate
- (void)didRangeBeacons:(GXBeaconRegion *)region
{
    if (!region.beacons) {
        NSLog(@"didRangeBeaocn:count 0");
    }
    
    CLBeacon *nearestBeacon = region.beacons.firstObject;
    
    NSString *alertBody = self.beaconDict[nearestBeacon.major];
    UILocalNotification *notification = [UILocalNotification new];
    notification.category = @"FIRST_CATEGORY";
    notification.alertBody = alertBody;
    notification.region = region;
    notification.regionTriggersOnce = YES;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    
    if (_privProximity != nearestBeacon.proximity) {
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                self.proximityLabel.text = @"Immediate";
                self.currentLocationLabel.text = self.beaconDict[nearestBeacon.major];
                break;
                
            case CLProximityNear:
                self.proximityLabel.text = @"Near";
                break;
                
            case CLProximityFar:
                self.proximityLabel.text = @"Far";
                break;
                
            case CLProximityUnknown:
                self.proximityLabel.text = @"Unknown";
                break;
                
            default:
                break;
        }
        
        //更新
        _privProximity = nearestBeacon.proximity;
    }
}

- (void)didUpdatePeripheralState:(NSString *)state
{
    NSMutableString *bluetoothLabelText = [NSMutableString stringWithFormat:@"Bluetooth:"];
    [bluetoothLabelText appendString:state];
    self.bluetoothStatus.text = bluetoothLabelText;
}

- (void)didUpdateLocationStatus:(NSString *)status
{
    NSMutableString *locationLabelText = [NSMutableString stringWithFormat:@"location:"];
    [locationLabelText appendString:status];
    self.locationStatus.text = locationLabelText;
}

- (void)didUpdateMonitoringStatus:(GXBeaconMonitoringStatus)status
{
    self.monitoringStatus = status;
    
    switch (status) {
        case kGXBeaconMonitoringStatusDisabled:
            self.monitoringStatusLabel.text = @"Disable";
            break;
            
        case kGXBeaconMonitoringStatusMonitoring:
            self.monitoringStatusLabel.text = @"Monitoring";
            break;
        
        case kGXBeaconMonitoringStatusStopped:
            self.monitoringStatusLabel.text = @"Stop";
            break;
            
        default:
            break;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/





//- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
//{
//    if (beacons.count > 0) {
//        CLBeacon *nearestBeacon = beacons.firstObject;
//        
//        if (_privProximity != nearestBeacon.proximity) {
//            switch (nearestBeacon.proximity) {
//                case CLProximityImmediate:
//                    NSLog(@"めっちゃ近い");
//                    break;
//                    
//                case CLProximityNear:
//                    NSLog(@"まあまあ近い");
//                    break;
//                    
//                case CLProximityFar:
//                    NSLog(@"遠い");
//                    break;
//                    
//                case CLProximityUnknown:
//                    NSLog(@"不明");
//                    break;
//                    
//                default:
//                    break;
//            }
//            _privProximity = nearestBeacon.proximity;
//        }
//    }
//}


@end
