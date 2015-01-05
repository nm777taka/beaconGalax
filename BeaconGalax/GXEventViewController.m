//
//  GXEventViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/06.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import "GXEventViewController.h"
#import "GXEventTableViewCell.h"

#import "GXDictonaryKeys.h"
#import "GXPageViewAnalyzer.h"

@interface GXEventViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *membersArray;
@property (weak, nonatomic) IBOutlet UILabel *eventTItleLabel;
@property (weak, nonatomic) IBOutlet UILabel *questCountLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *questProgressView;

@end

@implementation GXEventViewController

#pragma mark - ViewLifCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.questProgressView configureFlatProgressViewWithTrackColor:[UIColor sunflowerColor] progressColor:[UIColor cloudsColor]];
    self.questProgressView.transform = CGAffineTransformMakeScale(1.0, 4.0);
    self.questProgressView.trackTintColor = [UIColor cloudsColor];
    self.questProgressView.progressTintColor = [UIColor sunflowerColor];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.questProgressView setProgress:0.0];
    [self fetchEventData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.eventTItleLabel.text = [self.eventData getObjectForKey:@"title"];
    int nowClearCount = [[self.eventData getObjectForKey:@"clear_cnt"] intValue];
    NSString *clearCntString= [NSString stringWithFormat:@"残り%dクエスト",100-nowClearCount];
    self.questCountLabel.text = clearCntString;
    
    float progress = (float)nowClearCount / 100;
    
    [self.questProgressView setProgress:progress animated:YES];
    
    [[GXPageViewAnalyzer shareInstance] setPageView:NSStringFromClass([self class])];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DetaSouce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.membersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(GXEventTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *user = self.membersArray[indexPath.row];
    cell.userIconView.profileID = [user getObjectForKey:user_fb_id];
    cell.userNameLabel.text = [user getObjectForKey:user_name];
    
    int event_point = [[user getObjectForKey:@"event_point"] intValue];
    cell.userCleardQuestCountLabel.text = [NSString stringWithFormat:@"イベントpt:%d",event_point];
    
    cell.rankingIndexLabel.text = [NSString stringWithFormat:@"%d位",indexPath.row +1];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (void)fetchEventData
{
    KiiBucket *bucket = [Kii bucketWithName:@"Event"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    //大きい順にsort
    [query sortByDesc:@"event_point"];
    
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            NSMutableArray *resultArray = [NSMutableArray new];
            for (KiiObject *obj in results) {
                
                if ([obj getObjectForKey:@"title"]) {
                    //eventDataなので飛ばす
                    continue;
                }
                
                [resultArray addObject:obj];
            }
            
            self.membersArray = [NSMutableArray arrayWithArray:resultArray];
            [self.tableView reloadData];
        }
    }];
}

@end
