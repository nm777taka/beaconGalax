//
//  GXOnlineMemberTableViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/19.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXOnlineMemberTableViewController.h"
#import "GXBucketManager.h"

@interface GXOnlineMemberTableViewController ()

@property (nonatomic,strong) NSMutableArray *onlineUsers;
@property (nonatomic,strong) NSMutableArray *selectedUsersIndex;

- (IBAction)closeAction:(id)sender;
- (IBAction)doneAction:(id)sender;

@end

@implementation GXOnlineMemberTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.selectedUsersIndex = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD showWithStatus:@"メンバー取得中"];
    [self getOnlineGXUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.onlineUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *obj = self.onlineUsers[indexPath.row];
    if ([[obj getObjectForKey:@"isSelected"] boolValue]) {
        cell.imageView.image = [UIImage imageNamed:@"green.png"];
    } else {
        cell.imageView.image = nil;
    }
    cell.textLabel.text = [obj getObjectForKey:@"name"];
    cell.detailTextLabel.text = [obj getObjectForKey:@"location"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //クリア対象のbeaconを設定する場合
    if (self.index == 0) {
        KiiObject *selectedObj = self.onlineUsers[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"beaconSet" object:selectedObj];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
 
    KiiObject *selected = self.onlineUsers[indexPath.row];
    if ([[selected getObjectForKey:@"isSelected"] boolValue]) {
        //選択されてたら
        [selected setObject:@NO forKey:@"isSelected"];
    } else {
        [selected setObject:@YES forKey:@"isSelected"];
    }
    
    [self.tableView reloadData];
    
//    //だれに配信するか設定（複数人対応)
//    NSString *indexString = [NSString stringWithFormat:@"%ld",indexPath.row];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    //すでに選択しているか調べる
//    NSUInteger index = [self.selectedUsersIndex indexOfObject:indexString];
//    
//    if (index != NSNotFound) {
//        //チェックマークを削除
//        cell.imageView.image = nil;
//        //データ削除
//        [self.selectedUsersIndex removeObject:indexString];
//        NSLog(@"%@",self.selectedUsersIndex);
//    } else {
//        //新規
//        NSLog(@"新規");
//        [self.selectedUsersIndex addObject:indexString];
//        cell.imageView.image = [UIImage imageNamed:@"green.png"];
//        NSLog(@"selecteduser:%@",self.selectedUsersIndex);
//    }
//    
//    //[self configureCell:cell atIndexPath:indexPath];
//    [self.tableView reloadData];
//    switch (self.index) {
//        case 0:
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"beaconSet" object:selectedObj];
//            break;
//        case 1:
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"targetUserSet" object:selectedObj];
//            break;
//            
//        default:
//            break;
//    }
//    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma fetch
- (void)getOnlineGXUser
{
    KiiBucket *bucket = [GXBucketManager sharedManager].galaxUser;
    //KiiClause *clause = [KiiClause equals:@"isOnline" value:@YES];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            self.onlineUsers = [NSMutableArray arrayWithArray:results];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        }
    }];
}


- (IBAction)closeAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"targetUserSet" object:nil]; //nilを返す
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneAction:(id)sender {
    //選択したindexから実際のuserを取得
    
    NSMutableArray *array = [NSMutableArray new];
    for (KiiObject *userObj in self.onlineUsers) {
        BOOL isSelected = [[userObj getObjectForKey:@"isSelected"] boolValue];
        if (isSelected) {
            [array addObject:userObj];
        }
    }
    
    //なにも選択してなかったら
    if (array.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"targetUserSet" object:nil]; //nilを返す

    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"targetUserSet" object:array];

    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
