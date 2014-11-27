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
#import "GXDescriptionViewController.h"
#import "GXInviteQuestViewController.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "GXNavViewController.h"
#import "GXQuestDetailViewController.h"
#import "GXQuestGroupViewController.h"

#import <HMSegmentedControl.h>

#import "GXBucketManager.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"

//Model
#import "GXQuest.h"
#import "GXQuestList.h"

@interface GXQuestViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,FUIAlertViewDelegate,GXQuestListDelegate>

- (IBAction)createNewQuest:(id)sender;

@property (nonatomic,strong) GXQuestDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSArray *textArray;
@property NSMutableArray *objects;
@property KiiObject *selectedObject;
@property KiiGroup *selectedQuestGroup;
@property BOOL isSelectedQuestMulti;
@property NSInteger segmentIndex;
@property HMSegmentedControl *segmentedControl;

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
    
    _questList = [[GXQuestList alloc] initWithDelegate:self]; //delegate設定(del先は俺やで）
    
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
    
    //segumentControl
    _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"新しい",@"受注済み",@"募集中"]];
    _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.frame = CGRectMake(0, topOffset, 320, 50);
    _segmentedControl.selectionIndicatorHeight = 4.0f;
    _segmentedControl.backgroundColor = [UIColor turquoiseColor];
    _segmentedControl.textColor = [UIColor cloudsColor];
    _segmentedControl.selectionIndicatorColor = [UIColor greenSeaColor];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    _segmentedControl.selectedSegmentIndex = HMSegmentedControlNoSegment;
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentedControl.shouldAnimateUserSelection = YES;
    [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentedControl];
    
    self.detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    
    [self.questList requestAsyncronous:_segmentIndex];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![KiiUser loggedIn]) {
        //ログイン画面へ遷移
        [self performSegueWithIdentifier:@"gotoLoginView" sender:self];
        
        
    } else {
        //DBからフェッチ(非同期)
        //最終的に変更があった場合のみにしたい
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questFetched:) name:GXFetchQuestNotComplitedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinQuestHandler:) name:GXQuestJoinNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredInvitedBoard:) name:GXRegisteredInvitedBoardNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletedQuest:) name:@"deleteQuest" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromLocalNotis:) name:GXRefreshDataFromLocalNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoMemberView:) name:@"gotoMemberView" object:nil];
        

    }
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
//    self.selectedObject = self.objects[indexPath.row];
//    
//    if ([[self.selectedObject getObjectForKey:quest_player_num] intValue] > 1) {
//        //invite_boardへ
//        //すでに募集済みかどうか
//        BOOL ret = [[GXBucketManager sharedManager] isInvitedQuest:self.selectedObject];
//        
//        if (ret) {
//            NSLog(@"募集済みです");
//            [self invitedMultiQuestAlert];
//            
//            
//        } else {
//            NSLog(@"募集されてません");
//            [self notInviteMultiQuestAlert];
//        }
//        
//    } else {
//        
//        
//        [self questAlertShow:[self.selectedObject getObjectForKey:quest_title] description:quest_description];
//        
//    }
    if (self.detailViewController) {
        self.detailViewController.quest = [_questList questAtIndex:indexPath.row];
        [self.view addSubview:self.detailViewController.view];
    }
}


//協力型なのか個人でやるやつなのか判断
- (BOOL)isMultiQuest:(NSIndexPath *)indexPath
{
    BOOL ret = false;
    KiiObject *obj = self.objects[indexPath.row];
    int playerNum = [[obj getObjectForKey:quest_player_num] intValue];
    
    if (playerNum == 1) {
        //一人用
        ret = false;
    } else {
        ret = true;
    }
    
    return ret;
}


#pragma  mark - refresh
- (void)refresh
{
    NSLog(@"refresh");
    [self.questList requestAsyncronous:_segmentIndex];
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}

//カスタムcellクラスでタッチイベントを処理してる
- (void)joinQuestHandler:(NSNotification *)notification
{
    GXHomeCollectionViewCell *cell = notification.object;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    self.selectedObject = self.objects[indexPath.row];
    
    if ([[self.selectedObject getObjectForKey:quest_player_num] intValue] > 1) {
//        //invite_boardへ
//        //すでに募集済みかどうか
//        BOOL ret = [[GXBucketManager sharedManager] isInvitedQuest:self.selectedObject];
//        
//        if (ret) {
//            NSLog(@"募集済みです");
//            [self invitedMultiQuestAlert];
//            
//            
//        } else {
//            NSLog(@"募集されてません");
//            [self notInviteMultiQuestAlert];
//        }
        [self notInviteMultiQuestAlert];


    } else {
        
        
        [self questAlertShow:[self.selectedObject getObjectForKey:quest_title] description:quest_description];
     
    }
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
//    if ([[segue identifier] isEqualToString:@"gotoDescriptionView"]) {
//        GXDescriptionViewController *vc = segue.destinationViewController;
//        vc.object = _selectedObject;
//    }
    if ([[segue identifier] isEqualToString:@"goto_QuestMemberView"]) {
        
        GXQuestGroupViewController *vc = segue.destinationViewController;
        //選択されたクエストのグループとクエスト自体をパーティーViewに渡してあげる
        vc.selectedQuestGroup = _selectedQuestGroup;
        vc.willExeQuest = _selectedObject;
    }
}

#pragma mark - Notification

- (void)questFetched:(NSNotification *)info
{
    NSArray *array = info.object;
    self.objects = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
    
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
    [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
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
        case 0: // 一人用クエスト選択
            if (buttonIndex == 1) {
                [[GXBucketManager sharedManager] registerJoinedQuest:self.selectedObject];
                [[GXBucketManager sharedManager] deleteJoinedQuest:self.selectedObject];

            }
            break;
            
        case 1: //募集されてるクエスト
            //inviteに遷移
            if (buttonIndex == 1) {
                [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:^(NSTimer *timer) {
                    [self gotoInvitedView];
                } repeats:NO];
                
            }
            break;
            
        case 2: //募集するクエスト
            if (buttonIndex == 1) {
                
                [[GXBucketManager sharedManager] registerInviteBoard:self.selectedObject];
                [[GXBucketManager sharedManager] deleteJoinedQuest:self.selectedObject];

            }
            break;
            
        default:
            break;
    }

}

- (void)gotoInvitedView
{
    GXNavViewController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    GXInviteQuestViewController *invitedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"invite"];
    
    invitedVC.willDeleteObjAtNotJoin = self.selectedObject;
    
    navController.viewControllers = @[invitedVC];
    self.frostedViewController.contentViewController = navController;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
        case 1:
        case 2:
            [self request:segmentedControl.selectedSegmentIndex];
            break;
        default:
            break;
    }
}

- (void)request:(NSInteger)index
{
    if (_questList.loading) {
    } else {
        [_questList requestAsyncronous:index];
    }
}

#pragma makr - QuestList delegate
- (void)questListDidLoad
{
    NSLog(@"delegate");
    [_collectionView reloadData];
}



@end
