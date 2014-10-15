//
//  GXQuestGroupViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/16.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestGroupViewController.h"
#import "GXQuestGroupViewCell.h"

@interface GXQuestGroupViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *questMemberArray;

@end

@implementation GXQuestGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GXQuestGroupViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GXQuestGroupViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}
- (IBAction)backView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
