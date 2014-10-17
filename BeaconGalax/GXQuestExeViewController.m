//
//  GXQuestExeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/18.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestExeViewController.h"
#import "GXBeacon.h"
#import "GXDictonaryKeys.h"
#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"

@interface GXQuestExeViewController ()<ESTBeaconDelegate,ESTBeaconManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *questTitle;
@property (weak, nonatomic) IBOutlet UILabel *proxLabel;
@property (weak, nonatomic) IBOutlet UILabel *accLabel;
@property (weak, nonatomic) IBOutlet UIImageView *beaconImage;

@property ESTBeaconManager *beaconManager;
@property ESTBeaconRegion *beaconRegion;
@property CLBeaconMajorValue subjectBeaconMajor;
@property NSUUID *uuid;

@end

@implementation GXQuestExeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.uuid = [[NSUUID alloc]initWithUUIDString:kBeaconUUID];
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    PulsingHaloLayer *halo = [PulsingHaloLayer layer];
    halo.position = self.beaconImage.center;
    halo.backgroundColor = FlatWatermelon.CGColor;
    halo.radius = 240.0f;
    [self.view.layer insertSublayer:halo below:self.beaconImage.layer];
    
    [self questParse];
    [self startBeacon];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)questParse
{
    NSLog(@"title:%@",[self.exeQuest getObjectForKey:quest_title]);
    self.questTitle.text = [self.exeQuest getObjectForKey:quest_title];
}
- (void)startBeacon
{
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:self.uuid identifier:@"estimote"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - estBeaconDelegate
- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    ESTBeacon *closeBeacon;
    if (beacons.count > 0) {
        closeBeacon = beacons.firstObject;
        float acc = [closeBeacon.distance floatValue];
        NSMutableString *distance = [NSMutableString stringWithFormat:@"%f",acc];
        self.accLabel.text = distance;
        
        switch (closeBeacon.proximity) {
            case CLProximityImmediate:
                self.proxLabel.text = @"すごく近い";
                break;
                
            case CLProximityNear:
                self.proxLabel.text = @"近い";
                break;
                
            case CLProximityFar:
                self.proxLabel.text = @"遠い";
                break;
                
            default:
                break;
        }
    }
}

@end
