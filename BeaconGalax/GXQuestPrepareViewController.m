//
//  GXQuestPrepareViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestPrepareViewController.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXQuestPrepareViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet CSAnimationView *ownerAnimationView;
@property (weak, nonatomic) IBOutlet CSAnimationView *participantAnimationView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *ownerIcon;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *participantIcon;

//beacon関連
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@end

@implementation GXQuestPrepareViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //募集者
    self.ownerIcon.layer.cornerRadius = 60;
    self.ownerIcon.layer.borderWidth  = 2.0;
    self.ownerIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ownerIcon.profileID = [self.questObject getObjectForKey:quest_createdUser_fbid];
    
    //参加者
    self.participantIcon.layer.cornerRadius = 60.0;
    self.participantIcon.layer.borderWidth = 2.0;
    self.participantIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    
    KiiObject *currentUser = [[GXBucketManager sharedManager] getMeFromGalaxUserBucket];
    self.participantIcon.profileID = [currentUser getObjectForKey:user_fb_id];
    
    //beaconパート
    //Todo:クラス化
    if([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:kBeaconUUID];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID major:41291 minor:39935 identifier:kIdentifier];
        
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.ownerAnimationView startCanvasAnimation];
    [self.participantAnimationView startCanvasAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

#pragma mark Beacon
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
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    //有効なbeaconを取り出す
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"proximity != %d", CLProximityUnknown];
    NSArray *validBeacons = [beacons filteredArrayUsingPredicate:predicate];
    CLBeacon *beacon = validBeacons.firstObject;
    
    if ([beacon.major isEqualToNumber:@41291]) {
        NSLog(@"----->call");
        [self updateIconPositionForDistance:beacon.proximity];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"error:%@",error);
}

- (void)enterRegion
{
    NSLog(@"enter");
}



- (IBAction)closeView:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateIconPositionForDistance:(float)distance
{
    float step = (self.view.frame.size.height - 100)/ 20 ;
    int newY = 100 + (distance * step);
    [self.participantIcon setCenter:CGPointMake(self.participantIcon.center.x, newY)];
}

@end
