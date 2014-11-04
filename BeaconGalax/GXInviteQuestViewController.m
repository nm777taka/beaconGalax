//
//  GXInviteQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXInviteQuestViewController.h"
#import "GXQuestGroupViewController.h"
#import "GXInvitedViewCell.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXExeQuestManager.h"

@interface GXInviteQuestViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,FUIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *invitedQuestArray;
@property KiiObject *selectedInviteBucketObj; //InviteBucketObject;
@property KiiGroup *questGroupAtSelected;

@end

@implementation GXInviteQuestViewController{
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invitedQuestFetched:) name:GXInvitedQuestFetchedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedGroup:) name:GXAddGroupSuccessedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinButtonTopped:) name:@"inviteViewCellTopped" object:nil];
    [[GXBucketManager sharedManager] getInvitedQuest];
    [SVProgressHUD showWithStatus:@"クエストを取得しています"];
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


#pragma mark - CollectionView Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.invitedQuestArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GXInvitedViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)configureCell:(GXInvitedViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //影
    cell.layer.masksToBounds = NO;
    cell.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    cell.layer.shadowOpacity = 0.1f;
    cell.layer.shadowRadius = 2.0f;
    
    NSError *error;
    KiiObject *obj = self.invitedQuestArray[indexPath.row];
    KiiGroup *group = [self getGroup:indexPath.row];
    cell.title.text = [obj getObjectForKey:quest_description];

    //自分がオーナかどうか
    if ([self isOwner:group]) {
        cell.button.buttonColor = [UIColor alizarinColor];
        cell.button.shadowColor = [UIColor pomegranateColor];
        cell.button.shadowHeight = 2.0f;
        cell.button.cornerRadius = 6.0;
        cell.button.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        [cell.button setTitle:@"スタート" forState:UIControlStateNormal];
        [cell.button setTitle:@"スタート" forState:UIControlStateHighlighted];
        
        return;
    }
    
    //参加済みかどうか
    if ([self isJoined:group]) {
        
        cell.button.buttonColor = [UIColor peterRiverColor];
        cell.button.shadowColor = [UIColor belizeHoleColor];
        cell.button.shadowHeight = 2.0f;
        cell.button.cornerRadius = 6.0;
        cell.button.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        [cell.button setTitle:@"スタート" forState:UIControlStateNormal];
        [cell.button setTitle:@"スタート" forState:UIControlStateHighlighted];
        
        return;
        
    } else {
        cell.button.buttonColor = [UIColor turquoiseColor];
        cell.button.shadowColor = [UIColor greenSeaColor];
        cell.button.shadowHeight = 2.0f;
        cell.button.cornerRadius = 6.0;
        cell.button.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        [cell.button setTitle:@"参加" forState:UIControlStateNormal];
        [cell.button setTitle:@"参加" forState:UIControlStateHighlighted];
        
    }
    
}

- (KiiGroup *)getGroup:(int)row
{
    NSError *error;
    KiiObject *obj = self.invitedQuestArray[row];
    KiiGroup *group = [KiiGroup groupWithURI:[obj getObjectForKey:quest_groupURI]];
    [group refreshSynchronous:&error];
    
    return group;
}

- (void)showPushSendAlert
{
    FUIAlertView *alert = [[FUIAlertView alloc] initWithTitle:@"確認" message:@"このクエストに参加しますか？" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"JOIN", nil];
    alert.titleLabel.textColor = [UIColor cloudsColor];
    alert.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alert.messageLabel.textColor  = [UIColor cloudsColor];
    alert.messageLabel.font = [UIFont boldFlatFontOfSize:14];
    alert.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alert.alertContainer.backgroundColor = [UIColor orangeColor];
    alert.defaultButtonColor = [UIColor cloudsColor];
    alert.defaultButtonShadowColor = [UIColor asbestosColor];
    alert.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alert.defaultButtonTitleColor = [UIColor asbestosColor];
    [alert show];
}

- (void)sendPushtoOwner:(KiiGroup *)group
{
    NSError *error;
    KiiUser *ownerUser = [group getOwnerSynchronous:&error];
    KiiTopic *topic = [ownerUser topicWithName:topic_invite];
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    NSDictionary *dict = @{@"join_user":[KiiUser currentUser].objectURI,@"group":group.objectURI,push_type:push_invite};
    
    //サイレント
    [apnsFields setContentAvailable:@1];
    
    [apnsFields setSpecificData:dict];
    
    KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
    
    //ペイロードを削る
    [message setSendSender:[NSNumber numberWithBool:NO]];
    // Disable "w" field
    [message setSendWhen:[NSNumber numberWithBool:NO]];
    // Disable "to" field
    [message setSendTopicID:[NSNumber numberWithBool:NO]];
    // Disable "sa", "st" and "su" field
    [message setSendObjectScope:[NSNumber numberWithBool:NO]];
    
    [topic sendMessage:message withBlock:^(KiiTopic *topic, NSError *error) {
        
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            NSLog(@"送信完了");
        }
    }];
    
}

