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
#import "GXBucketManager.h"

@interface GXQuestGroupViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *questMemberArray;

@end

@implementation GXQuestGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [SVProgressHUD showWithStatus:@"メンバーを取得中"];
    
    //メンバーフェッチ
    NSString *groupURI = [self.selectedObj getObjectForKey:quest_groupURI];
    KiiGroup *group = [KiiGroup groupWithURI:groupURI];
    NSLog(@"selected groupURI:%@",group);
    [group refreshWithBlock:^(KiiGroup *group, NSError *error) {
        if (error) NSLog(@"error:%@",error);
        else [group getMemberListWithBlock:^(KiiGroup *group, NSArray *members, NSError *error) {
            if (error) NSLog(@"error:%@",error);
            else {
                self.questMemberArray = [NSMutableArray arrayWithArray:members];
                
                [self.collectionView reloadData];
                
                [SVProgressHUD dismiss];
            }
        }];
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
    
    KiiUser *user = self.questMemberArray[indexPath.row];
    KiiObject *gxUser = [[GXBucketManager sharedManager] getGalaxUser:user.objectURI];
    if (gxUser) {
        cell.userName.text = [gxUser getObjectForKey:user_name];
        cell.userIcon.profileID = [gxUser getObjectForKey:user_fb_id];
    }

}



@end
