//
//  GXInviteQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXInviteQuestViewController.h"
#import "GXInvitedViewCell.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXBucketManager.h"

@interface GXInviteQuestViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *invitedQuestArray;

@end

@implementation GXInviteQuestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invitedQuestFetched:) name:GXInvitedQuestFetchedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[GXBucketManager sharedManager] getInvitedQuest];
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

- (void)configureCell:(GXInvitedViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSError *error;
    KiiObject *obj = self.invitedQuestArray[indexPath.row];
    KiiGroup *group = [KiiGroup groupWithURI:[obj getObjectForKey:quest_groupURI]];
    [group refreshSynchronous:&error];
    
    //自分がオーナかどうか
    if ([self isOwner:group]) {
        NSLog(@"オーナーです");
        [cell.cellButton setTitle:@"START!" forState:UIControlStateNormal];
        [cell.cellButton bk_addEventHandler:^(id sender) {
            NSLog(@"オーナーによるアクション");
        } forControlEvents:UIControlEventTouchUpInside];
    } else {
        NSLog(@"ノットオーナー");
        [cell.cellButton setTitle:@"JOIN" forState:UIControlStateNormal];
        [cell.cellButton bk_addEventHandler:^(id sender) {
            NSLog(@"参加者によるアクション");
            //オーナーにpush送って参加申請
            
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.title.text = [obj getObjectForKey:quest_title];
}

- (void)sendPushtoOwner:(KiiGroup *)group
{
    NSError *error;
    KiiUser *ownerUser = [group getOwnerSynchronous:&error];
    KiiTopic *topic = [ownerUser topicWithName:topic_invite];
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    NSDictionary *dict = @{@"join_user":[KiiUser currentUser].objectURI,@"group":group,push_type:push_invite};
    
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
    
    [topic sendMessageSynchronous:message withError:&error];

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

#pragma mark - GXNotification
- (void)invitedQuestFetched:(NSNotification *)info
{
    NSArray *array = info.object;
    self.invitedQuestArray = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
}



@end
