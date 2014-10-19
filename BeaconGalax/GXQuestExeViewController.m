//
//  GXQuestExeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/18.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestExeViewController.h"
#import <objc/runtime.h>
#import "GXQuestCompleteViewController.h"
#import "GXClearViewController.h"
#import "GXBeacon.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"

static const char kAssocKey_Window;

@interface GXQuestExeViewController ()<ESTBeaconDelegate,ESTBeaconManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *questTitle;
@property (weak, nonatomic) IBOutlet UILabel *proxLabel;
@property (weak, nonatomic) IBOutlet UILabel *accLabel;
@property (weak, nonatomic) IBOutlet UIImageView *beaconImage;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView; //全体(クエストの進捗)
@property (weak, nonatomic) IBOutlet UAProgressView *userProgressView;
@property (nonatomic,assign) BOOL paused;
@property (nonatomic,assign) float localQuestProgress;
@property (nonatomic,assign) float localUserProgress;
@property NSTimer *userTimer;
@property BOOL isCommited;

@property ESTBeaconManager *beaconManager;
@property ESTBeaconRegion *beaconRegion;
@property CLBeaconMajorValue subjectBeaconMajor;
@property NSUUID *uuid;

@property BOOL isShowCompleteView;

@end

@implementation GXQuestExeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.uuid = [[NSUUID alloc]initWithUUIDString:kBeaconUUID];
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    self.isCommited = NO;
    [self configureUserProgress];
    [self configureQuestProgress];
    
    PulsingHaloLayer *halo = [PulsingHaloLayer layer];
    halo.position = self.beaconImage.center;
    halo.backgroundColor = FlatWatermelon.CGColor;
    halo.radius = 240.0f;
    [self.view.layer insertSublayer:halo below:self.beaconImage.layer];

    
    //notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questEndHandler:) name:GXEndQuestNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questCommitHandler:) name:GXCommitQuestNotification object:nil];
    
}

- (void)configureUserProgress
{
    self.paused = YES;
    self.userProgressView.tintColor = [UIColor colorWithRed:5/255.0 green:204/255.0 blue:197/255.0 alpha:1.0];
    self.userProgressView.borderWidth = 2.0f;
    self.userProgressView.lineWidth = 2.0f;
    self.userProgressView.fillOnTouch = YES;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 32.0)];
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:32];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = self.userProgressView.tintColor;
    textLabel.text = @"0%";
    self.userProgressView.centralView = textLabel;
    
    self.userProgressView.fillChangedBlock = ^(UAProgressView *progressView,BOOL filled, BOOL animated){
        UIColor *color = (filled ? [UIColor whiteColor] : progressView.tintColor);
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                [(UILabel *)progressView.centralView setTextColor:color];
            }];
        } else {
            [(UILabel *)progressView.centralView setTextColor:color];
        }
    };
    
    self.userProgressView.progressChangedBlock = ^(UAProgressView *progressView,float progress){
        [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%",progress * 100]] ;
        
        if ((progress*100) == 0) {
            NSLog(@"完了");
            [self.userTimer invalidate];
            [(UILabel *)progressView.centralView setText:@"OK"];
            [self commitQuest];
        }
        
    };
    
    self.userProgressView.didSelectBlock = ^(UAProgressView *progressView){
        _paused = !_paused;
    };
    
    [self startUserTimer];

}

- (void)startUserTimer
{
    if (![self.userTimer isValid]) {
        
        self.userTimer =  [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateUserProgress:) userInfo:nil repeats:YES];
    }
    
}

- (void)configureQuestProgress
{
    self.paused = YES;
    self.progressView.tintColor = FlatWatermelon;
    self.progressView.borderWidth = 2.0f;
    self.progressView.lineWidth = 2.0f;
    self.progressView.fillOnTouch = YES;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 32.0)];
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:27];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = self.progressView.tintColor;
    self.progressView.centralView = textLabel;
    
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
            [NSTimer bk_scheduledTimerWithTimeInterval:3.0 block:^(NSTimer *timer) {
                [self gotoClearView];
            } repeats:NO];
        }
    };
    
    self.progressView.didSelectBlock = ^(UAProgressView *progressView){
        _paused = !_paused;
    };

}

