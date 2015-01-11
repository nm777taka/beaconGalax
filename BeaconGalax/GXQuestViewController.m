//
//  GXQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/08.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//
/*
 クエストに関するメモ
 クエストタイプ
 type:1 (beaconで○○に近づけ系)
 type:2 (beaconに○○時間滞在系)
 
 */

//ViewController
#import "GXQuestViewController.h"
#import "GXHomeCollectionViewCell.h"
#import "GXQuestReadyViewController.h"
#import "GXInviteQuestViewController.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "GXNavViewController.h"
#import "GXQuestDetailViewController.h"
#import "GXQuestGroupViewController.h"
#import "GXHomeCollectionReusableView.h"
#import "GXEventViewController.h"

#import "GXPointManager.h"
#import "GXTopicManager.h"
#import <HMSegmentedControl.h>

#import "GXBucketManager.h"
#import "GXUserDefaults.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"
#import "FUIAlertView+GXTheme.h"

//Model
#import "GXQuest.h"
#import "GXQuestList.h"
#import "Device.h"

@interface GXQuestViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,FUIAlertViewDelegate,GXQuestListDelegate>

- (IBAction)createNewQuest:(id)sender;

@property (nonatomic,strong) GXQuestDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property KiiObject *selectedObject;
@property KiiGroup *selectedQuestGroup;
@property BOOL isSelectedQuestMulti;
@property NSInteger segmentIndex;
@property GXQuest *selectedQuest;
@property KiiObject *eventObject;
@property (nonatomic,strong) GXQuestList *questList;

- (IBAction)gotoEventAction:(id)sender;
- (IBAction)createQuest:(id)sender;

@property UIButton *addQuestButton;

@end

@implementation GXQuestViewController{
    UIRefreshControl *_refreshControl;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //どっからデータとってくるかのindex
    _segmentIndex = 0;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
//    UINib *sectionNib = [UINib nibWithNibName:@"HomeCollectionReusableView" bundle:nil];
//    [self.collectionView registerNib:sectionNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section"];
    
    //セルに表示するデータを管理してるクラスのインスタンス
    _questList = [[GXQuestList alloc] initWithDelegate:self]; //delegate設定(del先は俺やで）
    
    //refreshcontrolを追加
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
    
    //detailViewを取得
    self.detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    
    //ここでinfoトピックを購読してる(必要かどうか...?)
    [[GXTopicManager sharedManager] subscribeInfoTopic];
    
    //NavItem
    UIImage *image = [UIImage imageNamed:@"menu"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [button addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = navLeftButton;
    
    //eventUI
    self.eventTitleLabel.font = [UIFont boldFlatFontOfSize:15];
    self.eventTitleLabel.textColor = [UIColor whiteColor];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questFetched:) name:GXFetchQuestNotComplitedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredInvitedBoard:) name:GXRegisteredInvitedBoardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromLocalNotis:) name:GXRefreshDataFromLocalNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showInfo:) name:@"showInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questDeleted:) name:GXQuestDeletedNotification object:nil];
    //pageview
    [[GXPageViewAnalyzer shareInstance] setPageView:NSStringFromClass([self class])];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //questFetch
    [self request:0]; //new
    [self fetchEvent]; //eventをフェッチ

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return [_questList dailyQuestCount];
    } else {
        return [_questList count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GXHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0 ) {
        cell.quest = [_questList dailyQuestAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        cell.quest = [_questList questAtIndex:indexPath.row];
    }
    //modelの設定
    return cell;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        _selectedQuest = [_questList dailyQuestAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        _selectedQuest = [_questList questAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"gotoDetail" sender:self];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    GXHomeCollectionReusableView *sectionView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section" forIndexPath:indexPath];
    sectionView.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 0) {
        sectionView.sectionTitle.text = @"デイリークエスト";
    } else {
        sectionView.sectionTitle.text = @"みんなのクエスト";
    }
    return sectionView;
}

//協力型なのか個人でやるやつなのか判断

- (BOOL)isMultiQuest:(NSIndexPath *)indexPath
{
    GXQuest *quest = [_questList questAtIndex:indexPath.row];
    BOOL ret;
    if ([quest.player_num intValue] > 1) {
        ret = YES;
    } else {
        ret  = NO;
    }
    
    return ret;
}



#pragma  mark - refresh
- (void)refresh
{
    [self request:0];
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}

#pragma mark Button_Action
#pragma mark -- サーバーコードのテスト
- (IBAction)createNewQuest:(id)sender
{
    //[[GXBucketManager sharedManager] getQuestForQuestBoard];
    
    KiiServerCodeEntry* entry =[Kii serverCodeEntry:@"createQuest"];
    
    //実行時パラメータ
    NSDictionary *argDict = @{@"aaa":@"username",@"bbb":@"password"};
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
    NSError* error = nil;
    
    
    KiiServerCodeExecResult* result = [entry executeSynchronous:argument
                                                      withError:&error];
    
    // Parse the result.
    NSDictionary *returnedDict = [result returnedValue];
    NSString *returnString = [returnedDict objectForKey:@"returnedValue"];
    
    NSLog(@"%@",returnString);
}


#pragma mark segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"gotoDetail"]){
        GXQuestDetailViewController *vc = (GXQuestDetailViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
        vc.quest = _selectedQuest;
    } else if ([segue.identifier isEqualToString:@"gotoEvent"]) {
        GXEventViewController *vc = segue.destinationViewController;
        vc.eventData = self.eventObject;
    }
}

#pragma mark - Notification

