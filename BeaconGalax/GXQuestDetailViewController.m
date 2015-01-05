//
//  GXQuestDetailViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestDetailViewController.h"
#import "GXQuestExeViewController.h"
#import "GXQuestReadyViewController.h"
#import "GXQuestGroupViewController.h"
#import "GXQuestReadyViewController.h"
#import "GXQuestExeViewController.h"
#import "GXDetailViewMembersCell.h"

#import <CWStatusBarNotification.h>
#import "GXQuestBucketManager.h"
#import "GXExeQuestManager.h"
#import "GXActivityList.h"
#import "GXExeQuestManager.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"
#import "FUIAlertView+GXTheme.h"
#import "GXNotification.h"
#import "GXUserManager.h"
#import "NSObject+BlocksWait.h"

#import "GXDetailHeaderViewCell.h"
#import "GXDetailTableViewCell.h"
#import "GXQuestList.h"
#import "GXQuest.h"

#define kNotjoin 0
#define kJoined 1
#define kInvite 2

@interface GXQuestDetailViewController()<FUIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,GXHeaderCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *questMembersArray;
- (IBAction)closeAction:(id)sender;

@property KiiObject *selectedQuestObj;
@property KiiGroup *selectedQuestGroup;

@property UIRefreshControl *refreshConrol;

@property BOOL isOwner;
@property BOOL isMulti;

@end

@implementation GXQuestDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma makr - ViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //delegateの設定
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //空のcellを表示させないtameni
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questJoined:) name:GXQuestJoinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorHandler:) name:GXErrorNotification object:nil];
    
    [[GXPageViewAnalyzer shareInstance] setPageView:NSStringFromClass([self class])];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isQuestOwner]) {
        [self getMemberList];
    }
    
}

- (void)getMemberList
{
    if (!self.quest.groupURI) {return;};
    
    self.selectedQuestGroup = [KiiGroup groupWithURI:self.quest.groupURI];
    [self.selectedQuestGroup refreshWithBlock:^(KiiGroup *group, NSError *error) {
        if (!error) {
            [group getMemberListWithBlock:^(KiiGroup *group, NSArray *members, NSError *error) {
                if (!error) {
                    NSMutableArray *resultsArray = [NSMutableArray new];
                    for (KiiUser *user in members) {
                        KiiObject *gx_user = [[GXBucketManager sharedManager] getGalaxUser:user.objectURI];
                        [resultsArray addObject:gx_user];
                    }
                    self.questMembersArray = [NSMutableArray arrayWithArray:resultsArray];
                    [self.tableView reloadData];
                }
            }];
        } else {
            NSLog(@"groupError->%@",error);
            self.questMembersArray = [NSMutableArray new]; //初期化
        }
    }];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)resizeLable:(UILabel *)label
{
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, 284, label.frame.size.height );
}


#pragma mark - FUIAlertView

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            //cancel
            [self cancelJoinedQuest];
        }
    } else {
        if (buttonIndex == 1) {
            //delete
            [self deleteInvitedQuest];
            
        }
    }
}

