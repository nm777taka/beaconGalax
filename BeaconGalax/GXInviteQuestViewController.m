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
    } else {
        NSLog(@"ノットオーナー");
    }
    
    cell.title.text = [obj getObjectForKey:quest_title];
}

- (BOOL)isOwner:(KiiGroup *)group
{
    BOOL __block ret;
    [group getOwnerWithBlock:^(KiiGroup *group, KiiUser *owner, NSError *error) {
        KiiUser *currentUser = [KiiUser currentUser];
        if ([currentUser.objectURI isEqual:owner.objectURI]) {
            
            ret = true;
            
        } else {
            ret = false;
        }
    }];
    
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
