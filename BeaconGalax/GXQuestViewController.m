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

#import "GXGoogleTrackingManager.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface GXQuestViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,FUIAlertViewDelegate,GXQuestListDelegate>

- (IBAction)createNewQuest:(id)sender;

@property (nonatomic,strong) GXQuestDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property KiiObject *selectedObject;
@property KiiGroup *selectedQuestGroup;
@property BOOL isSelectedQuestMulti;
@property NSInteger segmentIndex;
@property GXQuest *selectedQuest;
@property (nonatomic,strong) GXQuestList *questList;

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
    CGFloat topOffset = 0;
    _segmentIndex = 0;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self.view setTintColor:[UIColor blueColor]];
    
    topOffset = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
#endif

    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor sunflowerColor];
    
    _questList = [[GXQuestList alloc] initWithDelegate:self]; //delegate設定(del先は俺やで）
    
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
    
    self.detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    
    [[GXTopicManager sharedManager] subscribeInfoTopic];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questFetched:) name:GXFetchQuestNotComplitedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredInvitedBoard:) name:GXRegisteredInvitedBoardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromLocalNotis:) name:GXRefreshDataFromLocalNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showInfo:) name:@"showInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questDeleted:) name:GXQuestDeletedNotification object:nil];
    //questFetch
    [self request:0];
    [self.collectionView reloadData];
    //pageview
    [[GXPageViewAnalyzer shareInstance] setPageView:NSStringFromClass([self class])];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GXGoogleTrackingManager sendScreenTracking:@"NotJoinQuestView"];

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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%d:object",[_questList count]);
    return [_questList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GXHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    //modelの設定
    cell.quest = [_questList questAtIndex:indexPath.row];
    return cell;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedQuest = [_questList questAtIndex:indexPath.row];
    
    //協力型か一人かチェック
    if ([self isMultiQuest:indexPath]) {
        
        FUIAlertView *alert = [FUIAlertView questInviteAlertTheme];
        alert.delegate = self;
        alert.tag = 0;
        [alert show];
        
        
    } else {
        FUIAlertView *alert = [FUIAlertView questAcceptAlertTheme];
        alert.delegate = self;
        alert.tag = 1;
        [alert show];

    }
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
    NSLog(@"pull-refresh");
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
    if ([[segue identifier] isEqualToString:@"goto_QuestMemberView"]) {
        
        GXQuestGroupViewController *vc = segue.destinationViewController;
        //選択されたクエストのグループとクエスト自体をパーティーViewに渡してあげる
        vc.selectedQuestGroup = _selectedQuestGroup;
        vc.willExeQuest = _selectedObject;
    } else if ([[segue identifier] isEqualToString:@"gotoQuestReadyView"]) {
        GXQuestReadyViewController *vc = segue.destinationViewController;
        vc.willExeQuest = _selectedObject;
        vc.selectedQuestGroup = _selectedQuestGroup;
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


#pragma mark - FUIAlert
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0://invite
            if (buttonIndex == 1) {
                [self newQuestInviteSequence];
            }
            break;
            
        case 1: //accecpt
            if (buttonIndex == 1) {
                [self newQuestAcceptSequence];
            }
            break;
            
        default:
            break;
    }

}

- (void)newQuestAcceptSequence
{
    NSLog(@"accecptシーケンスを開始");
    [SVProgressHUD showWithStatus:@"クエスト受注中..."];
    GXQuest *quest = _selectedQuest;
    KiiObject *obj = [KiiObject objectWithURI:quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            NSLog(@"joinedBucketに登録します");
            [[GXBucketManager sharedManager] acceptNewQuest:object]; // だめじゃねこれ
            NSLog(@"notJoinから削除");
          //  [[GXBucketManager sharedManager] deleteJoinedQuest:object];
            [SVProgressHUD dismiss];
            
            CWStatusBarNotification *notis = [CWStatusBarNotification new];
            notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
            notis.notificationLabel.textColor = [UIColor cloudsColor];
            notis.notificationStyle = CWNotificationStyleNavigationBarNotification;
            [notis displayNotificationWithMessage:@"クエストを受注しました!" forDuration:2.0f];
            [self request:0]; //notjoinから更新するよ
            [GXGoogleTrackingManager sendEventTracking:@"Quest" action:@"accept" label:@"受注" value:nil screen:@"NotJoinQuestView"];
            
            [[GXActionAnalyzer sharedInstance] setActionName:GXQuestAccept];
        }
    }];
}

- (void)newQuestInviteSequence
{
    [SVProgressHUD showWithStatus:@"クエスト募集中..."];
    GXQuest *quest = _selectedQuest;
    KiiObject *obj = [KiiObject objectWithURI:quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if(!error) {
            [[GXBucketManager sharedManager] registerInviteBoard:object];
           // [[GXBucketManager sharedManager] deleteJoinedQuest:object];
            [SVProgressHUD dismiss];
            CWStatusBarNotification *notis = [CWStatusBarNotification new];
            notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
            notis.notificationLabel.textColor = [UIColor cloudsColor];
            notis.notificationStyle = CWNotificationStyleNavigationBarNotification;
            [notis displayNotificationWithMessage:@"クエストを募集しました!" forDuration:2.0f];
            [self request:0]; //notjoinから更新するよ
            [[GXBucketManager sharedManager] countInviteBucket];
            [GXGoogleTrackingManager sendEventTracking:@"Quest" action:@"invite" label:@"募集" value:nil screen:@"NotJoinQuestView"];
            [[GXPointManager sharedInstance] getInviteQuestPoint];
            [[GXActionAnalyzer sharedInstance] setActionName:GXQuestInvite];
        }
    }];
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
    NSLog(@"delegate");
    [_collectionView reloadData];
    NSUInteger objNum = [self.questList count];
    NSLog(@"objNum:%ld",objNum);
    [GXUserDefaults setCurrentNotJoinQuestNum:objNum];
    NSUInteger ret = [GXUserDefaults getCurrentNotJoinQuest];
    NSLog(@"%ld",ret);
    [SVProgressHUD dismiss];
    
    if (_questList.count == 0) {
    }
}



@end