- (void)cancelJoinedQuest
{
    [SVProgressHUD showWithStatus:@"取り消し中"];
    //bucketからkii_objectを取得
    KiiBucket *bucket = [GXBucketManager sharedManager].joinedQuest;
    KiiClause *clause = [KiiClause equals:@"title" value:self.quest.title];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            
            KiiObject *quest = results.firstObject;
            
            if ([[quest getObjectForKey:quest_player_num] intValue] > 1) {
                //協力
                [quest deleteWithBlock:^(KiiObject *object, NSError *error) {
                    if (error) {
                        [self showErrorMsg];
                    } else {
                        KiiGroup *targetGroup = [KiiGroup groupWithURI:[quest getObjectForKey:quest_groupURI]];
                        [targetGroup refreshWithBlock:^(KiiGroup *group, NSError *error) {
                            if (error) {
                                [self showErrorMsg];
                            } else {
                                KiiBucket *member = [group bucketWithName:@"member"];
                                KiiObject *gxusr = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
                                KiiClause *clause = [KiiClause equals:@"name" value:[gxusr getObjectForKey:user_name]];
                                KiiQuery *query = [KiiQuery queryWithClause:clause];
                                [member executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
                                    if (!error) {
                                        KiiObject *deleteObj = results.firstObject;
                                        [deleteObj deleteWithBlock:^(KiiObject *object, NSError *error) {
                                            NSLog(@"クエストメンバーから抜けました");
                                            
                                            //自分のバケットから参加クエストを消す
                                            [quest deleteWithBlock:^(KiiObject *object, NSError *error) {
                                            }];
                                            
                                            //kiiGrupから消える
                                            [self getOutQuestGroup:group.objectURI];
                                            CWStatusBarNotification *notis = [CWStatusBarNotification new];
                                            notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
                                            [notis displayNotificationWithMessage:@"削除しました" forDuration:2.0f];
                                            
                                            [NSObject performBlock:^{
                                                [self.tableView reloadData];
                                                [SVProgressHUD dismiss];
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            } afterDelay:1.0f];
                                        }];
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }
            
            else {
                [quest deleteWithBlock:^(KiiObject *object, NSError *error) {
                    
                    if (!error) {
                        CWStatusBarNotification *notis = [CWStatusBarNotification new];
                        notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
                        [notis displayNotificationWithMessage:@"取り消しました" forDuration:2.0f];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestDeletedNotification object:nil];
                        [[GXActionAnalyzer sharedInstance] setActionName:GXQuestDelete];
                        
                        [self.tableView reloadData];
                        
                        [SVProgressHUD dismiss];
                    }
                }];
            }
            
        }
    }];
}

- (void)deleteInvitedQuest
{
    [SVProgressHUD showWithStatus:@"クエスト削除中"];
    KiiBucket *quest_board = [GXBucketManager sharedManager].questBoard;
    KiiClause *clause = [KiiClause equals:@"title" value:self.quest.title];
    KiiQuery *query = [KiiQuery queryWithClause:clause ];
    [quest_board executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            KiiObject *deleteQuest = results.firstObject;
            [deleteQuest deleteWithBlock:^(KiiObject *object, NSError *error) {
                if (!error) {
                    [SVProgressHUD showSuccessWithStatus:@"削除完了"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    CWStatusBarNotification *notis = [CWStatusBarNotification new];
                    notis.notificationLabelBackgroundColor = [UIColor alizarinColor];
                    [notis displayNotificationWithMessage:@"何かしらのエラーで削除できません" forDuration:2.0f];
                }
            }];
        }
    }];
}

- (void)getOutQuestGroup:(NSString *)groupURI
{
    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"getOutQuestGroup"];
    NSString *userURI = [KiiUser currentUser].objectURI;
    NSDictionary *argDict = [NSDictionary dictionaryWithObjectsAndKeys:groupURI,@"groupURI",userURI,@"userURI", nil];
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
    [entry execute:argument withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
        if (!error) {
            NSLog(@"%@",result);
        } else {
            NSLog(@"error:%@",error);
        }
    }];
}
- (void)showErrorMsg
{
    FUIAlertView *alert = [FUIAlertView errorTheme:@"エラー"];
    [alert show];
}


- (void)removeQuestGroup
{
    NSString *currentUserName = [KiiUser currentUser].displayName;
    NSString *questCreaterName = _quest.createdUserName;
    if ([currentUserName isEqualToString:questCreaterName]) {
        //オーナーです
    } else {
        FUIAlertView *alert = [FUIAlertView errorTheme:@"募集者以外は削除できません"];
        [alert show];
    }
    
}

#pragma  mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    return self.questMembersArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        GXDetailHeaderViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"Header"];
        headerCell.delegate = self;
        headerCell.quest = self.quest;
        
        if ([self isQuestOwner]) {
            [headerCell configureButtonForOwner];
        } else {
            [self isJoinedQuest:headerCell];
            
        }
        return headerCell;
    } else {
        //グループに参加しているuserを表示
        GXDetailViewMembersCell *membersCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        KiiObject *gx_user = self.questMembersArray[indexPath.row];
        membersCell.userIcon.profileID = [gx_user getObjectForKey:user_fb_id];
        membersCell.userNameLabel.text = [gx_user getObjectForKey:user_name];
        return membersCell;
        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = @"参加しているメンバ-";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;

}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 260.0f;
    }
    
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    
    return 34;
}

#pragma makr - Internal

//自分が作ったクエストか
- (BOOL)isQuestOwner
{
    BOOL ret = false;
    //自分が作ったクエストかどうか
    //NSString *currentUserName  = [KiiUser currentUser].displayName;
    NSString *currentUserName = [KiiUser currentUser].displayName;
    if ([currentUserName isEqualToString:self.quest.createdUserName]) {
        //リーダ権限をもつ
        ret = true;
    }
    
    return ret;

}

