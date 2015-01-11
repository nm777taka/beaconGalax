//
//  GXQuestShortCutViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/08.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import "GXQuestShortCutViewController.h"
#import "GXQuestShortCutTableViewCell.h"
#import "GXCreateViewController.h"
#import "GXPageViewAnalyzer.h"

@interface GXQuestShortCutViewController ()<UITableViewDataSource,UITableViewDelegate,GXQuestShortCutDelegate>
- (IBAction)closeAction:(id)sender;
- (IBAction)customButtonPushed:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *shortCutTableView;
@property (strong,nonatomic) GXCreateViewController *createViewController;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property NSMutableArray *templeteQuests;

@end

@implementation GXQuestShortCutViewController

#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.shortCutTableView.delegate = self;
    self.shortCutTableView.dataSource = self;
    
    //余計なcellを消す
    self.shortCutTableView.tableFooterView = self.footerView;
    
    //crateViewをインスタンス化しておく
    self.createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createView"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchTempleteData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[GXPageViewAnalyzer shareInstance] setPageView:NSStringFromClass([self class])];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDatasouce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.templeteQuests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXQuestShortCutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(GXQuestShortCutTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    KiiObject *obj = self.templeteQuests[indexPath.row];
    cell.shortCutTitle.text = [obj getObjectForKey:@"title"];
    
}

#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.footerView;
}

#pragma mark - IBAction
- (IBAction)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)customButtonPushed:(id)sender
{
    [self showCreatePanel:nil];
    
}

#pragma mark - GXShortCutCellDelegate
- (void)doneCreateButton:(GXQuestShortCutTableViewCell *)cell
{
    NSLog(@"done");
    NSIndexPath *indexPath = [self.shortCutTableView indexPathForCell:cell];
    KiiObject *selectedObj = self.templeteQuests[indexPath.row];
    [self showCreatePanel:selectedObj];
    
}

#pragma mark - Fetch
- (void)fetchTempleteData
{
    KiiBucket *bucket = [Kii bucketWithName:@"templete_quest"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    [bucket executeQuery:query withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
        if (!error) {
            self.templeteQuests = [NSMutableArray arrayWithArray:results];
            [self.shortCutTableView reloadData];
        }
    }];
}

#pragma mark - View Show
- (void)showCreatePanel:(KiiObject *)obj
{
    self.createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createView"];
    self.createViewController.templeteQuest = obj;
    
    [self.view addSubview:self.createViewController.view];
}

@end
