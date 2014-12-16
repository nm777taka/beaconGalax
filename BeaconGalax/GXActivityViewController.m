//
//  GXActivityViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXActivityViewController.h"
#import "GXActivityTableViewCell.h"
#import <REFrostedViewController.h>

#import "GXActivity.h"
#import "GXActivityList.h"

#import "GXBucketManager.h"

#import "GXGoogleTrackingManager.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] \
compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface GXActivityViewController ()<UITableViewDataSource,UITableViewDelegate,GXActivityListDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) GXActivityList *activityList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation GXActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        //ios 7.x
    } else {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    self.title = @"みんなの動き";
        
    _activityList = [[GXActivityList alloc] initWithDelegate:self];
    
    UIImage *image = [UIImage imageNamed:@"someImage"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [button addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = navLeftButton;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.indicator startAnimating];
    [_activityList requestAsynchronous];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GXGoogleTrackingManager sendScreenTracking:@"activityView"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableVieDataSouce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _activityList.count;
}

#pragma mark - TableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //モデルの設定
    cell.activity = [_activityList activityAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetWidthWindow = self.tableView.contentOffset.y + self.tableView.bounds.size.height;
    BOOL leachToButtom = contentOffsetWidthWindow >= self.tableView.contentSize.height;
    
    if (!leachToButtom || _activityList.loading || !_activityList.nextQuery){
        return;
    } else {
        [self.indicator startAnimating];
        [_activityList requestMoreAsynchronous];

    }
}
#pragma AvtivityList Delegate
- (void)activityListDidLoad
{
    //indicator stop
    [self.indicator stopAnimating];
    [self.tableView reloadData];
}

#pragma mark BarButton + Badge
- (void)buttonPress
{
    NSLog(@"buttonPress");
    [self.frostedViewController presentMenuViewController];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view
{
    return UIBarPositionBottom;
}


@end
