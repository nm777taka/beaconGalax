//
//  GXInviteQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXInviteQuestViewController.h"
#import "GXQuestGroupViewController.h"
#import "GXQuestDetailViewController.h"
#import "GXActivityList.h"
#import "GXInvitedViewCell.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXExeQuestManager.h"

#import "FUIAlertView+GXTheme.h"

//Model
#import "GXQuest.h"
#import "GXQuestList.h"

#import "GXGoogleTrackingManager.h"

@interface GXInviteQuestViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,FUIAlertViewDelegate,GXQuestListDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) GXQuestList *questList;
@property (nonatomic,strong) GXQuest *selectedQuest;

@property NSMutableArray *invitedQuestArray;
@property KiiObject *selectedInviteBucketObj; //InviteBucketObject;
@property KiiGroup *questGroupAtSelected;
@property UIButton *addQuestButton;

@property (nonatomic,strong) GXQuestDetailViewController *detailViewController;
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
    
    _questList = [[GXQuestList alloc] initWithDelegate:self]; //delegate設定(del先は俺やで）
    
    //詳細View
    self.detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    [self.questList requestAsyncronous:2];
    
    //button
    self.addQuestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addQuestButton.frame = CGRectMake(self.view.center.x - 25, self.view.center.y + 50 + 50, 50, 50);
    UIImage *image = [UIImage imageNamed:@"addQuestButton.png"];
    [self.addQuestButton setImage:image forState:UIControlStateNormal];
    [self.addQuestButton setImage:image forState:UIControlStateHighlighted];
    [self.addQuestButton addTarget:self action:@selector(addQuest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addQuestButton];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invitedQuestFetched:) name:GXInvitedQuestFetchedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questInfo:) name:@"questInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questDeleted:) name:GXQuestDeletedNotification object:nil];
    [self request:2];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GXGoogleTrackingManager sendScreenTracking:@"inviteQuestView"];
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
    GXInvitedViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    //modelの設定
    cell.quest = [_questList questAtIndex:indexPath.row];
    
    return cell;
    
}


#pragma mark - ToDo
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:@"通信中"];
    GXQuest *quest = [_questList questAtIndex:indexPath.row];
    KiiObject *obj = [KiiObject objectWithURI:quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            KiiGroup *group = [KiiGroup groupWithURI:[object getObjectForKey:quest_groupURI]];
            [group refreshWithBlock:^(KiiGroup *group, NSError *error) {
                if (!error) {
                    
                    _selectedInviteBucketObj = object;
                    _questGroupAtSelected = group;
                    
                    //クエスト募集者ならグループviewへ
                    if ([self isOwner:group]) {
                        [SVProgressHUD dismiss];
                        [self gotoQuestPartyView];
                        return ;
                    }
                    
                    //募集者じゃないなら参加処理へ
                    [SVProgressHUD dismiss];
                    [self showPushSendAlert];
                }
            }];
        }
    }];
}

#pragma mark - Todo
//くそ重い

- (KiiGroup *)getGroup
{
    NSError *error;
    KiiObject *obj = _selectedInviteBucketObj;
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
        [GXGoogleTrackingManager sendEventTracking:@"Quest" action:@"join" label:@"参加" value:nil screen:@"inviteQuestView"];
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
- (void)questDeleted:(NSNotification *)notis
{
    [self request:2]; //2 → bucketIndex (2=inviteBucket)
    CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationLabelBackgroundColor = [UIColor turquoiseColor];
    [notification displayNotificationWithMessage:@"削除完了" forDuration:2.0f];
}
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
    if (self.detailViewController) {
        self.detailViewController.quest = [_questList questAtIndex:indexPath.row];
        [self.view addSubview:self.detailViewController.view];
    }
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
            KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
            //自分の参加済み協力クエに登録
            [[GXBucketManager sharedManager] acceptNewQuest:obj];
            //notJoinから消す
            //[[GXBucketManager sharedManager] deleteJoinedQuest:self.willDeleteObjAtNotJoin];
            //Activity
            NSString *name = [gxUser getObjectForKey:user_name];
            NSString *questName = [obj getObjectForKey:quest_title];
            NSString *text = [NSString stringWithFormat:@"%@クエストに参加しました",questName];
            [[GXActivityList sharedInstance] registerQuestActivity:name title:text fbid:[gxUser getObjectForKey:user_fb_id]];
            
        }

    }];
    
    KiiBucket *clearJudegeBucket = [joinedGroup bucketWithName:@"clear_judge"];
    
    [KiiPushSubscription subscribe:clearJudegeBucket withBlock:^(KiiPushSubscription *subscription, NSError *error) {
        
        if (!error) NSLog(@"参加者によるグループバケットの購読完了");
    }];
    
    [SVProgressHUD dismiss];
    
    CWStatusBarNotification *notis = [CWStatusBarNotification new];
    notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
    notis.notificationLabel.textColor = [UIColor cloudsColor];
    notis.notificationStyle = CWNotificationStyleNavigationBarNotification;
    [notis displayNotificationWithMessage:@"パーティーに参加しました!" forDuration:2.0f];
    
    [self.collectionView reloadData];
    
}



#pragma mark - ToDo
//ここからいくのはリーダーだけにする! ..リーダー以外もできるように
- (void)gotoQuestPartyView
{
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
//           // [SVProgressHUD showWithStatus:@"参加申請中"];
//            [self requestAddGroup];
            [self questJoinSequence];
            
            break;
        default:
            break;
    }
}

- (void)questJoinSequence
{
    [SVProgressHUD showWithStatus:@"参加処理中"];
    //すでに参加しているかチェック
    if ([self isJoined:_questGroupAtSelected]) {
        //参加してた
        [SVProgressHUD dismiss];
        FUIAlertView *alert = [FUIAlertView errorTheme:@"すでに参加済みです"];
        [alert show];
    } else {
        //参加してなかったら
        [self requestAddGroup];
    }
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goto_QuestMemberView"]) {
        GXQuestGroupViewController *vc = segue.destinationViewController;
        //選択されたクエストのグループとクエスト自体をパーティーViewに渡してあげる
        vc.selectedQuestGroup = _questGroupAtSelected;
        vc.willExeQuest = _selectedInviteBucketObj;
    }
}


#pragma  mark - refresh
- (void)refresh
{
    [self request:2];
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];

}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}

- (void)request:(NSInteger)index
{
    if (_questList.loading) {
    } else {
        [SVProgressHUD showWithStatus:@"データ更新中"];
        [[GXBucketManager sharedManager] countInviteBucket];
        [_questList requestAsyncronous:index];
    }
}

#pragma makr - QuestList delegate
- (void)questListDidLoad
{
    NSLog(@"delegate");
    [_collectionView reloadData];
    [SVProgressHUD dismiss];
}

#pragma  mark - Button Action
- (void)addQuest:(UIButton *)sender
{

    [self performSegueWithIdentifier:@"gotoCreateView" sender:self];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.addQuestButton.hidden = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.addQuestButton.hidden = NO;
}



@end
