//
//  GXJoinedQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/22.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXJoinedQuestViewController.h"
#import "UITableViewCell+FlatUI.h"
#import "GXQuestExeViewController.h"
#import "GXBucketManager.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"

static NSString * const FUITableViewControllerCellReuseIdentifier = @"FUITableViewControllerCellReuseIdentifier";


@interface GXJoinedQuestViewController ()<UITableViewDataSource,UITableViewDelegate,FUIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property NSMutableArray *questArray;

@property KiiObject *selectedQuest;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questFetched:) name:GXJoinedQuestFetchedNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self segmentValueChanged];
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

#pragma mark
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KiiObject *obj = self.questArray[indexPath.row];
    NSString *title = [obj getObjectForKey:quest_title];
    NSString *description = [obj getObjectForKey:quest_description];
    self.selectedQuest = self.questArray[indexPath.row];
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
    [alertView show];
    
    
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

#pragma mark - AlertView
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"0"); //キャンセル
            break;
            
        case 1:
            NSLog(@"1"); //スタート
            [self gotoQuestExeView];
            break;
            
        default:
            break;
    }
}

- (void)gotoQuestExeView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"subStoryboard" bundle:nil];
    GXQuestExeViewController *initialViewController = [storyboard instantiateInitialViewController];
    [self presentViewController:initialViewController animated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissed" object:self.selectedQuest];
    }];
}

@end
