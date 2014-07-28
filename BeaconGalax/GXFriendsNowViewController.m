//
//  GXFriendsNowViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXFriendsNowViewController.h"
#import "GXCollectionViewCell.h"


@interface GXFriendsNowViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSMutableArray *dataSource;
@end

@implementation GXFriendsNowViewController

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
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.dataSource = [NSMutableArray new];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    return self.questArray.count;
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    GXCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    
    
    return cell;
    
}

#pragma mark CollectionViewDelegate


#pragma mark ConfigureCell
- (void)configureCell:(GXCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 5.0f;
    //cell.layer.masksToBounds = NO; //これ絶対
    //    cell.layer.shadowOffset = CGSizeMake(0,3);
    //    cell.layer.shadowColor = [UIColor asbestosColor].CGColor;
    //    cell.layer.shadowOpacity = 0.8;
    cell.layer.shadowPath = [[UIBezierPath bezierPathWithRect:cell.bounds] CGPath];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.backgroundColor = [UIColor colorWithRed:0.950 green:0.435 blue:0.511 alpha:1.000];
    
    //    KiiObject *quest = self.questArray[indexPath.row];
    //    cell.questNameLabel.text = [quest getObjectForKey:@"title"];

    
    
}

@end
