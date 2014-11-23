//
//  GXStatusViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/06.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXStatusViewController.h"
#import "GXAppDelegate.h"
#import "GXNavViewController.h"
#import "GXQuestViewController.h"
#import "GXInviteQuestViewController.h"
#import "GXJoinedQuestViewController.h"
#import "GXActivityViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "GXStatusViewCell.h"
#import "GXBeacon.h"
#import "GXBeaconRegion.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"

#define kBeaconUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define kIdentifier @"Estimote"

@interface GXStatusViewController ()<GXBeaconDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *locationStatusLable;
@property (weak, nonatomic) IBOutlet UILabel *bluetoothStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *monitoringStatusLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *usrNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLable;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *rankProgress;


@property NSMutableArray *joinedQuestArray;

@property GXBeacon *beacon;
@property GXBeaconMonitoringStatus monitoringStatus;
@property (nonatomic) NSUUID *proximityUUID;

@property KiiObject *gxUser;

@end

@implementation GXStatusViewController{
    CLProximity _privProximity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.rankProgress configureFlatProgressViewWithTrackColor:[UIColor silverColor] progressColor:[UIColor alizarinColor]];
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 40.f;
    self.iconImageView.layer.borderColor = [UIColor turquoiseColor].CGColor;
    self.iconImageView.layer.borderWidth = 3.0f;
    self.iconImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.iconImageView.layer.shouldRasterize = YES;
    self.iconImageView.clipsToBounds = YES;
    self.usrNameLabel.text = @"name";
    self.usrNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    self.usrNameLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    self.pointLable.font = [UIFont boldFlatFontOfSize:15];
    self.pointLable.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    self.rankLabel.font = [UIFont boldFlatFontOfSize:15];
    self.rankLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];

    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.iconImageView.profileID = [ud stringForKey:@"fb_id"];
    self.usrNameLabel.text = [ud stringForKey:@"usr_name"];
    
//    int currPoint = [[GXUserManager sharedManager] getUserPoint];
//    int currRank = [[GXUserManager sharedManager] getUserRank];
//    self.pointLable.text = [NSString stringWithFormat:@"%dpt",currPoint];
//    self.rankLabel.text = [NSString stringWithFormat:@"%d",currRank];
//    [self.rankProgress setProgress:0.2 animated:YES];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma makr - tableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = @"FriendsOnline";
    label.font = [UIFont boldFlatFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GXNavViewController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        GXQuestViewController *questViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"home"];
        navController.viewControllers = @[questViewController];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        GXInviteQuestViewController *inviteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"invite"];
        navController.viewControllers = @[inviteViewController];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        GXJoinedQuestViewController *joinedView = [self.storyboard instantiateViewControllerWithIdentifier:@"joined"];
        navController.viewControllers = @[joinedView];
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        GXActivityViewController *activityView = [self.storyboard instantiateViewControllerWithIdentifier:@"activityView"];
        navController.viewControllers = @[activityView];
    }
    
    self.frostedViewController.contentViewController = navController;
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView DataSouce

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXStatusViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        NSArray *titles = @[@"クエスト一覧",@"募集中のクエスト",@"参加中のクエスト",@"みんなの動き"];
        cell.textLabel.text = titles[indexPath.row];
    } else {
        NSArray *titles = @[@"userA",@"userB",@"userC"];
        cell.textLabel.text = titles[indexPath.row];
    }
    
    return cell;
}

- (void)configureCell:(GXStatusViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *obj = self.joinedQuestArray[indexPath.row];
    cell.title = [obj getObjectForKey:quest_title];
}


#pragma mark - Gxbeacon Delegate
//レンジングが開始されると呼ばれる
- (void)didRangeBeacons:(GXBeaconRegion *)region
{
    
}

//location(位置情報関連)の設定状況
- (void)didUpdateLocationStatus:(NSString *)status
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"Location:"];
    [string appendString:status];
    self.locationStatusLable.text = string;
}

//bluetooth設定状況
- (void)didUpdatePeripheralState:(NSString *)state
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"Bluethooth:"];
    [string appendString:state];
    self.bluetoothStatusLabel.text = string;
}

//モニタリングのステータス
- (void)didUpdateMonitoringStatus:(GXBeaconMonitoringStatus)status
{
    self.monitoringStatus = status;
    
    switch (status) {
        case kGXBeaconMonitoringStatusDisabled:
            self.monitoringStatusLabel.text = @"Disable";
            break;
            
        case kGXBeaconMonitoringStatusStopped:
            self.monitoringStatusLabel.text = @"Stop";
            break;
            
        case kGXBeaconMonitoringStatusMonitoring:
            self.monitoringStatusLabel.text = @"Monitoring";
            break;
            
        default:
            break;
    }
}

#pragma mark - データフェッチ
- (void)fetchOnePersonQuest
{
    [[GXBucketManager sharedManager] getJoinedOnePersonQuest];
}

- (void)fetchMultiPersonQuest
{
    [[GXBucketManager sharedManager] getJoinedMultiPersonQuest];
}

#pragma mark - Notification


@end
