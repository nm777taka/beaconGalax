//
//  GXGalaxterStatusViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXGalaxterStatusViewController.h"
#import "GXGalaxterStatusViewCell.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"

@interface GXGalaxterStatusViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *users;
@end

@implementation GXGalaxterStatusViewController{
    UIRefreshControl *_refreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"みんなの状況";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.users = [NSMutableArray new];
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[GXPageViewAnalyzer shareInstance] setPageView:NSStringFromClass([self class])];
    [self fetchGalaxUsers];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXGalaxterStatusViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GXGalaxterStatusViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *obj = self.users[indexPath.row];
    cell.nameLabel.text = [obj getObjectForKey:@"name"];
    cell.locationLabel.text = [obj getObjectForKey:@"location"];
    cell.userIconView.profileID = [obj getObjectForKey:user_fb_id];
}

- (void)fetchGalaxUsers
{
    KiiBucket *bucket = [GXBucketManager sharedManager].galaxUser;
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            NSLog(@"fetch-更新");
            self.users = [NSMutableArray arrayWithArray:results];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark RefreshControl
- (void)refresh
{
    [self fetchGalaxUsers];
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}
@end
