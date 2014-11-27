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
#import "GXQuestBucketManager.h"
#import "GXActivityList.h"
#import "GXExeQuestManager.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"

@interface GXQuestDetailViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *questTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *questClearReqLabel;
@property (weak, nonatomic) IBOutlet CSAnimationView *detailPanel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbIconView;
- (IBAction)questAction:(id)sender;
- (IBAction)closeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *questActionButton;

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
    _fbIconView.layer.cornerRadius = 20.f;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.alpha = 1.0f;
    [self.detailPanel startCanvasAnimation];
    [self configureDetailPanel];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)configureDetailPanel
{
    _titleLabel.text = _quest.title;
    _fbIconView.profileID = _quest.fb_id;
    _questClearReqLabel.text = _quest.quest_req;
    _descriptionLabel.text = _quest.quest_des;
    
    _isMulti = [self isMultiQuest];
    
    NSInteger questType = [self chekckQuestType];
    
    switch (questType) {
        case 0: //新しいクエ
            NSLog(@"notjoin");
            if (_isMulti) {
                [self.questActionButton setTitle:@"募集" forState:UIControlStateNormal];
                [self.questActionButton addTarget:self action:@selector(inviteQuestHandler) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [self.questActionButton setTitle:@"受注" forState:UIControlStateNormal];
                [self.questActionButton addTarget:self action:@selector(acceptNewQuest) forControlEvents:UIControlEventTouchUpInside];
            }
            break;
            
        case 1://受注済み
            NSLog(@"joined");
            [self.questActionButton setTitle:@"開始" forState:UIControlStateNormal];
            [self.questActionButton addTarget:self action:@selector(joinedQuestStart) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case 2: //募集
            NSLog(@"invite");
            //募集者かどうかをチェック
            _isOwner = [self isQuestInviter];
            if (_isOwner) {
                NSLog(@"enter");
                [self.questActionButton setTitle:@"開始" forState:UIControlStateNormal];
                [self.questActionButton addTarget:self action:@selector(multiQuestStart) forControlEvents:UIControlEventTouchUpInside];
                
            } else {
                NSLog(@"enter1");
                [self.questActionButton setTitle:@"参加" forState:UIControlStateNormal];
                //参加ハンドラーへ
                [self.questActionButton addTarget:self action:@selector(requestAddQuestGroup) forControlEvents:UIControlEventTouchUpInside];
            }
            break;
            
        default:
            break;
    }
    
}

- (BOOL)isQuestInviter
{
    BOOL ret;
    NSString *name = [[GXUserManager sharedManager].gxUser getObjectForKey:user_name];
    if ([name isEqualToString:_quest.owner]) {
        NSLog(@"募集者です");
        ret = YES;
    } else {
        ret = NO;
    }
    return ret;
}

- (BOOL)isAlreadyJoinedParty
{
    NSError *error;
    KiiObject *obj = [KiiObject objectWithURI:_quest.quest_id];
    [obj refreshSynchronous:&error];
    KiiGroup *group = [KiiGroup groupWithURI:[obj getObjectForKey:quest_groupURI]];
    [group refreshSynchronous:&error];
    
    BOOL ret = false;
    NSArray *members = [group getMemberListSynchronous:&error];
    for (KiiUser *user in members) {
        if ([user.objectURI isEqualToString:[KiiUser currentUser].objectURI]) {
            ret = YES;
            break;
        } else {
            ret = false;
        }
    }
    
    return ret;
}

- (BOOL)isMultiQuest
{
    BOOL ret;
    if ([_quest.player_num intValue] > 1) {
        _questTypeLabel.text = @"みんなでクエスト";
        ret = YES;
    } else {
        _questTypeLabel.text = @"ひとりでクエスト";
        ret = NO;
    }
    
    return ret;
}

- (NSInteger)chekckQuestType
{
    NSInteger ret;
    KiiBucket *currentBucket = _quest.bucket;
    if ([currentBucket isEqual:[GXBucketManager sharedManager].notJoinedQuest]) {
        ret = 0;
    } else if ([currentBucket isEqual:[GXBucketManager sharedManager].joinedQuest]) {
        ret = 1;
    } else {
        ret = 2;
    }
    
    return ret;
}

#pragma mark - TODO
#pragma ButtonAction

- (IBAction)closeAction:(id)sender {
    
    [self close];
}

- (void)close
{
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.view.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];

}

#pragma mark - QuestBotton Selector
//新しいクエストを受注(一人用)
- (void)acceptNewQuest
{
    KiiObject *obj = [KiiObject objectWithURI:_quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (error) {
        } else {
            [[GXBucketManager sharedManager] acceptNewQuest:object];
            [[GXBucketManager sharedManager] deleteJoinedQuest:object];

        }
    }];
}

