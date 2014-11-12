//
//  GXQuestReadyViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestReadyViewController.h"
#import "GXQuestGroupViewController.h"
#import "GXBeacon.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"

@interface GXQuestReadyViewController ()<ESTBeaconDelegate,ESTBeaconManagerDelegate>

@property (weak, nonatomic) IBOutlet FBProfilePictureView *ownerIconView;
@property ESTBeaconManager *beaconManager;
@property ESTBeaconRegion *beaconRegion;
@property NSUUID *uuid;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *proxLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation GXQuestReadyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.uuid = [[NSUUID alloc] initWithUUIDString:kBeaconUUID];
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    self.ownerIconView.layer.cornerRadius = 100.f;
    self.ownerIconView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.ownerIconView.layer.borderWidth = 2.0f;
    
    PulsingHaloLayer *halo = [PulsingHaloLayer layer];
    halo.position = self.ownerIconView.center;
    halo.backgroundColor = FlatWatermelon.CGColor;
    halo.radius = 240.f;
    [self.view.layer insertSublayer:halo below:self.ownerIconView.layer];
    
    self.distanceLabel.font = [UIFont boldFlatFontOfSize:17];
    self.distanceLabel.textColor = [UIColor midnightBlueColor];
    self.proxLabel.font = [UIFont boldFlatFontOfSize:20];
    self.proxLabel.textColor = [UIColor alizarinColor];
    
    self.headerLabel.font = [UIFont boldFlatFontOfSize:17];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startBeacon];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *ownerFBID = [self.willExeQuest getObjectForKey:quest_owner_fbid];
    self.ownerIconView.profileID = ownerFBID;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)startBeacon
{
    CLBeaconMajorValue major = [[self.willExeQuest getObjectForKey:@"major"] intValue];
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:self.uuid major:major identifier:@"estimote"];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    
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

#pragma mark ESTBeaconDelege
- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    ESTBeacon *closeBeacon;
    if (beacons.count > 0) {
        closeBeacon = beacons.firstObject;
        float acc = [closeBeacon.distance floatValue];
        NSMutableString *distance = [NSMutableString stringWithFormat:@"%fm",acc];
        //label更新
        self.distanceLabel.text = distance;
        
        switch (closeBeacon.proximity) {
            case CLProximityImmediate:
                NSLog(@"画面遷移");
                self.proxLabel.text = @"めっちゃ近い";
                [self stopBeacon];
                [self gotoPartyView];
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

- (void)gotoPartyView
{
    [NSTimer bk_scheduledTimerWithTimeInterval:2.0f block:^(NSTimer *timer) {
        
        [self performSegueWithIdentifier:@"gotoPartyView" sender:self];

    } repeats:NO];
}

- (void)stopBeacon
{
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}


#pragma mark segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoPartyView"]) {
        GXQuestGroupViewController *vc = segue.destinationViewController;
        vc.willExeQuest = self.willExeQuest;
        vc.selectedQuestGroup = self.selectedQuestGroup;
        
    }
}

@end
