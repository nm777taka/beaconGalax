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

#import "GXQuestViewController.h"
#import "GXHomeCollectionViewCell.h"
#import "GXDescriptionViewController.h"
#import "GXInviteQuestViewController.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "GXNavViewController.h"
#import "GXBucketManager.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"

@interface GXQuestViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,FUIAlertViewDelegate>

- (IBAction)createNewQuest:(id)sender;
@property GXDescriptionViewController *descriptionViewContoller;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSArray *textArray;
@property NSMutableArray *objects;
@property KiiObject *selectedObject;
@property BOOL isSelectedQuestMulti;
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
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    
    _objects = [NSMutableArray new];
    
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
    
    _descriptionViewContoller = [[self storyboard] instantiateViewControllerWithIdentifier:@"DescriptionView"];
    
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questFetched:) name:GXFetchQuestNotComplitedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinQuestHandler:) name:GXQuestJoinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(missionFetched:) name:GXFetchMissionWithNotCompletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredInvitedBoard:) name:GXRegisteredInvitedBoardNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletedQuest:) name:@"deleteQuest" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![KiiUser loggedIn]) {
        
        //ログイン画面へ遷移
        [self performSegueWithIdentifier:@"gotoLoginView" sender:self];
    } else {
        //DBからフェッチ(非同期)
        //最終的に変更があった場合のみにしたい
        [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
    }
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
    return self.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GXHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)configureCell:(GXHomeCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.masksToBounds = NO;
    cell.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    cell.layer.shadowOpacity = 0.1f;
    cell.layer.shadowRadius = 2.0f;
    
    KiiObject *quest = self.objects[indexPath.row];
    cell.titleLable.text = [quest getObjectForKey:quest_title];
    BOOL isMulti = [self isMultiQuest:indexPath];
    if (isMulti) {
        
        cell.createrName.text = @"システム";
        cell.questTypeIcon.image = [UIImage imageNamed:@"homeCellMulti.png"];
        cell.questTypeLabel.text = @"協力型クエスト";
        cell.questTypeColorView.backgroundColor = [UIColor amethystColor];
        
        
    } else {
        
        cell.createrName.text = @"システム";
        cell.questTypeLabel.text = @"一人クエスト";
        cell.questTypeIcon.image = [UIImage imageNamed:@"homeCellOne.png"];
        cell.questTypeColorView.backgroundColor = [UIColor turquoiseColor];
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
    [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}
#pragma mark Notification
- (void)questFetched:(NSNotification *)info
{
    NSArray *array = info.object;
    self.objects = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];

}

- (void)missionFetched:(NSNotification *)info
{
    NSArray *array = info.object;
    self.objects = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
}

//カスタムcellクラスでタッチイベントを処理してる
- (void)joinQuestHandler:(NSNotification *)notification
{
    GXHomeCollectionViewCell *cell = notification.object;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    self.selectedObject = self.objects[indexPath.row];
    NSLog(@"selected:%d",indexPath.row);
    
    if ([[self.selectedObject getObjectForKey:quest_player_num] intValue] > 1) {
        //invite_boardへ
        //すでに募集済みかどうか
        BOOL ret = [[GXBucketManager sharedManager] isInvitedQuest:self.selectedObject];
        
        if (ret) {
            NSLog(@"募集済みです");
            [self invitedMultiQuestAlert];
            
            
        } else {
            NSLog(@"募集されてません");
            [self notInviteMultiQuestAlert];
        }

    } else {
        
        
        [self questAlertShow:[self.selectedObject getObjectForKey:quest_title] description:quest_description];
     
    }


    //--------------------------->
    //ユーザがつくる場合
    //--------------------------->
    //作成者に参加申請pushをおくる
    /*
    NSString *ownerUserURI = [object getObjectForKey:quest_createUserURI];
    KiiUser *ownerUser = [KiiUser userWithURI:ownerUserURI];
    NSString *joinQuestGroup = [object getObjectForKey:quest_groupURI];
    NSLog(@"-------> group : %@",joinQuestGroup);
    
    KiiTopic *topic = [ownerUser topicWithName:topic_invite];
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    
    NSDictionary *dictionary = @{@"join_user":[KiiUser currentUser].objectURI,
                                 @"group":joinQuestGroup,push_type:push_invite};
    //slient
    [apnsFields setContentAvailable:@1];
    
    [apnsFields setSpecificData:dictionary];
    
    KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFields
                                                              andGCMFields:nil];
    
    //ペイロードを削る
    [message setSendSender:[NSNumber numberWithBool:NO]];
    // Disable "w" field
    [message setSendWhen:[NSNumber numberWithBool:NO]];
    // Disable "to" field
    [message setSendTopicID:[NSNumber numberWithBool:NO]];
    // Disable "sa", "st" and "su" field
    [message setSendObjectScope:[NSNumber numberWithBool:NO]];
    
    NSError *error = nil;
    
    [topic sendMessageSynchronous:message
                        withError:&error];
    if (error != nil) {
        // There was a problem.
        NSLog(@"参加処理でエラー");
        NSLog(@"error:%@",error);
    }*/
    
}

#pragma mark Button_Action
#pragma mark -- サーバーコードのテスト
- (IBAction)createNewQuest:(id)sender
{
    [[GXBucketManager sharedManager] getQuestForQuestBoard];
    
//    NSLog(@"call");
//    KiiServerCodeEntry* entry =[Kii serverCodeEntry:@"main"];
//    
//    //実行時パラメータ
//    KiiUser *currUser = [KiiUser currentUser];
//    NSDictionary *argDict = @{@"aaa":@"username",@"bbb":@"password"};
//    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
//    NSError* error = nil;
//    
//    
//    KiiServerCodeExecResult* result = [entry executeSynchronous:argument
//                                                      withError:&error];
//    
//    // Parse the result.
//    NSDictionary *returnedDict = [result returnedValue];
//    NSString *returnString = [returnedDict objectForKey:@"returnedValue"];
//    
//    NSLog(@"%@",returnString);
}


#pragma mark segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([[segue identifier] isEqualToString:@"gotoDescriptionView"]) {
//        GXDescriptionViewController *vc = segue.destinationViewController;
//        vc.object = _selectedObject;
//    }
}

- (IBAction)dataSourceChange:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0: // 一人用
            
            [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
            
            break;
            
        case 1: //みんな用
            
            [[GXBucketManager sharedManager] fetchMissionWithNotCompleted];
            
            
            break;
            
        default:
            break;
    }
}

#pragma mark - Notification
- (void)registeredInvitedBoard:(NSNotification *)notis
{
}

- (void)deletedQuest:(NSNotification *)notis
{
    [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
    [self.collectionView reloadData];
}



- (UIStatusBarStyle)preferredStatusBarStyle {
    return StatusBarContrastColorOf((UIColor *)FlatLime);
}

- (void)questAlertShow:(NSString *)title description:(NSString *)description
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:title
                                                          message:description
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
                                                          message:@"既にほかのメンバーによって募集されています"
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
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"協力クエスト"
                                                         message:@"このクエストの参加者を募集します"
                                                        delegate:nil cancelButtonTitle:@"やめる"
                                               otherButtonTitles:@"OK", nil];
    
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
                [[GXBucketManager sharedManager] registerJoinedQuest:self.selectedObject];
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
    navController.viewControllers = @[invitedVC];
    self.frostedViewController.contentViewController = navController;
}


@end
