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
#import "GXHomeRootViewController.h"
#import "GXSettingTableViewController.h"
#import "GXInviteQuestViewController.h"
#import "GXJoinedQuestViewController.h"
#import "GXActivityViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "GXStatusViewCell.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"
#import "GXUserDefaults.h"

#import "GXGoogleTrackingManager.h"


@interface GXStatusViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *usrNameLabel;



@property NSMutableArray *joinedQuestArray;

@property KiiObject *gxUser;

@end

@implementation GXStatusViewController{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor clearColor];
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDictionary *userInfo = [GXUserDefaults getUserInfomation];

    self.usrNameLabel.text = userInfo[@"GXUserName"];
    self.iconImageView.profileID = userInfo[@"GXFacebookID"];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    self.iconImageView.profileID = [ud stringForKey:@"fb_id"];
//    self.usrNameLabel.text = [ud stringForKey:@"usr_name"];
//    
//    int currPoint = [[GXUserManager sharedManager] getUserPoint];
//    int currRank = [[GXUserManager sharedManager] getUserRank];
//    self.pointLable.text = [NSString stringWithFormat:@"%dpt",currPoint];
//    self.rankLabel.text = [NSString stringWithFormat:@"%d",currRank];
//    [self.rankProgress setProgress:0.2 animated:YES];
    [GXGoogleTrackingManager sendScreenTracking:@"menuView"];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
        GXHomeRootViewController *homeRootView = [self.storyboard instantiateViewControllerWithIdentifier:@"root"];
        navController.viewControllers = @[homeRootView];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
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
        return 2;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXStatusViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        NSArray *titles = @[@"クエスト一覧",@"みんなの動き"];
        cell.textLabel.text = titles[indexPath.row];
    } else {
        NSArray *titles = @[@"userA",@"userB",@"userC"];
        cell.textLabel.text = titles[indexPath.row];
    }
    
    return cell;
}



@end
