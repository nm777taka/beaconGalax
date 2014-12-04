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
#import <CWStatusBarNotification.h>
#import "GXQuestBucketManager.h"
#import "GXActivityList.h"
#import "GXExeQuestManager.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"
#import "FUIAlertView+GXTheme.h"
#import "GXNotification.h"
#import "GXGoogleTrackingManager.h"
#import "GXUserManager.h"

#define kNotjoin 0
#define kJoined 1
#define kInvite 2

@interface GXQuestDetailViewController()<FUIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *questTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *questClearReqLabel;
@property (weak, nonatomic) IBOutlet CSAnimationView *detailPanel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbIconView;
- (IBAction)questAction:(id)sender;
- (IBAction)questDeleteAction:(id)sender;
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
    [GXGoogleTrackingManager sendScreenTracking:@"questDetailView"];
}

- (void)configureDetailPanel
{
    _titleLabel.text = _quest.title;
    _fbIconView.profileID = _quest.fb_id;
    _questClearReqLabel.text = _quest.quest_req;
    _descriptionLabel.text = _quest.quest_des;
    
    _isMulti = [self isMultiQuest];
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

- (IBAction)questDeleteAction:(id)sender
{
    NSInteger viewControllerIndex = [self chekckQuestType];
    FUIAlertView *alert = [FUIAlertView cautionTheme:@"本当に削除しますか?"];
    alert.delegate = self;

    switch (viewControllerIndex) {
        case kNotjoin:
            alert.tag = kNotjoin;
            [alert show];
           break;
            
        case kJoined:
            alert.tag = kJoined;
            [alert show];
            break;
            
        case kInvite:
            alert.tag = kInvite;
            [alert show];
            break;
            
        default:
            break;
    }
    
}

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

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kNotjoin:
            if (buttonIndex == 1) {
                //削除実行
                [self delete];
            }
            break;
        
        case kJoined:
            if (buttonIndex == 1) {
                //削除実行
                [self deleteJoinedQuest];
                
            }
            break;
            
        case kInvite:
            if (buttonIndex == 1) {
                [self deleteInvitedQuest];
            }
            
        default:
            break;
    }

}

- (void)delete
{
    KiiObject *obj = [KiiObject objectWithURI:self.quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            //削除
            [object deleteWithBlock:^(KiiObject *object, NSError *error) {
                if (!error) {
                    NSLog(@"削除完了");
                    [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestDeletedNotification object:nil];
                    [self close];
                }
            }];
        }
    }];
}

- (void)deleteJoinedQuest
{
    if (_isMulti) {
        //協力クエストを削除
        //参加したけどやめる的な感じ
        //もしくはなにかしらのエラーで参加クエストが既にはじまってしまった場合
        //グループから自分を削除＆グループのメンバーバケットからも削除 (絶対必要となったらやる)
        
        //とりあえず消しとく
        //[self delete];
        
    } else {
        //一人用クエストを削除
        [self delete];
    }
}

- (void)deleteInvitedQuest
{
    //オーナーかどうか(オーナ以外は削除できない)
    NSString *currentUserName = [KiiUser currentUser].displayName;
    NSString *ownerName = _quest.createdUserName;
    if ([currentUserName isEqualToString:ownerName]) {
        //オーナー
        [self delete];
    } else {
        FUIAlertView *alert = [FUIAlertView errorTheme:@"募集者以外は削除できません"];
        [alert show];
    }
    
}

- (void)removeQuestGroup
{
    NSString *currentUserName = [KiiUser currentUser].displayName;
    NSString *questCreaterName = _quest.createdUserName;
    if ([currentUserName isEqualToString:questCreaterName]) {
        //オーナーです
        [self delete];
    } else {
        FUIAlertView *alert = [FUIAlertView errorTheme:@"募集者以外は削除できません"];
        [alert show];
    }
    
}




@end
