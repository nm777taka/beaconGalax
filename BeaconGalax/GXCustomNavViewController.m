//
//  GXCustomNavViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCustomNavViewController.h"
#import "GXCustomNavViewCell.h"
#import "GXNotification.h"
#import "GXNavigationItem.h"

#define CORNER_RADIUS 2
#define SHADOW_RADIUS 3
#define SHADOW_OPACITY 0.5

@interface GXCustomNavViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *navCollectionView;
@property NSArray *navList;
@property NSDictionary *navImageDict;
@property NSMutableArray *collectionDataSource;
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
    
    _navImageDict = @{@"0":[UIImage imageNamed:@"home.png"],
                      @"1":[UIImage imageNamed:@"quest.png"],
                      @"2":[UIImage imageNamed:@"friendNow.png"],
                      @"3":[UIImage imageNamed:@"friend.png"]};
    
    _collectionDataSource = [NSMutableArray new];
    
    [self configureNavigationItem];
    
    //最初はhomeViewにいるため
    GXNavigationItem *first = _collectionDataSource.firstObject;
    first.isSelected = YES;
    
    
    //ドロップシャドウ
    self.view.layer.masksToBounds = NO;
    self.view.layer.cornerRadius = CORNER_RADIUS;
    self.view.layer.shadowOffset = CGSizeMake(0, 2);
    self.view.layer.shadowRadius = SHADOW_RADIUS;
    self.view.layer.shadowOpacity = SHADOW_OPACITY;
}

//init
- (void)configureNavigationItem
{
    for (NSString *name in _navList) {
        GXNavigationItem *navigationItem = [GXNavigationItem new];
        navigationItem.viewName = name;
        navigationItem.isSelected = NO;
        [_collectionDataSource addObject:navigationItem];
    }
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
    return _collectionDataSource.count;
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
    GXNavigationItem *item;
    item = _collectionDataSource[indexPath.row];
    cell.viewNameLabel.text = item.viewName;
    cell.viewNameLabel.font = [UIFont boldFlatFontOfSize:12];
    cell.viewIcon.image = _navImageDict[[NSString stringWithFormat:@"%d",indexPath.row]];
    
    //選択されたindicatorを黒くする
    if (item.isSelected) {
        cell.indicator.hidden = NO;
        cell.indicator.backgroundColor = [UIColor blackColor];
    } else {
        cell.indicator.hidden = YES;
    }
    
}

#pragma mark - CollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    
    GXNavigationItem *selectedItem = _collectionDataSource[indexPath.row];
    selectedItem.isSelected = YES;
    
    for (GXNavigationItem *item in _collectionDataSource) {
        if (item.isSelected == YES) {
            if ([item.viewName isEqualToString:selectedItem.viewName]) {
                //
            } else {
                item.isSelected = NO;
            }
        }
    }
    
    [_navCollectionView reloadData];
        
    NSNumber *num = [NSNumber numberWithInteger:indexPath.row];
    
    switch (indexPath.row) {
        case 0:
            [[NSNotificationCenter defaultCenter] postNotificationName:GXViewSegueNotification object:num];
            break;
        case 1:
            [[NSNotificationCenter defaultCenter] postNotificationName:GXViewSegueNotification object:num];
            break;
        
        case 2:
            [[NSNotificationCenter defaultCenter] postNotificationName:GXViewSegueNotification object:num];
            break;
            
        case 3:
            [[NSNotificationCenter defaultCenter] postNotificationName:GXViewSegueNotification object:num];
            break;
            
        case 4:
            [[NSNotificationCenter defaultCenter] postNotificationName:GXViewSegueNotification object:num];
            break;
            
        default:
            break;
    }
    
    
    
}


@end
