//
//  GXVisitQuestExeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/12.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//
#import <SVProgressHUD.h>
#import "GXVisitQuestExeViewController.h"
#import "GXClearViewController.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"


@interface GXVisitQuestExeViewController ()<ESTBeaconDelegate,ESTBeaconManagerDelegate>
@property (weak, nonatomic) IBOutlet UAProgressView *progressView;
@property (nonatomic) UILabel *progressCenterLabel;
@property ESTBeaconManager *beaconManager;
@property ESTBeaconRegion *beaconRegion;
@property NSUUID *uuid;

@property NSTimer *countDownTimer;
@property int limit;

@end

@implementation GXVisitQuestExeViewController

#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.uuid = [[NSUUID alloc] initWithUUIDString:kBeaconUUID];
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    CLBeaconMajorValue major = [[self.exeQuest getObjectForKey:@"major"] intValue];
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:self.uuid major:major identifier:@"estimote"];
    
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    
    
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkQuestProgress) userInfo:nil repeats:YES];
    //タイマーは別スレッドで動かす
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSDefaultRunLoopMode];
    
    //configure
    //progress
    self.progressView.borderWidth = 2.0f;
    self.progressView.lineWidth = 2.0f;
    self.progressView.fillOnTouch = NO;
    
    self.progressCenterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 32.0)];
    self.progressCenterLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:27];
    self.progressCenterLabel.textAlignment = NSTextAlignmentCenter;
    self.progressCenterLabel.textColor = self.progressView.tintColor;
    self.progressView.centralView = self.progressCenterLabel;
    
    self.progressView.fillChangedBlock = ^(UAProgressView *progressView,BOOL filled, BOOL animated){
        UIColor *color = (filled ? [UIColor whiteColor] : progressView.tintColor);
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                [(UILabel *)progressView.centralView setTextColor:color];
            }];
        } else {
            [(UILabel *)progressView.centralView setTextColor:color];
        }
    };
    
    self.progressView.progressChangedBlock = ^(UAProgressView *progressView,float progress){
        [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%",progress * 100]] ;
        
        if (progress * 100 == 100) {
            [(UILabel *)progressView.centralView setText:@"Clear"];
            [SVProgressHUD showSuccessWithStatus:@"クリア処理中"];
            [NSTimer bk_scheduledTimerWithTimeInterval:2.0 block:^(NSTimer *timer) {
                [self gotoClearView];
            } repeats:NO];
        }
    };

    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.beaconManager stopEstimoteBeaconDiscovery];
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
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

#pragma mark estBeaconDelegate
- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    ESTBeacon *closeBeacon;
    if (beacons.count > 0) {
        closeBeacon = beacons.firstObject;
        
        switch (closeBeacon.proximity) {
            case CLProximityImmediate:
                [self startTimer];
                
                break;
            case CLProximityNear:
            case CLProximityFar:
            case CLProximityUnknown:
                [self stopTimer];
                break;
            default:
                break;
        }
    }
}

- (void)startTimer
{
    //すでにうごいているか
    if (![self.countDownTimer isValid]) {
        [self.countDownTimer fire];
    }
}

- (void)stopTimer
{
    //動いていたら
    if ([self.countDownTimer isValid]) {
        [self.countDownTimer invalidate]; //止める
    }
}

//timer selector
//limitが
- (void)checkQuestProgress
{
    
    if (self.limit < 0) {
        [self.countDownTimer invalidate];
        //clear
        [self commitOnePersonQuest];
    } else {
        self.limit--;
        self.progressCenterLabel.text = [NSString stringWithFormat:@"%d",self.limit];
    }
}

#pragma mark QuestCommit
- (void)commitOnePersonQuest
{
    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"commitOnePersonQuest"];
    NSDictionary *argDict = [NSDictionary dictionaryWithObjectsAndKeys:self.exeQuest.objectURI,@"questURI", nil];
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
    NSError *error;
    KiiServerCodeExecResult *result = [entry executeSynchronous:argument withError:&error];
    NSDictionary *returnedDict = [result returnedValue];
    NSLog(@"returnd:%@",returnedDict);
    if ([[returnedDict[@"returnedValue"] stringValue] isEqualToString:@"0"]) {
        //クリア！
        [self.progressView setProgress:1.0f animated:YES];
        
    }

}

- (void)commitMultiPersonQuest
{
    
}

#pragma mark - segue
- (void)gotoClearView
{
    [self performSegueWithIdentifier:@"gotoClearView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoClearView"]) {
        
        GXClearViewController *vc = segue.destinationViewController;
        vc.group = self.exeGroup;
        vc.quest = self.exeQuest;
    }
}

@end
