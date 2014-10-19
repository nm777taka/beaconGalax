//
//  GXClearViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXClearViewController.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXQuestViewController.h"
#import "GXInviteQuestViewController.h"
#import "GXFrostedViewController.h"

@interface GXClearViewController ()


@end

@implementation GXClearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"point:%d",self.point);
    [self registerPoint];
    [NSTimer bk_scheduledTimerWithTimeInterval:3.0 block:^(NSTimer *timer) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Congratulation" message:@"クエストクリアおめでとうございます" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self deleteMultiQuest];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];

    } repeats:NO];
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

- (void)registerPoint
{
    NSError *error;
    KiiBucket *pointBucket = [[KiiUser currentUser] bucketWithName:@"point"];
    KiiObject *point = [pointBucket createObject];
    [point setObject:[NSNumber numberWithInt:self.point] forKey:@"point"];
    [point saveSynchronous:&error];
    if (error) {
        NSLog(@"ポイントゲットエラー:%@",error);
    } else {
        NSLog(@"ポイントゲット");
    }
    
}

- (void)deleteMultiQuest
{
    [SVProgressHUD showWithStatus:@"完了したクエストを処理しています"];

    //オーナーがやる
    //isOwner?
    NSError *error;
    KiiUser *owner = [self.group getOwnerSynchronous:&error];
    KiiUser *currUser = [KiiUser currentUser];
    if ([owner isEqual:currUser]) {
        //募集ボードから消す（オーナー）
        KiiClause *clause = [KiiClause equals:@"uri" value:[self.quest getObjectForKey:@"uri"]];
        KiiQuery *query = [KiiQuery queryWithClause:clause];
        KiiQuery *nextQuery;
        KiiBucket *inviteBucket = [Kii bucketWithName:@"invite_board"];
        NSArray *result_inviteBoard = [inviteBucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
        if (error) {
            NSLog(@"fetchError:%@",error);
        } else {
            if (result_inviteBoard.count == 1) {
                KiiObject *deleteObj = result_inviteBoard.firstObject;
                [deleteObj deleteSynchronous:&error];
                if (error) {
                    NSLog(@"deleteError:%@",error);
                } else {
                    NSLog(@"完了したクエストを削除完了");
                }
            }
        }
        
        [self completeJoinedMultiQuest];
        
        //参加者
        
    } else {
        [self completeJoinedMultiQuest];
    }
}

- (void)completeJoinedMultiQuest
{
    NSError *error;
    KiiUser *currUser = [KiiUser currentUser];
    KiiBucket *joinedMultiBucket = [[KiiUser currentUser] bucketWithName:@"joined_multiPersonQuest"];
    KiiClause *clause = [KiiClause equals:@"uri" value:[self.quest getObjectForKey:@"uri"]];
    KiiQuery *query = [KiiQuery queryWithClause:clause];
    KiiQuery *nextQuery;
    NSArray *results = [joinedMultiBucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    if (error) {
        NSLog(@"fetchError:%@",error);
    } else {
        if (results.count == 1) {
            KiiObject *obj = results.firstObject;
            [obj setObject:@YES forKey:quest_isCompleted];
            [obj saveSynchronous:&error];
            if (!error) {
                [SVProgressHUD dismiss];
            }
        }
    }

}


@end
