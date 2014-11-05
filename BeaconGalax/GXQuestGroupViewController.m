//
//  GXQuestGroupViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/16.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestGroupViewController.h"
#import "GXQuestExeViewController.h"
#import "GXQuestGroupViewCell.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXExeQuestManager.h"

@interface GXQuestGroupViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *questMemberArray;

@property KiiObject *quest;

@property (weak, nonatomic) IBOutlet FUIButton *actionButton;

@end

@implementation GXQuestGroupViewController{
    UIRefreshControl *_refreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
    
    self.actionButton.buttonColor = [UIColor turquoiseColor];
    self.actionButton.shadowColor = [UIColor greenSeaColor];
    self.actionButton.shadowHeight = 3.0f;
    self.actionButton.cornerRadius = 6.0f;
    self.actionButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Notificaiton
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberFetched:) name:GXGroupMemberFetchedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questStart:) name:GXStartQuestNotification object:nil];

    self.quest = [[GXBucketManager sharedManager] getGroupQuest:self.selectedQuestGroup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //メンバーフェッチ
    [self.selectedQuestGroup refreshWithBlock:^(KiiGroup *group, NSError *error) {
        if (error) NSLog(@"error:%@",error);
        else
            [[GXBucketManager sharedManager] getQuestMember:group];
        
        //現在ログイン中のユーザがオーナーかどうかでUIを変える
        if ([self isCurrentUserOwner:self.selectedQuestGroup]) {
            //オーナー
            [self.actionButton setTitle:@"Start" forState:UIControlStateNormal];
            [self.actionButton bk_addEventHandler:^(id sender) {
                [self questStartSequence];
            } forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            //参加者
            [self.actionButton setTitle:@"準備完了" forState:UIControlStateNormal];
            
            [self.actionButton bk_addEventHandler:^(id sender) {
                [self setReadyStatus];
            } forControlEvents:UIControlEventTouchUpInside];
        }
    }];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)questStartSequence
{
    NSError *error;
    [self.quest refreshSynchronous:&error];
    if ([[self.quest getObjectForKey:quest_isReady_num] intValue] > 0 ) {
        NSError *error;
        KiiTopic *startTopic = [self.selectedQuestGroup topicWithName:@"quest_start"];
        KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
        KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
        [startTopic sendMessageSynchronous:message withError:&error];
        
        if (error) {
            NSLog(@"error:%@",error);
            [SVProgressHUD showErrorWithStatus:@"クエストを開始できません"];
        } else {
            
            
        }
    }
}

- (void)setReadyStatus
{
    //クエストにできたよーって書き込む
    NSError *error;
    int isReadyNum = [[self.quest getObjectForKey:quest_isReady_num] intValue];
    NSLog(@"readynum:%d",isReadyNum);
    isReadyNum++;
    NSNumber *newValue = [NSNumber numberWithInt:isReadyNum];
    [self.quest setObject:newValue forKey:quest_isReady_num];
    [self.quest saveSynchronous:&error];
    if (error) {
        NSLog(@"error:%@",error);
    } else {
        NSLog(@"readyup");
    }
    
    
    //自分のステータス(cell用)
    for (KiiObject *obj in self.questMemberArray) {
        
        if ([[obj getObjectForKey:@"uri"] isEqualToString:[KiiUser currentUser].objectURI]) {
            
            //準備完了じゃなかったら→完了へ
            if ([[obj getObjectForKey:user_isReady] isEqualToNumber:@NO]) {
                [obj setObject:@YES forKey:user_isReady];
                [obj saveSynchronous:&error];
            }
            
        }
    }
    
    [self.collectionView reloadData];
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

#pragma mark - Collection Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.questMemberArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GXQuestGroupViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GXQuestGroupViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    KiiObject *member = self.questMemberArray[indexPath.row];
    
    if (member) {
        cell.userName.text = [member getObjectForKey:user_name];
        cell.userIcon.profileID = [member getObjectForKey:user_fb_id];
        
        
        if ([self isOwer:(int)indexPath.row]) {
            
            cell.readyIcon.hidden = YES;
            cell.backgroundColor = [UIColor alizarinColor];

        }else {
            
            if ([[member getObjectForKey:user_isReady] isEqualToNumber:@YES]) {
                cell.readyIcon.hidden = NO;
                cell.backgroundColor = [UIColor whiteColor];
            }
            
        }
            
    }

}


- (BOOL)isOwer:(int)index
{
    BOOL ret = false;
    
    KiiObject *user = self.questMemberArray[index];
    if ([[user getObjectForKey:user_isOwner] boolValue]) {
        ret = true;
    }
    
    return ret;
    

}

- (BOOL)isCurrentUserOwner:(KiiGroup *)group
{
    NSLog(@"Call0isCurrentOwner");
    NSError *error;
    BOOL ret = false;
    KiiUser *owner = [group getOwnerSynchronous:&error];
    if ([owner isEqual:[KiiUser currentUser]]) ret = true;
    else ret = false;
    
    return ret;
}

#pragma mark - GXNotification
- (void)memberFetched:(NSNotification *)notis
{
    NSArray *array = notis.object;
    self.questMemberArray = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
    //[SVProgressHUD showSuccessWithStatus:@"取得完了"];
}

- (void)questStart:(NSNotification *)notis
{
    NSLog(@"クエストスタート!!");
    [SVProgressHUD showWithStatus:@"クエストを開始します"];
    [NSTimer bk_scheduledTimerWithTimeInterval:2.0f block:^(NSTimer *timer) {
        [self gotoQuestExeView];
        [SVProgressHUD dismiss];
    } repeats:NO];
}

#pragma  mark - refresh
- (void)refresh
{
    NSLog(@"refresh");
    [[GXBucketManager sharedManager] getQuestMember:self.selectedQuestGroup];
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}


#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"test"]) {
        GXQuestExeViewController *vc = segue.destinationViewController;
        vc.exeQuest = self.quest;
        vc.exeGroup = self.selectedQuestGroup;
    }
}

- (void)gotoQuestExeView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"subStoryboard" bundle:nil];
    GXQuestExeViewController *initialViewController = [storyboard instantiateInitialViewController];
    initialViewController.exeQuest = self.quest;
    initialViewController.exeGroup = self.selectedQuestGroup;
    initialViewController.isMulti = YES;
    initialViewController.groupMemberNum = (int)self.questMemberArray.count;
    
    //QMで管理
    [GXExeQuestManager sharedManager].nowExeQuest = self.willExeQuest;
    
    [self presentViewController:initialViewController animated:YES completion:^{
        
        //どこのbucketに属しているか
        //inviteだったらisStartedをtrueへ
        KiiBucket *willExeQuestBucket = self.willExeQuest.bucket;
        KiiBucket *inviteBucket = [GXBucketManager sharedManager].inviteBoard;
        if (willExeQuestBucket == inviteBucket) {
            [[GXExeQuestManager sharedManager] startQuestAtInvitedBucket:self.willExeQuest]; //isStartedをYESに
        }
        
    }];
}


@end