- (void)questDeleted:(NSNotification *)info
{
    [self request:0]; //更新するよ
    CWStatusBarNotification *notis = [CWStatusBarNotification new];
    notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
    [notis displayNotificationWithMessage:@"削除完了" forDuration:2.0f];
}
- (void)showInfo:(NSNotification *)info
{
    GXHomeCollectionViewCell *cell = info.object;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    if (self.detailViewController) {
        self.detailViewController.quest = [_questList questAtIndex:indexPath.row];
        [self.view addSubview:self.detailViewController.view];
    }
}

- (void)questFetched:(NSNotification *)info
{
    [self request:0];
    [SVProgressHUD dismiss];
}

- (void)registeredInvitedBoard:(NSNotification *)notis
{
    CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationStyle = CWNotificationStyleNavigationBarNotification;
    [notification displayNotificationWithMessage:@"募集完了" forDuration:2.0f];
    
}

- (void)deletedQuest:(NSNotification *)notis
{
    [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
    [self.collectionView reloadData];
}

- (void)refreshFromLocalNotis:(NSNotification *)notis
{
    [SVProgressHUD showWithStatus:@"データ更新中"];
    [self request:0];
}

- (void)gotoMemberView:(NSNotification *)notis
{
    NSLog(@"ok---->");
    _selectedObject = notis.object;
    _selectedQuestGroup = [KiiGroup groupWithURI:[_selectedObject getObjectForKey:quest_groupURI]];
    [_selectedQuestGroup refreshWithBlock:^(KiiGroup *group, NSError *error) {
        if (error) {
            NSLog(@"group refresh error:%@",error);
        } else {
            [self performSegueWithIdentifier:@"goto_QuestMemberView" sender:self];
        }
    }];
}

- (void)gotoQuestReadyView:(NSNotification *)notis
{
    _selectedObject = notis.object;
    _selectedQuestGroup = [KiiGroup groupWithURI:[_selectedObject getObjectForKey:quest_groupURI]];
    [_selectedQuestGroup refreshWithBlock:^(KiiGroup *group, NSError *error) {
        if (error) {
            NSLog(@"group refresh error:%@",error);
        } else {
            [self performSegueWithIdentifier:@"gotoQuestReadyView" sender:self];
        }
    }];

}

#pragma mark-


- (UIStatusBarStyle)preferredStatusBarStyle {
    return StatusBarContrastColorOf((UIColor *)FlatLime);
}

- (void)questAlertShow:(NSString *)title description:(NSString *)description
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:title
                                                          message:[self.selectedObject getObjectForKey:quest_description]
                                                         delegate:nil cancelButtonTitle:@"やめる"
                                                otherButtonTitles:@"受注する", nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    alertView.delegate = self;
    alertView.tag = 0;
    [alertView show];

}

- (void)invitedMultiQuestAlert{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"協力クエスト"
                                                          message:[self.selectedObject getObjectForKey:quest_description]
                                                         delegate:nil cancelButtonTitle:@"やめる"
                                                otherButtonTitles:@"参加画面へ", nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    alertView.delegate = self;
    alertView.tag = 1;
    [alertView show];

}

- (void)notInviteMultiQuestAlert
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"リーダーとして参加者を募集"
                                                          message:[self.selectedObject getObjectForKey:quest_description]
                                                        delegate:nil cancelButtonTitle:@"やめる"
                                               otherButtonTitles:@"募集する", nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    alertView.delegate = self;
    alertView.tag = 2;
    [alertView show];
}


////クエストチェック(すでに募集済みのものがあるか)
- (BOOL)isAlreadyInvitedQuest:(NSString *)questTitle
{
    BOOL ret;
    [SVProgressHUD showWithStatus:@"処理中"];
    
    KiiBucket *bucket = [GXBucketManager sharedManager].inviteBoard;
    KiiClause *clause = [KiiClause equals:quest_title value:questTitle];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    NSError *error;
    KiiQuery *nextQuery;
    NSArray *results = [bucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    if (error) {
        CWStatusBarNotification *notis = [CWStatusBarNotification new];
        notis.notificationLabelBackgroundColor = [UIColor redColor];
        [notis displayNotificationWithMessage:@"通信エラー" forDuration:2.0f];
    } else {
        
        if (results.count == 0) {
            ret = NO;
        } else {
            ret = YES;
        }
    }
    
    [SVProgressHUD dismiss];
    
    return ret;
    
}

- (void)request:(NSInteger)index
{
    if (_questList.loading) {
    } else {
        [SVProgressHUD showWithStatus:@"データ更新中"];
        [[GXBucketManager sharedManager] countNotJoinBucket];
        [_questList requestAsyncronous:index];
    }
}

#pragma makr - QuestList delegate
- (void)questListDidLoad
{
    [_collectionView reloadData];
    [SVProgressHUD dismiss];
}

- (void)addQuest:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"gotoCreateView" sender:self];
}

#pragma mark BarButton + Badge
- (void)buttonPress
{
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)gotoEventAction:(id)sender {
    [self performSegueWithIdentifier:@"gotoEvent" sender:self];
}

- (IBAction)createQuest:(id)sender {
    [self performSegueWithIdentifier:@"gotoCreateView" sender:self];
}

#pragma mark - Event
- (void)fetchEvent
{
    KiiBucket *bucket = [Kii bucketWithName:@"Event"];
    KiiClause *clause = [KiiClause equals:@"isCompleted" value:@NO];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            self.eventObject = results.firstObject;
            [self updateEventUI];
        }
    }];
}

- (void)updateEventUI
{
    KiiObject *eventDate = self.eventObject;
    self.eventTitleLabel.text = [eventDate getObjectForKey:@"title"];
}
@end
