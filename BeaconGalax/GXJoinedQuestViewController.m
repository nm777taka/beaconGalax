//
//  GXJoinedQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXJoinedQuestViewController.h"
#import "GXQuestDetailViewController.h"
#import "GXJoinedQuestCollectionViewCell.h"
#import "GXQuestExeViewController.h"

#import "GXBucketManager.h"
#import "GXExeQuestManager.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"
#import "FUIAlertView+GXTheme.h"

//model
#import "GXQuest.h"
#import "GXQuestList.h"

#import "GXGoogleTrackingManager.h"

@interface GXJoinedQuestViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,GXQuestListDelegate,FUIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) GXQuestDetailViewController *detailViewController;
@property (nonatomic,strong) GXQuestList *questList;
@property (nonatomic,strong) GXQuest *selectedQuest;

@end

@implementation GXJoinedQuestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor turquoiseColor];
    _questList = [[GXQuestList alloc ] initWithDelegate:self];
    
    //詳細viewを取得
    self.detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    [self.questList requestAsyncronous:1];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showInfo:) name:@"showInfo" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [GXGoogleTrackingManager sendScreenTracking:@"joinedQuestView"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
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
    return [_questList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GXJoinedQuestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    //modelの設定
    cell.quest = [_questList questAtIndex:indexPath.row];
    cell.createrIcon.layer.borderColor = [UIColor turquoiseColor].CGColor;
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedQuest = [_questList questAtIndex:indexPath.row];
    FUIAlertView *alert = [FUIAlertView questStartAlertTheme];
    alert.delegate = self;
    [alert show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)request:(NSInteger)index
{
    if (_questList.loading) {
    } else {
        [SVProgressHUD showWithStatus:@"データ更新中"];
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

#pragma markr - Notification
- (void)showInfo:(NSNotification *)notis
{
    GXJoinedQuestCollectionViewCell *cell = notis.object;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (self.detailViewController) {
        self.detailViewController.quest = [_questList questAtIndex:indexPath.row];
        [self.view addSubview:self.detailViewController.view];
    }
}

#pragma mark - FUIAlert
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self questStartSequence];
    }
}

- (void)questStartSequence
{
    [SVProgressHUD showWithStatus:@"クエスト開始処理中"];
    GXQuest *quest = _selectedQuest;
    KiiObject *obj = [KiiObject objectWithURI:quest.quest_id];
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (!error) {
            [SVProgressHUD dismiss];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"subStoryboard" bundle:nil];
            GXQuestExeViewController *vc  = [storyboard instantiateInitialViewController];
            vc.exeQuest = object;
            [GXGoogleTrackingManager sendEventTracking:@"Quest" action:@"start_one" label:@"一人クエスト開始" value:nil screen:@"joinedQuestView"];
            [self presentViewController:vc animated:YES completion:^{
                //QMで管理
                [GXExeQuestManager sharedManager].nowExeQuest = object;
            }];
        }
    }];
}
@end
