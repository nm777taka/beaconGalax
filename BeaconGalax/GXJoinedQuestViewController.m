//
//  GXJoinedQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/20.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXJoinedQuestViewController.h"
#import "GXJoinedQuestTableViewCell.h"
#import "GXQuestExeViewController.h"
#import "GXQuestB1ViewController.h"
#import "GXFooterCell.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"

@interface GXJoinedQuestViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property GXJoinedQuestTableViewCell *stubCell;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segumentedControl;
@property (nonatomic,retain) NSMutableArray *joinedQuestArray;
@property (nonatomic,retain) KiiObject *selectedQuest;



@end

@implementation GXJoinedQuestViewController{
    UIRefreshControl *_refreshControl;
    UIAlertController *_type1Alert;
}

#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _stubCell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    _type1Alert = [UIAlertController alertControllerWithTitle:@"ビーコンクエスト" message:@"クエストを開始しますか？" preferredStyle:UIAlertControllerStyleAlert];
    [_type1Alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //start
        [self startQuest];
    }]];
    
    [_type1Alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil]];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueNotisHandler:) name:GXSegueToQuestExeViewNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;

    
    switch (self.segumentedControl.selectedSegmentIndex) {
        case 0:
            [self fetchParticipantQuest];
            break;
            
        case 1:
            [self fetchOwnerQuest];
            break;
            
        default:
            break;
    }
    
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedQuest = self.joinedQuestArray[indexPath.row];
    NSNumber *type = [self.selectedQuest getObjectForKey:quest_type];
    int type_int = [type intValue];
    NSLog(@"selected_type:%d",type_int);
    
    switch (type_int) {
        case 1: // type_beacon_1
            //alertshow
            [self presentViewController:_type1Alert animated:YES completion:nil];
            break;
            
        case 2: // type_beacon_2
            //
            break;
            
        default:
            break;
    }
    

}


//cellの高さを可変に
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:_stubCell atIndexPath:indexPath];
    [_stubCell layoutSubviews];
    CGFloat height = [_stubCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height + 1;
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

- (void)segueNotisHandler:(NSNotification *)notis
{
    GXJoinedQuestTableViewCell *cell = notis.object;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.selectedQuest = self.joinedQuestArray[indexPath.row];
    
//    //クエスト作成者 or 受注者で画面をかえる
//    NSString *currentUserURI = [KiiUser currentUser].objectURI;
//    NSString *questOwnerURI = [self.selectedQuest getObjectForKey:quest_createUserURI];
//    NSString *userFBID= [self.selectedQuest getObjectForKey:quest_createdUser_fbid];
//    
//    if ([currentUserURI isEqualToString:questOwnerURI]) {
//        //クエスト作成者 = クエスト実行viewへ
//        [self performSegueWithIdentifier:@"goto_questExe" sender:self];
//
//    } else {
//        //クエスト参加者
//        [self performSegueWithIdentifier:@"goto_questPrepare" sender:self];
//    }
    
}

#pragma mark segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goto_questExe"]) {
        
        //クエスト実行ビューに選択されたクエストを渡す
        GXQuestExeViewController *vc = segue.destinationViewController;
        vc.exeQuest = self.selectedQuest;
    }
    
    if ([segue.identifier isEqualToString:@"type_1"]) {
        GXQuestB1ViewController *vc = segue.destinationViewController;
        vc.exeQuest = self.selectedQuest;
    }
}

- (IBAction)goBack:(UIStoryboardSegue *)sender
{
    
}

- (IBAction)indexChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.title = @"参加中";
            [self fetchParticipantQuest];
            break;
            
        case 1:
            
            self.title = @"発行中";
            [self fetchOwnerQuest];
            
        default:
            break;
    }
}

#pragma mark - fetch
- (void)fetchOwnerQuest
{
    [[GXBucketManager sharedManager] getOwnerQuest];
}

- (void)fetchParticipantQuest
{
    //自分が参加しているクエストをフェッチ
    [[GXBucketManager sharedManager] getJoinedQuest];

}

#pragma mark - refresh handler
- (void)refresh
{
    NSLog(@"refresh");
    
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh
{
    [_refreshControl endRefreshing];
}

- (void)startQuest
{
    [self performSegueWithIdentifier:@"type_1" sender:self];

}
@end