//参加済み・受注済みのクエストか
- (void)isJoinedQuest:(GXDetailHeaderViewCell *)cell
{
    KiiBucket *bucket = [GXBucketManager sharedManager].joinedQuest;
    KiiClause *clause1 = [KiiClause equals:@"title" value:self.quest.title];
    KiiClause *clause2 = [KiiClause equals:quest_isCompleted value:@NO];
    NSArray *clauseArray = [NSArray arrayWithObjects:clause1,clause2, nil];
    KiiClause *totalClause = [KiiClause andClauses:clauseArray];
    KiiQuery *query = [KiiQuery queryWithClause:totalClause];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (error) {
            NSLog(@"%s",__PRETTY_FUNCTION__);
            NSLog(@"error:%@",error);
        } else {
            if (results.count > 0) {
                //既に受注済み
                //join → start
                [cell configureButtonForJoiner:YES];
                [cell setNeedsLayout];
                [self getMemberList];
                [NSObject performBlock:^{
                    [self.tableView reloadData];
                } afterDelay:1.0f];
                
            } else {
                [cell configureButtonForJoiner:NO];
                [cell setNeedsLayout];
            }
        }
    }];
}

- (void)requestAddGroup
{
    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"addGroup"];
    NSString *groupURI = self.quest.groupURI;
    NSString *kiiuserURI = [KiiUser currentUser].objectURI;
    // KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
    KiiObject *gxUser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
    NSString *gxUserURI = gxUser.objectURI;
    
    NSDictionary *argDict = [NSDictionary dictionaryWithObjectsAndKeys:groupURI,@"groupURI",kiiuserURI,@"userURI",gxUserURI,@"gxURI", nil];
    
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
    
    [entry execute:argument withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
        NSDictionary *retDict = [result returnedValue];
        NSLog(@"returned:%@",retDict);
        [self addedGroup];
    }];
}
- (void)addedGroup
{
    NSError *error;
    //今選択しているobjのグループに参加したから
    NSString *groupURI = self.quest.groupURI;
    KiiGroup *joinedGroup = [KiiGroup groupWithURI:groupURI];
    [joinedGroup refreshSynchronous:&error];
    
    //トピック購読
    KiiTopic *topic = [joinedGroup topicWithName:@"quest_start"];
    [KiiPushSubscription subscribe:topic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
        if (error) NSLog(@"error:%@",error);
    }];
    
//    //参加したクエストを取得
//    KiiBucket *bucket = [joinedGroup bucketWithName:@"quest"];
//    KiiQuery *query = [KiiQuery queryWithClause:nil];
//    KiiObject *gxUser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
//    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
//        
//        if (!error) {
//            KiiObject *obj = results.firstObject;
//            //自分の参加済み協力クエに登録
////            [[GXBucketManager sharedManager] acceptNewQuest:self.quest];
//            //notJoinから消す
//            //[[GXBucketManager sharedManager] deleteJoinedQuest:self.willDeleteObjAtNotJoin];
//            //Activity
//            NSString *name = [gxUser getObjectForKey:user_name];
//            NSString *questName = [obj getObjectForKey:quest_title];
//            NSString *text = [NSString stringWithFormat:@"%@クエストに参加しました",questName];
//            [[GXActivityList sharedInstance] registerQuestActivity:name title:text fbid:[gxUser getObjectForKey:user_fb_id]];
//            
//            [[GXActionAnalyzer sharedInstance] setActionName:GXQuestJoin];
//        }
//    }];

    [[GXBucketManager sharedManager] acceptNewQuest:self.quest];
    
    //アクティビティとか
    KiiObject *gxUser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
    NSString *name = [gxUser getObjectForKey:user_name];
    //NSString *questName = [obj getObjectForKey:quest_title];
    NSString *questName = self.quest.title;
    NSString *text = [NSString stringWithFormat:@"%@クエストに参加しました",questName];
    [[GXActivityList sharedInstance] registerQuestActivity:name title:text fbid:[gxUser getObjectForKey:user_fb_id]];
    
    [[GXActionAnalyzer sharedInstance] setActionName:GXQuestJoin];

    
    KiiBucket *clearJudegeBucket = [joinedGroup bucketWithName:@"clear_judge"];
    [KiiPushSubscription subscribe:clearJudegeBucket withBlock:^(KiiPushSubscription *subscription, NSError *error) {
    }];
    
    CWStatusBarNotification *notis = [CWStatusBarNotification new];
    notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
    notis.notificationLabel.textColor = [UIColor cloudsColor];
    notis.notificationStyle = CWNotificationStyleNavigationBarNotification;
    [notis displayNotificationWithMessage:@"パーティーに参加しました!" forDuration:2.0f];
    
    [NSObject performBlock:^{
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } afterDelay:1.0f];
}

