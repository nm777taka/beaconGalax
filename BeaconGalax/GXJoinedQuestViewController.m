//
//  GXJoinedQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/22.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXJoinedQuestViewController.h"
#import "GXInviteQuestViewController.h"
#import "GXQuestGroupViewController.h"
#import "UITableViewCell+FlatUI.h"
#import "GXQuestExeViewController.h"
#import "GXNavViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "REFrostedViewController.h"
#import "GXBucketManager.h"
#import "GXExeQuestManager.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"

static NSString * const FUITableViewControllerCellReuseIdentifier = @"FUITableViewControllerCellReuseIdentifier";


@interface GXJoinedQuestViewController ()<UITableViewDataSource,UITableViewDelegate,FUIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property NSMutableArray *questArray;

@property KiiObject *selectedQuest;
@property KiiGroup *selectedGroup;

@end

@implementation GXJoinedQuestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.separatorColor = [UIColor cloudsColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:FUITableViewControllerCellReuseIdentifier];
    
    self.segmentControl.selectedSegmentIndex = 0; //defult
    [self.segmentControl addTarget:self action:@selector(segmentValueChanged) forControlEvents:UIControlEventValueChanged];
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questFetched:) name:GXJoinedQuestFetchedNotification object:nil];
    
    [self segmentValueChanged];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedQuest = self.questArray[indexPath.row];
    NSString *title = [self.selectedQuest getObjectForKey:quest_title];
    NSString *description = [self.selectedQuest getObjectForKey:quest_description];
    if ([[self.selectedQuest getObjectForKey:quest_player_num] intValue] > 1) {
        //協力型
        FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:title
                                                              message:description
                                                             delegate:nil cancelButtonTitle:@"Dismiss"
                                                    otherButtonTitles:@"募集画面へ", nil];
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        alertView.messageLabel.textColor = [UIColor cloudsColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:14];
        alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
        alertView.defaultButtonColor = [UIColor cloudsColor];
        alertView.defaultButtonShadowColor = [UIColor asbestosColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor asbestosColor];
        alertView.delegate = self;
        alertView.tag = 1;
        [alertView show];

    } else {
        
        FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:title
                                                              message:description
                                                             delegate:nil cancelButtonTitle:@"Dismiss"
                                                    otherButtonTitles:@"Start", nil];
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        alertView.messageLabel.textColor = [UIColor cloudsColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:14];
        alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
        alertView.defaultButtonColor = [UIColor cloudsColor];
        alertView.defaultButtonShadowColor = [UIColor asbestosColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor asbestosColor];
        alertView.delegate = self;
        alertView.tag = 0;
        [alertView show];

    }
    
    
}


#pragma mark - UITableViewDataSouce

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.questArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FUITableViewControllerCellReuseIdentifier forIndexPath:indexPath];
    
    UIRectCorner corner = UIRectCornerAllCorners;
    //cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor cloudsColor];
    cell.textLabel.font = [UIFont boldFlatFontOfSize:16];
    
    [cell configureFlatCellWithColor:[UIColor greenSeaColor]
                       selectedColor:[UIColor cloudsColor]
                     roundingCorners:corner];
    
    //cell.cornerRadius = 5.0f; // optional
    cell.separatorHeight = 2.f; // optional

    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *quest = self.questArray[indexPath.row];
    cell.textLabel.text = [quest getObjectForKey:quest_title];
}

#pragma mark - セグメントコントロール
- (void)segmentValueChanged
{
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            //一人用フェッチ
            [[GXBucketManager sharedManager] getJoinedOnePersonQuest];
            break;
        
        case 1:
            //協力型フェッチ
            [[GXBucketManager sharedManager] getJoinedMultiPersonQuest];
            break;
            
        default:
            break;
    }
}

#pragma mark - Notification

- (void)questFetched:(NSNotification *)notis
{
    NSArray *array = notis.object;
    KiiObject *obj = array.firstObject;
    self.questArray = [NSMutableArray arrayWithArray:array];
    [self.tableView reloadData];
}

#pragma mark - AlertView(各Viewへの遷移)
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0://ひとり
            if (buttonIndex == 1) { //開始
                
                [self startOneQuestSequence];
            }
            break;
            
        case 1: //協力
            if (buttonIndex == 1) {
                [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:^(NSTimer *timer) {
                    [self gotoPartyView];
                } repeats:NO];
            }
            
        default:
            break;
    }
    
}

- (void)startOneQuestSequence
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"subStoryboard" bundle:nil];
    GXQuestExeViewController *initialViewController = [storyboard instantiateInitialViewController];
    initialViewController.exeQuest = self.selectedQuest;
    [self presentViewController:initialViewController animated:YES completion:^{
        //QMで管理
        [GXExeQuestManager sharedManager].nowExeQuest = self.selectedQuest;
    }];
}

- (void)gotoPartyView
{
    NSError *error;
    KiiGroup *group = [KiiGroup groupWithURI:[self.selectedQuest getObjectForKey:quest_groupURI]];
    [group refreshSynchronous:&error];
    if (error) {
        NSLog(@"error:%@",error);
    } else {
        self.selectedGroup = group;
        [self performSegueWithIdentifier:@"gotoReadyView" sender:self];

    }

}
- (void)gotoInviteView
{
    GXNavViewController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    GXInviteQuestViewController *invitedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"invite"];
    navController.viewControllers = @[invitedVC];
    self.frostedViewController.contentViewController = navController;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoReadyView"]) {
        GXQuestGroupViewController *vc = segue.destinationViewController;
        vc.willExeQuest = self.selectedQuest;
        vc.selectedQuestGroup = self.selectedGroup;
    }
}

@end
