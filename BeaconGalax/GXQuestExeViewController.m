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
@property KiiGroup *questGroup;
@property KiiBucket *questMemberBucket;

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

    self.readyButton.backgroundColor = [UIColor clearColor];
    self.readyButton.layer.cornerRadius = 5.0f;
    self.readyButton.layer.borderColor = [UIColor colorWithComplementaryFlatColorOf:FlatWatermelon].CGColor;
    self.readyButton.layer.borderWidth = 1.0f;
    [self.readyButton setTitleColor:[UIColor colorWithComplementaryFlatColorOf:FlatWatermelon] forState:UIControlStateNormal];
    self.readyButton.alpha = 0.0f;
    
    self.statusLabel.textColor = [UIColor colorWithComplementaryFlatColorOf:FlatWatermelon];
    self.statusLabel.text = @"beacon検出中...";
    
//    //beacon
//    self.beacon = [GXBeacon sharedManager];
//    self.beacon.delegate = self;
//    GXBeaconRegion *region = [self.beacon registerRegion:kBeaconUUID identifier:kIdentifier];
//    if (region) {
//        region.rangingEnabled = YES;
//    }
    
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

        self.isOwner = true;
        
    } else {
     
        self.isOwner = false;
    }
    
    [self configureUI:self.isOwner];
    
    //GroupMemberFetch
    [[GXGroupManager sharedManager] getGroup:self.exeQuest];
    
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

- (void)configureUI:(BOOL)isOwner
{
    if (isOwner) {
        self.messageLabel.text = @"メンバーを揃えよう";
        [self.readyButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.readyButton bk_addEventHandler:^(id sender) {
            
        } forControlEvents:UIControlEventTouchUpInside];
        
    }else {
        self.messageLabel.text = @"リーダの近くに集まれ";
        [self fadeIn];
        [self.readyButton setTitle:@"Ready" forState:UIControlStateNormal];
        [self.readyButton bk_addEventHandler:^(id sender) {
            [self readyAction];
        } forControlEvents:UIControlEventTouchUpInside];
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

- (void)beaconAnimation
{
    //ibeacon的演出
    PulsingHaloLayer *haloLayer = [PulsingHaloLayer layer];
    haloLayer.position = self.ownerIcon.center;
    haloLayer.radius = 240.f;
    [self.view.layer insertSublayer:haloLayer below:self.ownerIcon.layer];

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
    NSNumber *number = [member getObjectForKey:user_isReady];
    NSLog(@"number:%@",number);
    BOOL isReady = [number boolValue];
    cell.userIconView.profileID = fbURI;
    cell.userNameLabel.text = name;
    
    if (isReady) {
        cell.userReadySignLabel.text = @"OK";
    } else {
        cell.userReadySignLabel.text = @"NO";
    }
    
}


#pragma mark Animation
- (void)fadeIn
{
    [UIView animateWithDuration:1.0f animations:^{
        self.readyButton.alpha = 1.0f;
    }];
}

#pragma mark - 参加者
- (void)readyAction
{
    //バケットにある自分の情報に準備OKフラグを書き込む
    NSMutableArray *results = [NSMutableArray new];
    NSString *currentUserURI  = [KiiUser currentUser].objectURI;
    
    KiiClause *clause = [KiiClause equals:user_uri value:currentUserURI];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    KiiQuery *nextQuery;
    NSError *error;
    
    NSArray *result = [self.questMemberBucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    
    if (!error) {
        [results addObjectsFromArray:result];
        NSLog(@"resultsカウント %d",results.count);
    } else{
        NSLog(@"eeror:%@",error);
    }
    
    if (results.count == 1) {
        NSLog(@"自分の情報を更新");
        KiiObject *me = results.firstObject;
        [me refreshSynchronous:&error];
        [me setObject:@YES forKey:@"isReady"];
        [me saveSynchronous:&error];
        
        if (!error) {
            NSLog(@"情報を更新完了");
            [[GXGroupManager sharedManager] getGroup:self.exeQuest];
        }
    }
}

- (void)startAction
{
    int cnt = 0;
    
    for (KiiObject *obj in self.memberArray) {
        NSNumber *num = [obj getObjectForKey:user_isReady];
        bool isready = [num boolValue];
        
        if (isready) cnt++;
    }
    
    if (cnt == self.memberArray.count) {
        
        //クエストスタート処理
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"確認" message:@"クエストを開始します" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action  = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //なんかする
        }];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark Notification Handler
- (void)memberFetchedHandler:(NSNotification *)notis
{
    self.questGroup = notis.object;
    self.questMemberBucket = [self.questGroup bucketWithName:@"member"];
    //このバケットから全メンバーを取り出す
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [self.questMemberBucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        NSLog(@"results:%@",results);
        self.memberArray = [NSMutableArray arrayWithArray:results];
        [self.tableView reloadData];

    }];
    
}


@end