//参加済みの一人クエストを開始
- (void)joinedQuestStart
{
    KiiObject *obj = [KiiObject objectWithURI:_quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            if (_isMulti) {
                //協力型
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoMemberView" object:object];
                [self.view removeFromSuperview];
                
            } else {
                //一人用だったら開始
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"subStoryboard" bundle:nil];
                GXQuestExeViewController *initialViewController = [storyboard instantiateInitialViewController];
                initialViewController.exeQuest = obj;
                [self presentViewController:initialViewController animated:YES completion:^{
                    //QMで管理
                    [GXExeQuestManager sharedManager].nowExeQuest = obj;
                    [self.view removeFromSuperview];
                }];
            }
        }
    }];
}

//クエストを募集する(協力型クエスト)
- (void)inviteQuestHandler
{
    KiiObject *obj = [KiiObject objectWithURI:_quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            [[GXBucketManager sharedManager] registerInviteBoard:obj];
            [[GXBucketManager sharedManager] deleteJoinedQuest:obj];
            
            [self close];
        }
    }];
    
}

//マルチクエストをスタート (リーダー)
- (void)multiQuestStart
{
    KiiObject *obj = [KiiObject objectWithURI:_quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoMemberView" object:object];
            [self.view removeFromSuperview];

        }
    }];
}

//協力型クエストのパーティーに参加する
- (void)requestAddQuestGroup
{
    [SVProgressHUD showWithStatus:@"パーティー参加申請中"];
    
    if ([self isAlreadyJoinedParty]) {
        CWStatusBarNotification *notification = [CWStatusBarNotification new];
        notification.notificationLabelBackgroundColor = [UIColor alizarinColor];
        notification.notificationStyle =CWNotificationStyleNavigationBarNotification;
        [notification displayNotificationWithMessage:@"既に参加済みです" forDuration:2.0f];
        
        [SVProgressHUD dismiss];
        return;
    }
    
    KiiObject *obj = [KiiObject objectWithURI:_quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            
            KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"addGroup"];
            NSString *groupURI = [object getObjectForKey:quest_groupURI];
            NSString *kiiuserURI = [KiiUser currentUser].objectURI;
            KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
            NSString *gxUserURI = gxUser.objectURI;
            
            NSDictionary *argDict = [NSDictionary dictionaryWithObjectsAndKeys:groupURI,@"groupURI",kiiuserURI,@"userURI",gxUserURI,@"gxURI", nil];
            
            KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
            
            [entry execute:argument withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
                NSDictionary *retDict = [result returnedValue];
                NSLog(@"returned:%@",retDict);
                [self addedGroup:object];
            }];
        }
    }];
}

- (void)addedGroup:(KiiObject *)obj
{
    NSError *error;
    //今選択しているobjのグループに参加したから
    NSString *groupURI = [obj getObjectForKey:quest_groupURI];
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
            [[GXBucketManager sharedManager] acceptNewQuest:obj];
            //notJoinから消す
//            [[GXBucketManager sharedManager] deleteJoinedQuest:self.willDeleteObjAtNotJoin];
            //Activity
            KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
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
    
    CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationLabelBackgroundColor = [UIColor turquoiseColor];
    notification.notificationStyle = CWNotificationStyleNavigationBarNotification;
    [notification displayNotificationWithMessage:@"パーティーに参加しました" forDuration:2.0f];
    
    [self close];
}



#pragma mark - Segue

@end
