//
//  GXQuestShortCutViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/08.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import "GXQuestShortCutViewController.h"
#import "GXQuestShortCutTableViewCell.h"

@interface GXQuestShortCutViewController ()<UITableViewDataSource,UITableViewDelegate>
- (IBAction)closeAction:(id)sender;
- (IBAction)customButtonPushed:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *shortCutTableView;

@property NSArray *shortCutArray;

@end

@implementation GXQuestShortCutViewController

#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.shortCutTableView.delegate = self;
    self.shortCutTableView.dataSource = self;
    
    self.shortCutArray = @[@"a",@"b",@"c",@"もっとカスタム"];
    
    //余計なcellを消す
    self.shortCutTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
    return self.shortCutArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXQuestShortCutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(GXQuestShortCutTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.shortCutTitle.text = self.shortCutArray[indexPath.row];
    
}

#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark - IBAction
- (IBAction)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)customButtonPushed:(id)sender
{
    
}
@end
