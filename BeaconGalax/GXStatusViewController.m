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
#import "GXSettingTableViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "GXQuestDetailViewController.h"

#import "GXStatusViewCell.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"
#import "GXUserDefaults.h"
#import "GXPointManager.h"
#import "NSObject+BlocksWait.h"

//model
#import "GXQuestList.h"
#import "GXQuest.h"


@interface GXStatusViewController ()<UITableViewDataSource,UITableViewDelegate,GXQuestListDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *usrNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLocationStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *rankProgressView;
@property (weak, nonatomic) IBOutlet UILabel *requirePointLabel;

@property (nonatomic,strong) GXQuestList *questList;
@property GXQuest *selectedQuest;
@property KiiObject *gxUser;

@end

@implementation GXStatusViewController{
    UIRefreshControl *_refreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //tableViwe
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //icon
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 40.f;
    self.iconImageView.layer.borderColor = [UIColor turquoiseColor].CGColor;
    self.iconImageView.layer.borderWidth = 3.0f;
    self.iconImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.iconImageView.layer.shouldRasterize = YES;
    self.iconImageView.clipsToBounds = YES;
    
    //name
    self.usrNameLabel.text = @"name";
    self.usrNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    self.usrNameLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    
    //status:online or offline
    self.userLocationStatusLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    self.userLocationStatusLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    
    //rank
    self.rankLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    self.rankLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    
    //progress
    [self.rankProgressView configureFlatProgressViewWithTrackColor:[UIColor sunflowerColor] progressColor:[UIColor cloudsColor]];
    self.rankProgressView.trackTintColor = [UIColor cloudsColor];
    self.rankProgressView.progressTintColor = [UIColor sunflowerColor];
    self.rankProgressView.transform = CGAffineTransformMakeScale(1.0, 2.0);
    
    //requirePoint
    self.requirePointLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.requirePointLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    
    //modelの設定
    self.questList = [[GXQuestList alloc] initWithDelegate:self];
    
    //refreshControl
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //udに保存しているユーザの基本情報を取得
    NSDictionary *userInfo = [GXUserDefaults getUserInfomation];
    self.usrNameLabel.text = userInfo[@"GXUserName"];
    self.iconImageView.profileID = userInfo[@"GXFacebookID"];
    
    //fetch
    [self request];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    KiiObject *gxuser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
    
    //ロケーション設定
    if (gxuser != nil) {
        NSString *locationState = [NSString stringWithFormat:@"Status:%@",[gxuser getObjectForKey:@"location"]];
        self.userLocationStatusLabel.text = locationState;
        BOOL isOnline = [[gxuser getObjectForKey:@"isOnline"] boolValue];
        
        //iconの色
        if (isOnline) self.iconImageView.layer.borderColor = [UIColor turquoiseColor].CGColor;
        else self.iconImageView.layer.borderColor = [UIColor grayColor].CGColor;
        
        //rank
        self.rankLabel.text = [NSString stringWithFormat:@"Rank : %@",[gxuser getObjectForKey:@"rank"]];
                            
        //requirePoint + progress
        NSDictionary *dict = [[GXPointManager sharedInstance] checkNextRank];
        NSNumber *nextPoint = dict[@"nextPoint"];
        NSNumber *curPoint = [gxuser getObjectForKey:@"point"];
        [self setProgress:[curPoint intValue] nextRequirePoint:[nextPoint intValue]];
    }
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgress:(int)curPoint nextRequirePoint:(int)nextReqPoint
{
    int reqPoint = nextReqPoint - curPoint;
    self.requirePointLabel.text = [NSString stringWithFormat:@"あと%dpt",reqPoint];
    [self.rankProgressView setProgress:(float)curPoint/(float)nextReqPoint animated:YES];
    
}

#pragma makr - tableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    
    if (section == 0) {
        label.text = @"受注済みのクエスト";
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        [view addSubview:label];
    } else if (section == 1) {
        label.text = @"作ったクエスト";
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        [view addSubview:label];
    }
    
    return view;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedQuest = [self.questList joinedQuestAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"gotoDetail" sender:self];
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
    NSInteger rows;
    if (section == 0) {
        rows = [self.questList joinedQuestCount];
    } else if(section == 1){
        rows = 0;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXStatusViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.quest = [self.questList joinedQuestAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
    }

    return cell;
}

#pragma data fetch
- (void)request
{
    if (self.questList.loading) {
    
    }else {
        [self.questList requestAsyncronous:1]; //1(magic number) 参加済みのクエスト
    }
}

#pragma makr - QuestList delegate
- (void)questListDidLoad
{
    [self.tableView reloadData];
}

#pragma mark - RefreshControlEvent
- (void)refresh:(UIRefreshControl *)sender
{
    //データの更新
    [self request];
    [NSObject performBlock:^{
        [_refreshControl endRefreshing];
    } afterDelay:1.0f];
    
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoDetail"]) {
        GXQuestDetailViewController *vc = (GXQuestDetailViewController *)[(UINavigationController *)[segue destinationViewController] topViewController];
        vc.quest = _selectedQuest;
    }
}


@end
