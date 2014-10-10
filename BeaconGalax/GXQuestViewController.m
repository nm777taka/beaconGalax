//
//  GXQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/08.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//
/*
 クエストに関するメモ
 クエストタイプ
 type:1 (beaconで○○に近づけ系)
 type:2 (beaconに○○時間滞在系)
 
 */

#import "GXQuestViewController.h"
#import "GXHomeCollectionViewCell.h"
#import "GXDescriptionViewController.h"
#import "GXBucketManager.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"

@interface GXQuestViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

- (IBAction)createNewQuest:(id)sender;
@property GXDescriptionViewController *descriptionViewContoller;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSArray *textArray;
@property NSMutableArray *objects;
@property KiiObject *selectedObject;
@end

@implementation GXQuestViewController{
    UIRefreshControl *_refreshControl;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    _objects = [NSMutableArray new];
    
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
    
    _descriptionViewContoller = [[self storyboard] instantiateViewControllerWithIdentifier:@"DescriptionView"];
    
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questFetched:) name:GXFetchQuestNotComplitedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinQuestHandler:) name:GXQuestJoinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(missionFetched:) name:GXFetchMissionWithNotCompletedNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![KiiUser loggedIn]) {
        
        //ログイン画面へ遷移
        [self performSegueWithIdentifier:@"gotoLoginView" sender:self];
    } else {
        //DBからフェッチ(非同期)
        //最終的に変更があった場合のみにしたい
        //[[GXBucketManager sharedManager] fetchQuestWithNotComplited];
        [[GXBucketManager sharedManager] getQuestForQuestBoard];

    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GXHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)configureCell:(GXHomeCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *quest = self.objects[indexPath.row];
    
    cell.titleLable.text = [quest getObjectForKey:quest_title];
    cell.desLabel.text = [quest getObjectForKey:quest_description];
    NSNumber *num = [quest getObjectForKey:quest_reward];
    cell.rewardLabel.text = [NSString stringWithFormat:@"%d",[num intValue]];
    
}


#pragma  mark - refresh
- (void)refresh:(id)sender
{
    [_refreshControl beginRefreshing];
    
    [self.collectionView reloadData];
    
    [_refreshControl endRefreshing];
}
#pragma mark Notification
- (void)questFetched:(NSNotification *)info
{
    NSArray *array = info.object;
    self.objects = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];

}

- (void)missionFetched:(NSNotification *)info
{
    NSArray *array = info.object;
    self.objects = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
}

//カスタムcellクラスでタッチイベントを処理してる
- (void)joinQuestHandler:(NSNotification *)notification
{
    GXHomeCollectionViewCell *cell = notification.object;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    KiiObject *object = self.objects[indexPath.row];
    
    if ([[object getObjectForKey:quest_player] intValue] > 1) {
        //invite_boardへ
        NSLog(@"みんな用です");
        //すでに募集済みかどうか
        BOOL ret = [[GXBucketManager sharedManager] isInvitedQuest:object];
        if (ret) {
            NSLog(@"募集済みです");
        } else {
            NSLog(@"募集されてません");
            [[GXBucketManager sharedManager] registerInviteBoard:object];
        }

    } else {
     
        NSLog(@"ひとりようです");
    }
    
    [[GXBucketManager sharedManager] registerJoinedQuest:object];
    
    
    //--------------------------->
    //ユーザがつくる場合
    //--------------------------->
    //作成者に参加申請pushをおくる
    /*
    NSString *ownerUserURI = [object getObjectForKey:quest_createUserURI];
    KiiUser *ownerUser = [KiiUser userWithURI:ownerUserURI];
    NSString *joinQuestGroup = [object getObjectForKey:quest_groupURI];
    NSLog(@"-------> group : %@",joinQuestGroup);
    
    KiiTopic *topic = [ownerUser topicWithName:topic_invite];
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    
    NSDictionary *dictionary = @{@"join_user":[KiiUser currentUser].objectURI,
                                 @"group":joinQuestGroup,push_type:push_invite};
    //slient
    [apnsFields setContentAvailable:@1];
    
    [apnsFields setSpecificData:dictionary];
    
    KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFields
                                                              andGCMFields:nil];
    
    //ペイロードを削る
    [message setSendSender:[NSNumber numberWithBool:NO]];
    // Disable "w" field
    [message setSendWhen:[NSNumber numberWithBool:NO]];
    // Disable "to" field
    [message setSendTopicID:[NSNumber numberWithBool:NO]];
    // Disable "sa", "st" and "su" field
    [message setSendObjectScope:[NSNumber numberWithBool:NO]];
    
    NSError *error = nil;
    
    [topic sendMessageSynchronous:message
                        withError:&error];
    if (error != nil) {
        // There was a problem.
        NSLog(@"参加処理でエラー");
        NSLog(@"error:%@",error);
    }*/
    
}

#pragma mark Button_Action
#pragma mark -- サーバーコードのテスト
- (IBAction)createNewQuest:(id)sender
{
    
//    NSLog(@"call");
//    KiiServerCodeEntry* entry =[Kii serverCodeEntry:@"main"];
//    
//    //実行時パラメータ
//    KiiUser *currUser = [KiiUser currentUser];
//    NSDictionary *argDict = @{@"aaa":@"username",@"bbb":@"password"};
//    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
//    NSError* error = nil;
//    
//    
//    KiiServerCodeExecResult* result = [entry executeSynchronous:argument
//                                                      withError:&error];
//    
//    // Parse the result.
//    NSDictionary *returnedDict = [result returnedValue];
//    NSString *returnString = [returnedDict objectForKey:@"returnedValue"];
//    
//    NSLog(@"%@",returnString);
}


#pragma mark segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"gotoDescriptionView"]) {
        GXDescriptionViewController *vc = segue.destinationViewController;
        vc.object = _selectedObject;
    }
}

- (IBAction)dataSourceChange:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0: // quest
            
            [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
            
            break;
            
        case 1: //mission
            
            [[GXBucketManager sharedManager] fetchMissionWithNotCompleted];
            
            
            break;
            
        default:
            break;
    }
}

@end
