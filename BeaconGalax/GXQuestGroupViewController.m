//
//  GXQuestGroupViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/16.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestGroupViewController.h"
#import "GXQuestExeViewController.h"
#import "GXUserQuestExeViewController.h"
#import "GXQuestGroupViewCell.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXExeQuestManager.h"
#import "GXUserManager.h"

#import "GXGoogleTrackingManager.h"

@interface GXQuestGroupViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *questMemberArray;

@property KiiObject *quest;

@property (weak, nonatomic) IBOutlet FUIButton *actionButton;
@property BOOL isActionButtonPushed;

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
    
    _isActionButtonPushed = NO; //連打されると落ちるためにフラグで管理
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Notificaiton
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberFetched:) name:GXGroupMemberFetchedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questStart:) name:GXStartQuestNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userReady:) name:@"ready" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //メンバーフェッチ
    self.quest = [[GXBucketManager sharedManager] getGroupQuest:self.selectedQuestGroup]; //groupScopeのクエストをとってくる
    
    [self.selectedQuestGroup refreshWithBlock:^(KiiGroup *group, NSError *error) {
        if (error) NSLog(@"error:%@",error);
        else
            [[GXBucketManager sharedManager] getQuestMember:group];
        
        //現在ログイン中のユーザがオーナーかどうかでUIを変える
        if ([self isCurrentUserOwner:self.selectedQuestGroup]) {
            //オーナー
            [self.actionButton setTitle:@"Start" forState:UIControlStateNormal];
            [self.actionButton bk_addEventHandler:^(id sender) {
                if (_isActionButtonPushed) {
                    return ;
                } else {
                    _isActionButtonPushed = YES;
                    [self questStartSequence];
                }
            } forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            //参加者
            [self.actionButton setTitle:@"準備完了" forState:UIControlStateNormal];
            
            [self.actionButton bk_addEventHandler:^(id sender) {
                if (_isActionButtonPushed) {
                    NSLog(@"_isAction=YES ->");
                    return ;
                    
                } else {
                    _isActionButtonPushed = YES;
                    [self setReadyStatus];
                }
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
    [self.quest refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            KiiClause *clause = [KiiClause equals:user_isReady value:@YES ];
            KiiQuery *query = [KiiQuery queryWithClause:clause];
            KiiBucket *bucket = [self.selectedQuestGroup bucketWithName:@"member"];
            [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
                if (!error) {
                    
                    if ((self.questMemberArray.count - 1) == 0) { //リーダーしか以内状況
                        [SVProgressHUD showErrorWithStatus:@"メンバーが一人もいません"];
                        _isActionButtonPushed = NO; //フラグリセット
                        return ;
                    }
                    
                    if ((self.questMemberArray.count - 1) == results.count) { //リーダーはisReadyStatusを持たないので除いた数で判定する
                        //リーダ以外全員準備完了
                        //開始処理
                        KiiTopic *startTopic = [self.selectedQuestGroup topicWithName:@"quest_start"];
                        KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
                        KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
                        [startTopic sendMessage:message withBlock:^(KiiTopic *topic, NSError *error) {
                        
                        }];

                    } else {
                        //まだ全員準備OKじゃない
                        [SVProgressHUD showErrorWithStatus:@"準備完了じゃないメンバーがいます"];
                        _isActionButtonPushed = NO; //フラグリセット
                    }
                }
            }];
        }
    }];
}

- (void)setReadyStatus
{
    KiiBucket *bucket = [_selectedQuestGroup bucketWithName:@"member"];
    KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
    KiiClause *clause = [KiiClause equals:user_uri value:[gxUser getObjectForKey:user_uri]];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    //Groupスコープのmemberバケットから自分をとってくる
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            NSLog(@"questGroupMemberNum:%d",results.count);
            //自分のreadyステータスをアップデート
            KiiObject *me = results.firstObject;
            NSNumber *isReady = [me getObjectForKey:user_isReady];
            isReady = @YES;
            [me setObject:isReady forKey:user_isReady];
            [me saveWithBlock:^(KiiObject *object, NSError *error) {
                NSLog(@"isReadyUpdate");
                [self.collectionView reloadData];
            }];
        }
    }];
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
    cell.userName.text = [member getObjectForKey:user_name];
    cell.userIcon.profileID = [member getObjectForKey:user_fb_id];
    BOOL isReady = [[member getObjectForKey:user_isReady] boolValue];
    BOOL isOwner = [[member getObjectForKey:user_isOwner] boolValue];
    if (isReady) {
        cell.readyIcon.hidden = NO;
    } else {
        cell.readyIcon.hidden = YES;
    }
    
    if (isOwner) {
        cell.userIcon.layer.borderWidth = 2.0f;
        cell.userIcon.layer.borderColor = [UIColor alizarinColor].CGColor;
    } else {
        cell.userIcon.layer.borderColor = [UIColor cloudsColor].CGColor;
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

- (void)userReady:(NSNotification *)notis
{
    NSLog(@"call--handler");
    [self setReadyStatus];
}

- (void)questStart:(NSNotification *)notis
{
    NSLog(@"クエストスタート!!");
    [[GXActionAnalyzer sharedInstance] setActionName:GXQuestStart];
    [SVProgressHUD showWithStatus:@"クエストを開始します"];
    [NSTimer bk_scheduledTimerWithTimeInterval:2.0f block:^(NSTimer *timer) {
        [self gotoQuestExeView];
        [SVProgressHUD dismiss];
        [GXGoogleTrackingManager sendEventTracking:@"Quest" action:@"start_multi" label:@"協力クエスト開始" value:nil screen:@"questGroupView"];
        
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
    GXUserQuestExeViewController *vc1;
    GXQuestExeViewController *vc2;
    //QMで管理
    [GXExeQuestManager sharedManager].nowExeQuest = self.willExeQuest;

    NSString *type = [self.quest getObjectForKey:quest_type];
    if ([type isEqualToString:@"user"]) {
        //ユーザ判定のクエスト
        vc1 = [storyboard instantiateViewControllerWithIdentifier:@"userExeQuest"];
        vc1.exeQuest = self.quest;
        vc1.exeGroup = self.selectedQuestGroup;
        
        [self presentViewController:vc1 animated:YES completion:^{
            
            //どこのbucketに属しているか
            //inviteだったらisStartedをtrueへ
            //現在実行中のユーザがオーナーか参加者かでwillExeQuestの親バケットが違う
            KiiBucket *willExeQuestBucket = self.willExeQuest.bucket;
            KiiBucket *inviteBucket = [GXBucketManager sharedManager].inviteBoard;
            if (willExeQuestBucket == inviteBucket) {
                [[GXExeQuestManager sharedManager] startQuestAtInvitedBucket:self.willExeQuest]; //isStartedをYESに
            }

        }];
        
    } else {
        
        //ビーコン判定クエスト
        vc2 = [storyboard instantiateInitialViewController];
        vc2.exeQuest = self.quest;
        vc2.exeGroup = self.selectedQuestGroup;
        vc2.isMulti = YES;
        vc2.groupMemberNum = (int)self.questMemberArray.count;
        
        [self presentViewController:vc2 animated:YES completion:^{
            
            //どこのbucketに属しているか
            //inviteだったらisStartedをtrueへ
            KiiBucket *willExeQuestBucket = self.willExeQuest.bucket;
            KiiBucket *inviteBucket = [GXBucketManager sharedManager].inviteBoard;
            if (willExeQuestBucket == inviteBucket) {
                [[GXExeQuestManager sharedManager] startQuestAtInvitedBucket:self.willExeQuest]; //isStartedをYESに
            }
            
        }];
    }
}


@end
