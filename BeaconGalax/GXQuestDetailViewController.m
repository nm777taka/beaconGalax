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
#import "GXUserManager.h"

#import "GXDetailHeaderViewCell.h"
#import "GXDetailTableViewCell.h"
#import "GXQuestList.h"
#import "GXQuest.h"

#define kNotjoin 0
#define kJoined 1
#define kInvite 2

@interface GXQuestDetailViewController()<FUIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,GXHeaderCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


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
    [self configureDetailPanel];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureDetailPanel
{
    
    _isMulti = [self isMultiQuest];
}

- (void)resizeLable:(UILabel *)label
{
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, 284, label.frame.size.height );
}
- (BOOL)isMultiQuest
{
    BOOL ret;
    if ([_quest.player_num intValue] > 1) {
        ret = YES;
    } else {
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
                    
                    [[GXActionAnalyzer sharedInstance] setActionName:GXQuestDelete];
                    
                }
            }];
        }
    }];
}

- (void)deleteJoinedQuest
{
    if (_isMulti) {
        //協力クエストを削除
      
        KiiObject *deleteObj = [KiiObject objectWithURI:self.quest.quest_id];
        [deleteObj refreshWithBlock:^(KiiObject *object, NSError *error) {
            KiiObject *deleteJoinedQuest = object;
            if (error) {
                [self showErrorMsg];
            } else {
                KiiGroup *targetGroup = [KiiGroup groupWithURI:[object getObjectForKey:quest_groupURI]];
                [targetGroup refreshWithBlock:^(KiiGroup *group, NSError *error) {
                    //もしかしたらオーナーが削除してるかも
                    if (error) {
                        [self showErrorMsg];
                    } else {
                        //グループのmemberバケットから自分を削除
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
                                    [deleteJoinedQuest deleteWithBlock:^(KiiObject *object, NSError *error) {
                                        NSLog(@"削除完了なり");
                                    }];
                                    
                                    //kiiGrupから消える
                                    [self getOutQuestGroup:group.objectURI];
                                    CWStatusBarNotification *notis = [CWStatusBarNotification new];
                                    notis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
                                    [notis displayNotificationWithMessage:@"削除しました" forDuration:2.0f];
                                    
                                }];
                            }
                        }];
                    }
                }];
            }
        }];
        
    } else {
        //一人用クエストを削除
        [self delete];
    }
}

- (void)getOutQuestGroup:(NSString *)groupURI
{
    NSLog(@"groupURI:%@",groupURI);
    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"getOutQuestGroup"];
    NSString *userURI = [KiiUser currentUser].objectURI;
    NSLog(@"userURI:%@",userURI);
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
    
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        GXDetailHeaderViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"Header"];
        headerCell.delegate = self;
        headerCell.quest = self.quest;
        return headerCell;
    }
    
    GXDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
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

#pragma HeaderView delegate
- (void)joinActionDelegate
{
    NSLog(@"joiniiii");
}

@end
