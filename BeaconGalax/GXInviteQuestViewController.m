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
#import "GXUserManager.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questInfo:) name:@"questInfo" object:nil];
    
    [[GXBucketManager sharedManager] getInvitedQuest];
    //[SVProgressHUD showWithStatus:@"クエストを取得しています"];
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

    self.selectedInviteBucketObj = self.invitedQuestArray[indexPath.row];
    
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
        //アラート
        FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"！" message:@"すでに参加しています。参加済み画面からクエストを開始できます" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
        [alertView show];
        return;
    }
    
    //参加アクション
    [self showPushSendAlert];

}

#pragma mark - Todo
//くそ重い
- (void)configureCell:(GXInvitedViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //影
    cell.layer.masksToBounds = NO;
    cell.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    cell.layer.shadowOpacity = 0.1f;
    cell.layer.shadowRadius = 2.0f;
    
    //コンテンツ
    KiiObject *obj = self.invitedQuestArray[indexPath.row];
    KiiGroup *group = [self getGroup:indexPath.row];
    cell.title.text = [obj getObjectForKey:quest_title];
    int questRank = [[obj getObjectForKey:quest_rank] intValue];
    cell.questRankLabel.text = [NSString stringWithFormat:@"Rank:☆%d",questRank];
    cell.questRankLabel.textColor = [UIColor orangeColor];
    int cur_memberNum = [self getGroupMemberNum:group];
    cell.nowMemberLabel.text = [NSString stringWithFormat:@"パーティーメンバー:%d",cur_memberNum];
    cell.ownerIcon.profileID = [obj getObjectForKey:quest_owner_fbid];
    cell.ownerName.text = [obj getObjectForKey:quest_owner];
    
    //既にスタートされているか
    if ([[obj getObjectForKey:quest_isStarted] boolValue]) {
        cell.userJoinStatus.text = @"開始済み";
    }

    //自分がオーナかどうか
    if ([self isOwner:group]) {
        cell.userJoinStatus.textColor = [UIColor alizarinColor];
        cell.userJoinStatus.text = @"オーナー";
        return;
    }
    
    //参加済みかどうか
    if ([self isJoined:group]) {
        cell.userJoinStatus.textColor = [UIColor turquoiseColor];
        cell.userJoinStatus.text = @"参加済み";
        return;
        
    } else {
        cell.userJoinStatus.textColor = [UIColor midnightBlueColor];
        cell.userJoinStatus.text = @"未参加";
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

- (int)getGroupMemberNum:(KiiGroup *)group
{
    NSError *error;
    NSArray *array = [group getMemberListSynchronous:&error];
    return array.count;
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

- (void)requestAddGroup
{
    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"addGroup"];
    NSString *groupURI = [self.selectedInviteBucketObj getObjectForKey:quest_groupURI];
    NSLog(@"selected-groupuri:%@",groupURI);
    NSString *kiiuserURI = [KiiUser currentUser].objectURI;
    KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
    NSString *gxUserURI = gxUser.objectURI;
    
    NSDictionary *argDict = [NSDictionary dictionaryWithObjectsAndKeys:groupURI,@"groupURI",kiiuserURI,@"userURI",gxUserURI,@"gxURI", nil];
    
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
    
    [entry execute:argument withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
        NSDictionary *retDict = [result returnedValue];
        NSLog(@"returned:%@",retDict);
        [self addedGroup];
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
    [_refreshControl endRefreshing];
    
}

- (void)questInfo:(NSNotification *)info
{
    GXInvitedViewCell *cell = info.object;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    KiiObject *infoObj = self.invitedQuestArray[indexPath.row];
    NSString *req = [infoObj getObjectForKey:quest_requirement];
    NSString *des = [infoObj getObjectForKey:quest_description];
    [self showFUIAlert:des message:req];
    
}

#pragma mark - FUIAlertView
- (void)showFUIAlert:(NSString *)title message:(NSString *)message
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:title
                                                          message:message
                                                         delegate:nil cancelButtonTitle:@"Dismiss"
                                                otherButtonTitles:nil, nil];
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
    [alertView show];

}

#pragma mark - 参加者
#pragma mark - デバック必要
- (void)addedGroup
{
    NSError *error;
    //今選択しているobjのグループに参加したから
    NSString *groupURI = [self.selectedInviteBucketObj getObjectForKey:quest_groupURI];
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
            [[GXBucketManager sharedManager] registerJoinedQuest:obj];
            //notJoinから消す
            [[GXBucketManager sharedManager] deleteJoinedQuest:self.willDeleteObjAtNotJoin];
        }

    }];
    
    KiiBucket *clearJudegeBucket = [joinedGroup bucketWithName:@"clear_judge"];
    
    [KiiPushSubscription subscribe:clearJudegeBucket withBlock:^(KiiPushSubscription *subscription, NSError *error) {
        
        if (!error) NSLog(@"参加者によるグループバケットの購読完了");
    }];
    
    [SVProgressHUD dismiss];
    
    //[TSMessage showNotificationWithTitle:@"参加完了" type:TSMessageNotificationTypeSuccess];
    [self showFUIAlert:@"Success" message:@"パーティーに参加しました"];
    
    [self.collectionView reloadData];
    
}

- (void)joinButtonTopped:(NSNotification *)notis
{
}

#pragma mark - ToDo
//ここからいくのはリーダーだけにする! ..リーダー以外もできるように
- (void)gotoQuestPartyView:(NSIndexPath *)indexPath
{
    self.selectedInviteBucketObj = self.invitedQuestArray[indexPath.row];
    self.questGroupAtSelected = [self getGroup:(int)indexPath.row];
    
    if ([self isJoined:self.questGroupAtSelected]) {
        [self performSegueWithIdentifier:@"goto_QuestMemberView" sender:self];

    }

}

#pragma mark - FUIAlertViewDelegate
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: //キャンセル
            //なにもしない
            break;
        case 1:
           // [SVProgressHUD showWithStatus:@"参加申請中"];
            [self requestAddGroup];
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
        //選択されたクエストのグループとクエスト自体をパーティーViewに渡してあげる
        vc.selectedQuestGroup = self.questGroupAtSelected;
        vc.willExeQuest = self.selectedInviteBucketObj;
    }
}


#pragma  mark - refresh
- (void)refresh
{
    NSLog(@"refresh");
    [SVProgressHUD showWithStatus:@"クエストを取得しています"];
    [[GXBucketManager sharedManager] getInvitedQuest];

}

- (void)endRefresh
{
}




@end