- (void)updateUserProgress:(NSTimer *)timer{
    if (!_paused) {
        _localUserProgress = ((int)((_localUserProgress * 100.0f) + 1.01) %100) / 100.0f;
        [self.userProgressView setProgress:_localUserProgress];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
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
                if (_paused) {
                    _paused = NO;
                }
                break;
                
            case CLProximityNear:
                if (!_paused) _paused = YES;

                self.proxLabel.text = @"近い";
                break;
                
            case CLProximityFar:
                if (!_paused) _paused = YES;
                self.proxLabel.text = @"遠い";
                break;
                
            default:
                break;
        }
    }
}

- (void)stopBeacon
{
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

#pragma mark - 遷移

#pragma mark - Notification

- (void)questCommitHandler:(NSNotification *)notis
{
    NSError *error;
    [self fetchGroupQuest]; //更新をフェッチ
    
    int success_cnt = [[self.exeQuest getObjectForKey:quest_success_cnt] intValue];
    NSArray *members = [self.exeGroup getMemberListSynchronous:&error];
    int member_cnt = (int)members.count;
    int commitValue = 100 / member_cnt;
    int progressValue = commitValue *success_cnt;
    
    if (member_cnt == success_cnt) { //クリア
        //クリア処理
        //無理やり100%に(奇数とかのために)
        NSLog(@"clear");
        [self.progressView setProgress:1.0f animated:YES];
        return ;
    }
    
    _localQuestProgress = (float)progressValue / 100.0f;
    [self.progressView setProgress:_localQuestProgress animated:YES];

}

- (void)questEndHandler:(NSNotification *)notis
{
    [SVProgressHUD dismiss];
    [self gotoClearView];
}

- (void)commitQuest
{
    NSError *error;
    KiiBucket *bucket = [self.exeGroup bucketWithName:@"quest"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    KiiQuery *nextQuery;
    NSArray *result = [bucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    KiiObject *quest = result.firstObject;
    int succCnt = [[quest getObjectForKey:quest_success_cnt] intValue];
    succCnt++;
    NSNumber *newValue  = [NSNumber numberWithInt:succCnt];
    [quest setObject:newValue forKey:quest_success_cnt];
    [quest saveSynchronous:&error];
    if (!error) {
        
        [self sendCommitPush];
    }

}

- (void)fetchGroupQuest
{
    NSError *error;
    KiiBucket *bucket = [self.exeGroup bucketWithName:@"quest"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    KiiQuery *nextQuery;
    NSArray *result = [bucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    self.exeQuest = result.firstObject;

}

- (void)sendCommitPush
{
    NSError *error;
    KiiTopic *commitTopic = [self.exeGroup topicWithName:@"quest_commit"];
    KiiAPNSFields *apnesFields = [KiiAPNSFields createFields];
    KiiPushMessage *msg = [KiiPushMessage composeMessageWithAPNSFields:apnesFields andGCMFields:nil];
    [commitTopic sendMessageSynchronous:msg withError:&error];
    if (error) {
        NSLog(@"sendPushError:%@",error);
    } else {
        NSLog(@"コミットpush送信完了");
    }
    
}

- (void)sendClearPush
{
    NSError *error;
    KiiTopic *clearTopic = [self.exeGroup topicWithName:@"quest_end"];
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    KiiPushMessage *msg = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
    [clearTopic sendMessageSynchronous:msg withError:&error];
    if (error) {
        NSLog(@"sendPushError:%@",error);
        [SVProgressHUD showErrorWithStatus:@"push通知送信エラー"];
    } else {
        NSLog(@"クリアpush送信完了");
        [NSTimer bk_scheduledTimerWithTimeInterval:3.0 block:^(NSTimer *timer) {
            [SVProgressHUD dismiss];
        } repeats:NO];
    }
}


- (void)gotoClearView
{
    [self performSegueWithIdentifier:@"gotoClearView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoClearView"]) {
        
        GXClearViewController *vc = segue.destinationViewController;
        vc.point = 100;
    }
}


@end
