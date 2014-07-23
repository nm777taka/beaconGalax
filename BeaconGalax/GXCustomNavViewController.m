//
//  GXCustomNavViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCustomNavViewController.h"
#import "GXCustomNavViewCell.h"

@interface GXCustomNavViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *navCollectionView;
@property NSArray *navList;

@end

@implementation GXCustomNavViewController

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
    // Do any additional setup after loading the view.
    self.navCollectionView.delegate = self;
    self.navCollectionView.dataSource = self;
    
    self.navList = [NSArray new];
    self.navList = @[@"ホーム",@"クエスト",@"友達の動き",@"フレンド",@"自分",@"トロフィ-",@"セッティング"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.navList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    GXCustomNavViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:(GXCustomNavViewCell *)cell atIndexPath:(NSIndexPath *)indexPath];
    
    return cell;
    
}

- (void)configureCell:(GXCustomNavViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.viewNameLabel.text = self.navList[indexPath.row];
}

#pragma mark - CollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected Cell is %d",indexPath.row);
}
@end
