//
//  GXQuestExeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestExeViewController.h"
#import "GXQuestMemberCell.h"
#import "GXBeacon.h"
#import "GXBeaconRegion.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"
#import "GXGroupManager.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXQuestExeViewController ()<GXBeaconDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet FBProfilePictureView *ownerIcon;
@property (weak, nonatomic) IBOutlet UIView *joinedUserIcon;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *readyButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

//tabelView
@property (nonatomic,retain) NSMutableArray *memberArray;

@end

@implementation GXQuestExeViewController

#pragma mark ViewLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:self.view.frame andColors:@[FlatWatermelon,FlatWatermelonDark]];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithComplementaryFlatColorOf:FlatWatermelon];
    
    //UI init
    self.ownerIcon.layer.cornerRadius = 50.f;
    self.ownerIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ownerIcon.layer.borderWidth = 1.f;
    self.joinedUserIcon.layer.cornerRadius = 50.f;
    self.joinedUserIcon.layer.borderWidth = 1.f;
    self.joinedUserIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.readyButton.backgroundColor = [UIColor clearColor];
    self.readyButton.layer.cornerRadius = 5.0f;
    self.readyButton.layer.borderColor = [UIColor colorWithComplementaryFlatColorOf:FlatWatermelon].CGColor;
    self.readyButton.layer.borderWidth = 1.0f;
    [self.readyButton setTitleColor:[UIColor colorWithComplementaryFlatColorOf:FlatWatermelon] forState:UIControlStateNormal];
    self.readyButton.alpha = 0.0f;
    
    self.statusLabel.textColor = [UIColor colorWithComplementaryFlatColorOf:FlatWatermelon];
    self.statusLabel.text = @"beacon検出中...";
    
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
    
    //tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberFetchedHandler:) name:GXGroupMemberFetchedNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.beacon startMonitoring];
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
    
    //GroupMemberFetch
    [[GXGroupManager sharedManager] getQuestMember:self.exeQuest];
    
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
        self.messageLabel.text = @"メンバーを揃えよう";
        [self.readyButton setTitle:@"Start" forState:UIControlStateNormal];
    }else {
        self.messageLabel.text = @"リーダの近くに集まれ";
        [self.readyButton setTitle:@"Ready" forState:UIControlStateNormal];
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
                    self.statusLabel.text = @"遠い";
                    break;
                case CLProximityNear:
                case CLProximityImmediate:
                    self.statusLabel.text = @"準備完了!";
                    [self fadeIn];
                    [self.beacon stopMonitoring];
                    break;
                    
                default:
                    break;
            }
        } 
    }
}

#pragma makr - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.memberArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXQuestMemberCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GXQuestMemberCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *member = self.memberArray[indexPath.row];
    NSString *fbURI = [member getObjectForKey:user_fb_id];
    NSString *name = [member getObjectForKey:user_name];
    cell.userIconView.profileID = fbURI;
    cell.userNameLabel.text = name;
    
}


#pragma mark Animation
- (void)fadeIn
{
    [UIView animateWithDuration:1.0f animations:^{
        self.readyButton.alpha = 1.0f;
    }];
}
- (IBAction)readyAction:(id)sender {
    
    //
    
}

#pragma mark Notification Handler
- (void)memberFetchedHandler:(NSNotification *)notis
{
    NSMutableArray *array = notis.object;
    
    self.memberArray = [NSMutableArray arrayWithArray:array];
    
    [self.tableView reloadData];
}


@end
