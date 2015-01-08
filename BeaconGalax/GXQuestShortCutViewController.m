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

@interface GXQuestShortCutViewController ()<UITableViewDataSource,UITableViewDelegate>
- (IBAction)closeAction:(id)sender;
- (IBAction)customButtonPushed:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *shortCutTableView;
@property (weak,nonatomic) GXCreateViewController *createViewController;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property NSArray *shortCutArray;

@end

@implementation GXQuestShortCutViewController

#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.shortCutTableView.delegate = self;
    self.shortCutTableView.dataSource = self;
    
    self.shortCutArray = @[@"a",@"b",@"c"];
    
    //余計なcellを消す
    self.shortCutTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //crateViewをインスタンス化しておく
    self.createViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"createView"];
    
    
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
    //とりえずここでテスト
    [self.view addSubview:self.createViewController.view];
    
}

#pragma mark - Animation
- (void)fadeIn
{
    
}

- (void)fadeOut
{
    
}
@end