#pragma mark - HeaderView delegate
- (void)joinActionDelegate
{
    if (self.quest.isStarted) {
        FUIAlertView *alert = [FUIAlertView errorTheme:@"このクエストは開始済みです"];
        [alert show];
        return;
    }
    
    if (self.quest.isCompleted) {
        FUIAlertView *alert = [FUIAlertView errorTheme:@"このクエストはクリア済みです"];
        [alert show];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"クエスト受注中"];
    
    NSString *questType = self.quest.type;
    if ([questType isEqualToString:@"system"]) {
        //systemが毎日生成するデイリークエスト
        [[GXBucketManager sharedManager] acceptNewQuest:self.quest];
        [NSObject performBlock:^{
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        } afterDelay:2.0f];
        
    } else if ([questType isEqualToString:@"user"]) {
        //userが作成したクエスト
        //join
        [self requestAddGroup];
    }
    
}

- (void)questStatrtDelegate
{
    if (self.quest.isStarted) {
        FUIAlertView *alert = [FUIAlertView errorTheme:@"このクエストは開始済みです"];
        [alert show];
        return;
    }
    
    if (self.quest.isCompleted) {
        FUIAlertView *alert = [FUIAlertView errorTheme:@"このクエストはクリア済みです"];
        [alert show];
        return;
    }
    
    KiiClause *clause = [KiiClause equals:@"title" value:self.quest.title];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    KiiBucket *bucket;
    if ([self isQuestOwner]) {
        bucket = [GXBucketManager sharedManager].questBoard;
    } else {
        bucket = [GXBucketManager sharedManager].joinedQuest;
    }
    
    //KiiBucket *bucket = [GXBucketManager sharedManager].joinedQuest;
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        
        if (!error) {
          //  KiiObject *questObj = results.firstObject;
            self.selectedQuestObj = results.firstObject;
            
            //一人 (現状はシステムの作ったクエスト)
            if ([[self.selectedQuestObj getObjectForKey:quest_player_num] intValue] == 1) {
                [self gotoExeView:self.selectedQuestObj];
                return ;
            }
            
            if ([[KiiUser currentUser].displayName isEqualToString:self.quest.createdUserName]) {
                //groupViewへ
                [self performSegueWithIdentifier:@"groupView" sender:self];
                return;
            } else {
                // readyViewへ
                [self performSegueWithIdentifier:@"readyView" sender:self];
                return;
            }
        } else {
            NSLog(@"error----->");
        }

    }];
    
}

//受注したクエストを取り消す
- (void)questCacelDelegate
{
    FUIAlertView *alert = [FUIAlertView cautionTheme:@"受注を取り消しますか？"];
    alert.delegate = self;
    alert.tag = 0;
    [alert show];
}

//募集したクエストを削除する
- (void)questDeleteDelgate
{
    FUIAlertView *alert = [FUIAlertView cautionTheme:@"募集したクエストを削除しますか?"];
    alert.delegate = self;
    alert.tag = 1;
    [alert show];
}

#pragma mark - GXNotification
- (void)questJoined:(NSNotification *)notis
{
    CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationLabelBackgroundColor = [UIColor turquoiseColor];
    [notification displayNotificationWithMessage:@"クエストを受注しました" forDuration:2.0f];
}
- (void)errorHandler:(NSNotification *)notis
{
    NSString *msg = notis.object;
    CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationLabelBackgroundColor = [UIColor alizarinColor];
    [notification displayNotificationWithMessage:msg forDuration:2.0f];
}

#pragma mark - ButtonAction
- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PrepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"readyView"]) {
        
        GXQuestReadyViewController *vc = segue.destinationViewController;
        vc.willExeQuest = self.selectedQuestObj;
        vc.selectedQuestGroup = self.selectedQuestGroup;
        [GXExeQuestManager sharedManager].nowExeQuest = self.selectedQuestObj;
        
    } else if ([segue.identifier isEqualToString:@"groupView"]) {
        GXQuestGroupViewController *vc = segue.destinationViewController;
        vc.willExeQuest = self.selectedQuestObj;
        vc.selectedQuestGroup = self.selectedQuestGroup;
        [GXExeQuestManager sharedManager].nowExeQuest = self.selectedQuestObj;
        
    }
}

#pragma mark - segue
- (void)gotoExeView:(KiiObject *)questObj
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"subStoryboard" bundle:nil];
    GXQuestExeViewController *vc = [storyboard instantiateInitialViewController];
    vc.exeQuest = questObj; //JoinedBucket
    
    //notJoinBucketからデイリークエストを取得
    KiiBucket *bucket = [GXBucketManager sharedManager].notJoinedQuest;
    KiiClause *clause = [KiiClause equals:@"title" value:self.quest.title];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            [self presentViewController:vc animated:NO completion:^{
                //クエストマネージャーに
                [GXExeQuestManager sharedManager].nowExeQuest = questObj; //joinedBucket
                [GXExeQuestManager sharedManager].nowExeParentQuest = results.firstObject; //notJoin
            }];
        }
    }];
}

- (void)gotoGroupView:(KiiObject *)questObj
{
    
}

@end
