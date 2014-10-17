//
//  GXQuestGroupViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/16.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestGroupViewController.h"
#import "GXQuestGroupViewCell.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXBucketManager.h"

@interface GXQuestGroupViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *questMemberArray;

@property KiiGroup *questGroup;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end

@implementation GXQuestGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //Notificaiton
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memberFetched:) name:GXGroupMemberFetchedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questStart:) name:GXStartQuestNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [SVProgressHUD showWithStatus:@"メンバーを取得中"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //メンバーフェッチ
    NSString *groupURI = [self.selectedObj getObjectForKey:quest_groupURI];
    self.questGroup = [KiiGroup groupWithURI:groupURI];
    [self.questGroup refreshWithBlock:^(KiiGroup *group, NSError *error) {
        if (error) NSLog(@"error:%@",error);
        else
            [[GXBucketManager sharedManager] getQuestMember:group];
        
        //現在ログイン中のユーザがオーナーかどうかでUIを変える
        if ([self isCurrentUserOwner:self.questGroup]) {
            //オーナー
            [self.actionButton setTitle:@"Start" forState:UIControlStateNormal];
            [self.actionButton bk_addEventHandler:^(id sender) {
                
                if ([[self.selectedObj getObjectForKey:quest_isReady_num] intValue] > 0 ) {
                    NSLog(@"開始処理できます");
                    [SVProgressHUD showWithStatus:@"クエストを開始しています"];
                    NSError *error;
                    KiiTopic *startTopic = [self.questGroup topicWithName:@"quest_start"];
                    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
                    KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
                    [startTopic sendMessageSynchronous:message withError:&error];
                    if (error) {
                        NSLog(@"error:%@",error);
                        [SVProgressHUD showErrorWithStatus:@"クエストを開始できません"];
                    } else {
                        NSLog(@"送信完了");
                        [NSTimer bk_scheduledTimerWithTimeInterval:3.0 block:^(NSTimer *timer) {
                            [self performSegueWithIdentifier:@"test" sender:self];
                            [SVProgressHUD dismiss];
                        } repeats:NO];
                        
                    }
                }
                
            } forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            //参加者
            [self.actionButton setTitle:@"準備完了" forState:UIControlStateNormal];
            
            [self.actionButton bk_addEventHandler:^(id sender) {
                
                //準備完了処理
                //クエストにできたよーって書き込む
                NSError *error;
                int isReadyNum = [[self.selectedObj getObjectForKey:quest_isReady_num] intValue];
                isReadyNum++;
                NSNumber *newValue = [NSNumber numberWithInt:isReadyNum];
                [self.selectedObj setObject:newValue forKey:quest_isReady_num];
                [self.selectedObj saveSynchronous:&error];
                if (error) NSLog(@"error:%@",error);
                
                //自分のステータス(cell用)
                for (KiiObject *obj in self.questMemberArray) {
                    
                    if ([[obj getObjectForKey:@"uri"] isEqualToString:[KiiUser currentUser].objectURI]) {
                        
                        //準備完了じゃなかったら→完了へ
                        if ([[obj getObjectForKey:user_isReady] isEqualToNumber:@NO]) {
                            [obj setObject:@YES forKey:user_isReady];
                            [obj saveSynchronous:&error];
                            [self.collectionView reloadData];
                        }
                        
                    }
                }
                
            } forControlEvents:UIControlEventTouchUpInside];
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
    
    if (member) {
        cell.userName.text = [member getObjectForKey:user_name];
        cell.userIcon.profileID = [member getObjectForKey:user_fb_id];
        
        if ([[member getObjectForKey:user_isReady] isEqualToNumber:@YES]) {
            cell.backgroundColor = FlatSkyBlue;
        }
        
        if ([self isOwer:(int)indexPath.row]) {
            
            cell.backgroundColor = FlatWatermelon;

        }else {
            
        }
            
    }

}

- (void)configureOwnerCell:(GXQuestGroupViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)configureParticipantCell:(GXQuestGroupViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
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
    [SVProgressHUD showSuccessWithStatus:@"取得完了"];
}

- (void)questStart:(NSNotification *)notis
{
    NSLog(@"クエストスタート!!");
    [SVProgressHUD showWithStatus:@"クエストを開始します"];
    [NSTimer bk_scheduledTimerWithTimeInterval:3.0f block:^(NSTimer *timer) {
        [self performSegueWithIdentifier:@"test" sender:self];
        [SVProgressHUD dismiss];
    } repeats:NO];
}

@end
