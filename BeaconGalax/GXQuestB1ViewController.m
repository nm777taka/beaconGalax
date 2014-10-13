//
//  GXQuestB1ViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/07.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestB1ViewController.h"
#import "GXClearViewController.h"
#import "GXBucketManager.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"
#import "GXBeacon.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"


@interface GXQuestB1ViewController ()<ESTBeaconDelegate,ESTBeaconManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *proxLabel;
@property (weak, nonatomic) IBOutlet UILabel *clearCntLabel;
@property (weak, nonatomic) IBOutlet UILabel *sucCntLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;


@property ESTBeaconManager *beaconManager;
@property ESTBeaconRegion *beaconRegion;
@property NSUUID *uuid;
@property CLBeaconMinorValue subjectBeaconMajor;

@end

@implementation GXQuestB1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    
    self.clearButton.layer.cornerRadius = 5.0;
    self.clearButton.layer.borderColor = [UIColor cyanColor].CGColor;
    self.clearButton.layer.borderWidth = 1.0;
    self.clearButton.alpha = 0.0f;
    
    self.uuid = [[NSUUID alloc] initWithUUIDString:kBeaconUUID];
    
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
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //アラート表示
    [self questParse];
    [self beaconStart];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)questParse
{
    self.titleLabel.text = [self.exeQuest getObjectForKey:quest_description];
    self.locationLabel.text = [self.exeQuest getObjectForKey:beacon_name];
    self.clearCntLabel.text = [NSString stringWithFormat:@"%d",[[self.exeQuest getObjectForKey:quest_clear_cnt] integerValue]];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)goBack:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//#pragma mark - Beacon
//- (void)didRangeBeacons:(GXBeaconRegion *)region
//{
//    NSLog(@"------------>");
//    CLBeacon *nearestBeacon = region.beacons.firstObject;
//    NSLog(@"nearestBeacon is %@",nearestBeacon.major);
//    
//    if ([nearestBeacon.major isEqualToNumber:self.subjectBeaconMajor]) {
//        
//        NSLog(@"OKKKKKK");
//    }
//}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    ESTBeacon *closetBeacon;
    if ([beacons count] > 0) {
        closetBeacon = beacons.firstObject;
        
        float acc = [closetBeacon.distance floatValue];
        NSMutableString *distance = [NSMutableString stringWithFormat:@"%f",acc];
        [distance appendString:@"m"];
        self.distanceLabel.text = distance;
        
        switch (closetBeacon.proximity) {
            case CLProximityImmediate:
                
                self.proxLabel.text = @"完璧！！";
                [self fadeInButton];
                
                break;
            case CLProximityNear:
                self.proxLabel.text = @"もっと近づいて";
                break;
                
            case CLProximityFar:
                self.proxLabel.text = @"遠いよ！";
                break;
                
            default:
                break;
        }
    }
}


- (void)fadeInButton
{
    [UIView animateWithDuration:0.5 animations:^{
        self.clearButton.alpha = 1.0f;
    }];
}

- (IBAction)clearAction:(id)sender {
    
    //[self performSegueWithIdentifier:@"gotoClearView" sender:self];
    
    [SVProgressHUD showWithStatus:@"クリア判定中"];
    BOOL isClear = [[GXBucketManager sharedManager] isClear:self.exeQuest];
    if (isClear) {
        [NSTimer bk_scheduledTimerWithTimeInterval:3.0f block:^(NSTimer *timer) {
            //
            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:@"gotoClearView" sender:self];
            
        } repeats:NO];

    }
    else {
        [NSTimer bk_scheduledTimerWithTimeInterval:3.0f block:^(NSTimer *timer) {
            //
            [SVProgressHUD dismiss];
            //alert
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"failure" message:@"クエスト失敗" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"failure" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        } repeats:NO];
    }

    
}

- (void)beaconStart
{
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:self.uuid major:55213 minor:51135 identifier:@"estimote"];
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"gotoClearView"]) {
        GXClearViewController *vc = segue.destinationViewController;
        vc.point = [[self.exeQuest getObjectForKey:quest_reward] intValue];
    }
}


@end
