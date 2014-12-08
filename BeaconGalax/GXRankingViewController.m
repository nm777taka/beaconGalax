//
//  GXRankingViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/07.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXRankingViewController.h"
#import "GXRankingTableViewCell.h"

#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"

@interface GXRankingViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *dataSouce;

@end

@implementation GXRankingViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUserData];
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

#pragma mark - UITableViewDataSouce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSouce.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXRankingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)configureCell:(GXRankingTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *user = self.dataSouce[indexPath.row];
    cell.userIcon.profileID = [user getObjectForKey:user_fb_id];
    cell.userName.text = [user getObjectForKey:user_name];
    int point = [[user getObjectForKey:@"point"] intValue];
    cell.userPoint.text = [NSString stringWithFormat:@"%d",point];
    cell.userRank.text = [NSString stringWithFormat:@"%@ランク",[user getObjectForKey:@"rank"]];
    cell.rankIndex.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
    cell.rankIndex.textColor = [UIColor grayColor];
}

#pragma mark - TalbleView delegata
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

#pragma mark 通信
- (void)getUserData
{
    KiiBucket *users = [GXBucketManager sharedManager].galaxUser;
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [query sortByDesc:@"point"]; //ポイントの大きい順に取得
    [users executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
           //tableViweのDataSouceを更新
            self.dataSouce = [NSMutableArray arrayWithArray:results];
            [self.tableView reloadData];
        }
    }];
}


@end
