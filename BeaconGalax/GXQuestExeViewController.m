//
//  GXQuestExeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestExeViewController.h"
#import "GXBeacon.h"
#import "GXBeaconRegion.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXQuestExeViewController ()<GXBeaconDelegate>
@property (weak, nonatomic) IBOutlet FBProfilePictureView *ownerIcon;
@property (weak, nonatomic) IBOutlet UIView *joinedUserIcon;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

//クエスト要素
@property NSString *ownerName;
@property NSString *ownerFBID;
@property NSString *ownerURI;
@property NSString *questTitle;
@property NSNumber *isStarted;
@property NSNumber *isCompleted;
@property KiiGroup *questGroupURI;

@property BOOL isOwner;

//ビーコン関連
@property GXBeacon *beacon;
@property GXBeaconMonitoringStatus monitoringStatus;
@property (nonatomic) NSUUID *proximityUUID;


@end

@implementation GXQuestExeViewController

#pragma mark ViewLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //UI init
    self.ownerIcon.layer.cornerRadius = 50.f;
    self.ownerIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ownerIcon.layer.borderWidth = 1.f;
    self.joinedUserIcon.layer.cornerRadius = 50.f;
    self.joinedUserIcon.layer.borderWidth = 1.f;
    self.joinedUserIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    
    //beacon
    self.beacon = [GXBeacon sharedManager];
    self.beacon.delegate = self;
    GXBeaconRegion *region = [self.beacon registerRegion:kBeaconUUID identifier:kIdentifier];
    if (region) {
        region.rangingEnabled = YES;
    }
    
    //ibeacon的演出
    PulsingHaloLayer *haloLayer = [PulsingHaloLayer layer];
    haloLayer.position = self.ownerIcon.center;
    haloLayer.radius = 240.f;
    [self.view.layer insertSublayer:haloLayer below:self.ownerIcon.layer];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.beacon startMonitoring];
    [self parseObject:self.exeQuest];
    
    self.isOwner = false;
    //クエスト作成者か受注者でUIを変える
    if ([self.ownerURI isEqualToString:[KiiUser currentUser].objectURI]) {
        //作成者
        NSLog(@"作成者");
        self.isOwner = true;
        
    } else {
        //受注者
        NSLog(@"受注者");
        self.isOwner = false;
    }
    
    [self configureLabel:self.isOwner];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.beacon stopMonitoring];
}

- (void)parseObject:(KiiObject *)object
{
    self.questTitle = [object getObjectForKey:quest_title];
    self.ownerName = [object getObjectForKey:quest_createdUserName];
    self.ownerURI = [object getObjectForKey:quest_createUserURI];
    self.ownerIcon.profileID = [object getObjectForKey:quest_createdUser_fbid];
    self.questGroupURI = [object getObjectForKey:quest_groupURI];
    self.isStarted = [object getObjectForKey:quest_isStarted];
    self.isCompleted = [object getObjectForKey:quest_isCompleted];
    
}

- (void)configureLabel:(BOOL)isOwner
{
    if (isOwner) {
        self.messageLabel.text = @"あなたがクエストリーダーです\nクエスト参加者が全員集まったらクエスト開始ボタンを押してクエストを開始しましょう";
    }else {
        self.messageLabel.text = @"リーダの近くに集まりましょう";
    }
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
- (IBAction)goback:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GXBeacon 
- (void)didRangeBeacons:(GXBeaconRegion *)region
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"proximity != %d", CLProximityUnknown];
    NSArray *validBeacons = [region.beacons filteredArrayUsingPredicate:predicate];
    CLBeacon *beacon = validBeacons.firstObject;
    if ([beacon.major isEqualToNumber:@28319]) {
        NSLog(@"緑のbeakon");
        
        if (!self.isOwner) {
            
            switch (beacon.proximity) {
                case CLProximityFar:
                    self.statusLabel.text = @"遠いよ!もっと近くまでいこう";
                    break;
                case CLProximityNear:
                case CLProximityImmediate:
                    self.statusLabel.text = @"準備完了ボタンを押そう";
                    break;
                    
                default:
                    break;
            }
        }
    }
}


@end
