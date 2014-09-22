//
//  GXJoinedQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/20.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXJoinedQuestViewController.h"
#import "GXJoinedQuestTableViewCell.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"

@interface GXJoinedQuestViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GXJoinedQuestTableViewCell *stabCell;

@property (nonatomic,retain) NSMutableArray *joinedQuestArray;
@end

@implementation GXJoinedQuestViewController

#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchedHandler:) name:GXJoindQuestFetchedNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetch];
}

- (void)fetch
{
    //自分が参加しているクエストをフェッチ
    self.joinedQuestArray = [[GXBucketManager sharedManager] getJoinedQuest];
    [self.tableView reloadData];

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

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.joinedQuestArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    GXJoinedQuestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GXJoinedQuestTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *obj = self.joinedQuestArray[indexPath.row];
    
    cell.mainLabel.text = [obj getObjectForKey:quest_title];
    cell.nameLabel.text = [obj getObjectForKey:quest_createdUserName];
    cell.userIconView.profileID = [obj getObjectForKey:quest_createdUser_fbid];
    
    NSDate *date = obj.created;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    NSString *dateText = [formatter stringFromDate:date];
    
    cell.subLabel.text = dateText;
    
}

#pragma mark - NotificationHandler

- (void)fetchedHandler:(NSNotification *)notis
{
    
}

@end