- (BOOL)isOwner:(KiiGroup *)group
{
    BOOL ret = false;
    NSError *error;
   KiiUser *owner =  [group getOwnerSynchronous:&error];
    if (error) {
        NSLog(@"eeror:%@",error);
    } else {
        if ([owner.objectURI isEqual:[KiiUser currentUser].objectURI]) {
            ret = true;
        } else {
            ret = false;
        }
    }
    
    return ret;
}

- (BOOL)isJoined:(KiiGroup *)group
{
    NSError *error;
    BOOL ret = false;
    NSArray *members = [group getMemberListSynchronous:&error];
    if (error) NSLog(@"error:%@",error);
    else NSLog(@"membercount:%d",members.count);
    for (KiiUser *user in members) {
        if ([user.objectURI isEqualToString:[KiiUser currentUser].objectURI]) {
            ret = true;
            break;
        } else {
            ret = false;
        }
    }
    
    return ret;
}

#pragma mark - GXNotification
- (void)invitedQuestFetched:(NSNotification *)info
{
    NSArray *array = info.object;
    self.invitedQuestArray = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
    
    [SVProgressHUD dismiss];
}

//参加者
#pragma mark - デバック必要
- (void)addedGroup:(NSNotification *)info
{
    NSError *error;
    NSString *groupURI = info.object;
    KiiGroup *joinedGroup = [KiiGroup groupWithURI:groupURI];
    [joinedGroup refreshSynchronous:&error];
    
    //トピック購読
    KiiTopic *topic = [joinedGroup topicWithName:@"quest_start"];
    [KiiPushSubscription subscribe:topic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
        if (error) NSLog(@"error:%@",error);
    }];
    
    //参加したクエストを取得
    KiiBucket *bucket = [joinedGroup bucketWithName:@"quest"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        
        if (!error) {
            
            KiiObject *obj = results.firstObject;
            //自分の参加済み協力クエに登録
            [[GXBucketManager sharedManager] registerJoinedMultiQuest:obj];
        }

    }];
    
    
    //notjoinから消す --------> Debug
    //このobjは(Groupスコープのobjと紐付いてるから消すとそっちが消える)
    //[[GXBucketManager sharedManager] deleteJoinedQuest:obj];
    
    KiiBucket *clearJudegeBucket = [joinedGroup bucketWithName:@"clear_judge"];
    
    [KiiPushSubscription subscribe:clearJudegeBucket withBlock:^(KiiPushSubscription *subscription, NSError *error) {
        
        if (!error) NSLog(@"参加者によるグループバケットの購読完了");
    }];
    
    [SVProgressHUD dismiss];
    
    [TSMessage showNotificationWithTitle:@"参加完了" type:TSMessageNotificationTypeSuccess];
    
    [self.collectionView reloadData];
    
}

- (void)joinButtonTopped:(NSNotification *)notis
{
    GXInvitedViewCell *cell = notis.object;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    KiiObject *obj = self.invitedQuestArray[indexPath.row];
    
    //色々判定する
    //タップしたクエストのグループを取得
    self.questGroupAtSelected = [self getGroup:(int)indexPath.row];
    
    //自分がオーナかどうか
    if ([self isOwner:self.questGroupAtSelected]) {
        [self gotoQuestPartyView:indexPath];
        return;
    }
    
    //既にグループに参加しているか
    if ([self isJoined:self.questGroupAtSelected]) {
        [self gotoQuestPartyView:indexPath];
        return;
    }
    
    //参加アクション
    [self showPushSendAlert];
}

- (void)gotoQuestPartyView:(NSIndexPath *)indexPath
{
    self.selectedInviteBucketObj = self.invitedQuestArray[indexPath.row];
    self.questGroupAtSelected = [self getGroup:(int)indexPath.row];
    
    if ([self isJoined:self.questGroupAtSelected])
        [GXExeQuestManager sharedManager].exeQuest = self.selectedInviteBucketObj; //マネージャーでこれからやるクエストを管理(InvitedBoardのクエスト)
        [self performSegueWithIdentifier:@"goto_QuestMemberView" sender:self];

}

#pragma mark - FUIAlertViewDelegate
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: //キャンセル
            //なにもしない
            break;
        case 1:
            [SVProgressHUD showWithStatus:@"参加申請中"];
            [self sendPushtoOwner:self.questGroupAtSelected];
            break;
        default:
            break;
    }
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goto_QuestMemberView"]) {
        GXQuestGroupViewController *vc = segue.destinationViewController;
        vc.selectedQuestGroup = self.questGroupAtSelected;
        
    }
}


#pragma  mark - refresh
- (void)refresh
{
    NSLog(@"refresh");
    [SVProgressHUD showWithStatus:@"クエストを取得しています"];
    [[GXBucketManager sharedManager] getInvitedQuest];
    [NSTimer bk_scheduledTimerWithTimeInterval:1.0f block:^(NSTimer *timer) {
        [self endRefresh];
    } repeats:NO];
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}




@end
