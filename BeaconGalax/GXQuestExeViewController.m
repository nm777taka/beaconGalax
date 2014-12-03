//
//  GXQuestExeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/18.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestExeViewController.h"
#import <objc/runtime.h>
#import "GXClearViewController.h"
#import "GXBeacon.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXGoogleTrackingManager.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kQuestTypeOne 0
#define kQuestTypeMulti 1


@interface GXQuestExeViewController ()<ESTBeaconDelegate,ESTBeaconManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *questTitle;
@property (weak, nonatomic) IBOutlet UILabel *proxLabel;
@property (weak, nonatomic) IBOutlet UILabel *accLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *targetUserIconView;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView; //全体(クエストの進捗)
@property (weak, nonatomic) IBOutlet UAProgressView *userProgressView;
@property (nonatomic,assign) BOOL paused;
@property (nonatomic,assign) float localQuestProgress;
@property (nonatomic,assign) float localUserProgress;
@property NSTimer *userTimer;

@property ESTBeaconManager *beaconManager;
@property ESTBeaconRegion *beaconRegion;
@property CLBeaconMajorValue subjectBeaconMajor;
@property NSUUID *uuid;

@property (weak, nonatomic) IBOutlet UILabel *questDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *questRequireLabel;

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
    
    self.targetUserIconView.layer.cornerRadius = 100.0f;
    
    [self configureUserProgress];
    [self configureQuestProgress];
    
    PulsingHaloLayer *halo = [PulsingHaloLayer layer];
    halo.position = self.targetUserIconView.center;
    halo.backgroundColor = FlatWatermelon.CGColor;
    halo.radius = 240.0f;
    [self.view.layer insertSublayer:halo below:self.targetUserIconView.layer];
    
    self.questTitle.font = [UIFont boldFlatFontOfSize:17];
    self.questDesLabel.font = [UIFont boldFlatFontOfSize:14];
    self.questRequireLabel.font = [UIFont boldFlatFontOfSize:14];
    
    self.userProgressView.fillOnTouch = NO;
    self.progressView.fillOnTouch = NO;
    
}


#pragma makr - ユーザプログレス

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
            [UIView animateWithDuration:1.0 animations:^{
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
            if (self.isMulti)
                [self commitQuest];
            else
                [self commitOnePersonQuest];
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
        
        self.userTimer =  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateUserProgress:) userInfo:nil repeats:YES];
    }
    
}

- (void)configureQuestProgress
{
    self.paused = YES;
    self.progressView.tintColor = FlatWatermelon;
    self.progressView.borderWidth = 2.0f;
    self.progressView.lineWidth = 2.0f;
    self.progressView.fillOnTouch = NO;
    
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
            [NSTimer bk_scheduledTimerWithTimeInterval:2.0 block:^(NSTimer *timer) {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questCommitHandler:) name:GXCommitQuestNotification object:nil];
    [self questParse];
    [self startBeacon];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [GXGoogleTrackingManager sendScreenTracking:@"questExeView"];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];

}

- (void)questParse
{
    self.questTitle.text = [self.exeQuest getObjectForKey:quest_title];
    [self.questTitle sizeToFit];
    self.questDesLabel.text = [self.exeQuest getObjectForKey:quest_description];
    [self.questDesLabel sizeToFit];
    self.questRequireLabel.text = [self.exeQuest getObjectForKey:quest_requirement];
    [self.questRequireLabel sizeToFit];
    //self.targetUserIconView.profileID = [self.exeQuest getObjectForKey:quest_owner_fbid];
    //userbeaconから紐付いたやつを持ってくる(targetのbeaconから)
    
}
- (void)startBeacon
{
    CLBeaconMajorValue major = [[self.exeQuest getObjectForKey:@"major"] intValue];
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:self.uuid major:major identifier:@"estimote"];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];

}

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
    NSLog(@"enterrrrrrrrrrrr");
//    NSError *error;
//    //[self fetchGroupQuest]; //更新をフェッチ(最新の状態にする)
//    
//    int success_cnt = [[self.exeQuest getObjectForKey:quest_success_cnt] intValue];
//    NSArray *members = [self.exeGroup getMemberListSynchronous:&error];
//    int member_cnt = (int)members.count;
//    int commitValue = 100 / member_cnt;
//    int progressValue = commitValue *success_cnt;
//    
//    NSLog(@"mem_cnt:%d",member_cnt);
//    NSLog(@"suc_cnt:%d",success_cnt);
//    
//    if (member_cnt == success_cnt) { //クリア
//        //クリア処理
//        //無理やり100%に(奇数とかのために)
//        NSLog(@"clear");
//        [self.progressView setProgress:1.0f animated:YES];
//        return ;
//    }
//    
//    //_localQuestProgress = (float)progressValue / 100.0f;
//    
//   // [self.progressView setProgress:_localQuestProgress animated:YES];
    
//    [self.exeQuest refreshWithBlock:^(KiiObject *object, NSError *error) {
//        if(error) NSLog(@"error");
//        else {
//            NSLog(@"suc_cnt:%@",[object getObjectForKey:quest_success_cnt]);
//            NSString *suc_cnt = [[object getObjectForKey:quest_success_cnt] stringValue];
//            NSString *member_cnt = [NSString stringWithFormat:@"%d",self.groupMemberNum];
//            
//            if ([suc_cnt isEqualToString:member_cnt]){
//                NSLog(@"クリア");
//                [self.progressView setProgress:1.0f animated:YES];
//            }
//        }
//    }];
    
    //ここにきた時点でクリアなのでクリアシーケンスに入るよ
    [self.progressView setProgress:1.0f animated:YES];
    
}

- (void)questEndHandler:(NSNotification *)notis
{
    [self gotoClearView];
}


//一人用
- (void)commitOnePersonQuest
{
    [GXGoogleTrackingManager sendEventTracking:@"Quest" action:@"oneQuestCommit" label:@"一人用クエストコミット" value:nil screen:@"questExeView"];
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

//協力型のクエスト
- (void)commitQuest
{
    [GXGoogleTrackingManager sendEventTracking:@"Quest" action:@"multiQuestCommit" label:@"協力クエストコミット" value:nil screen:@"questExeView"];
    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"commitGroupQuest"];
    NSDictionary* argDict= [NSDictionary dictionaryWithObjectsAndKeys:
                            self.exeQuest.objectURI,@"questURI",self.exeGroup.objectURI,@"groupURI",[NSNumber numberWithInt:self.groupMemberNum],@"memberNum",nil];
    
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
    
    NSError *error = nil;
    [entry execute:argument withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
        NSDictionary *returendDict = [result returnedValue];
        NSLog(@"returnd:%@",returendDict);
    }];
    
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
        vc.group = self.exeGroup;
        vc.quest = self.exeQuest;
    }
}


@end
