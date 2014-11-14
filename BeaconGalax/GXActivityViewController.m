//
//  GXActivityViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXActivityViewController.h"
#import "GXActivityTableViewCell.h"

#import "GXActivity.h"
#import "GXActivityList.h"

#import "GXBucketManager.h"

@interface GXActivityViewController ()<UITableViewDataSource,UITableViewDelegate,GXActivityListDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) GXActivityList *activityList;

@end

@implementation GXActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _activityList = [[GXActivityList alloc] initWithDelegate:self];
    [_activityList requestAsynchronous];
    
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    あとで
//}

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
    
}

#pragma AvtivityList Delegate
- (void)activityListDidLoad
{
    //indicator stop
    [self.tableView reloadData];
}

@end
