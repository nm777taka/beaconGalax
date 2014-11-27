//
//  GXQuestDetailViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestDetailViewController.h"
#import "GXQuestExeViewController.h"
#import "GXQuestBucketManager.h"
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
    
    BOOL isMulti = [self isMultiQuest];
    
    NSInteger questType = [self chekckQuestType];
    switch (questType) {
        case 0: //新しいクエ
            NSLog(@"notjoin");
            if (isMulti) {
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
                [self.questActionButton setTitle:@"開始" forState:UIControlStateNormal];
                [self.questActionButton addTarget:self action:@selector(multiQuestStart) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [self.questActionButton setTitle:@"参加" forState:UIControlStateNormal];
                //参加ハンドラーへ

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
    } else if ([currentBucket isEqual:[GXBucketManager sharedManager].inviteBoard]) {
        ret = 2;
    }
    
    return ret;
}

#pragma mark - TODO
#pragma ButtonAction
- (IBAction)questAction:(id)sender {
    
    //とりあえず参加してみる
    //questTypeのチェックが必要
    //どのバケット？何人用？
    //[[GXQuestBucketManager sharedInstance] requestJoinNewQuest:_quest];
}

- (IBAction)closeAction:(id)sender {
    
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
//新しいクエスト
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
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"subStoryboard" bundle:nil];
            GXQuestExeViewController *initialViewController = [storyboard instantiateInitialViewController];
            initialViewController.exeQuest = obj;
            [self presentViewController:initialViewController animated:YES completion:^{
                //QMで管理
                [GXExeQuestManager sharedManager].nowExeQuest = obj;
                [self.view removeFromSuperview];
            }];
        } else {
            NSLog(@"error:%@",error);
        }
    }];
}

//クエストを募集する
- (void)inviteQuestHandler
{
    KiiObject *obj = [KiiObject objectWithURI:_quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            [[GXBucketManager sharedManager] registerInviteBoard:obj];
            [[GXBucketManager sharedManager] deleteJoinedQuest:obj];
        }
    }];
    
}

//マルチクエストをスタート
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

#pragma mark - Segue

@end
