//
//  GXQuestBoardViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestBoardViewController.h"
#import "GXQuestTableCell.h"
#import "GXTableViewConst.h"

@interface GXQuestBoardViewController ()

@property NSMutableArray *questArray;

@end

@implementation GXQuestBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - ViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.questTable.delegate = self;
    self.questTable.dataSource = self;
    
    self.questArray = [NSMutableArray new];
    
    //カスタムCellを登録
    UINib *nib = [UINib nibWithNibName:QuestTableViewCellIdentifier bundle:nil];
    [self.questTable registerNib:nib forCellReuseIdentifier:@"cell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //テーブルデータソース配列フェッチ処理
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXQuestTableCell *cell = [self.questTable dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[GXQuestTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

#pragma mark -TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (void)configureCell:(GXQuestTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    //バケットからフェッチしたobjectの各要素
    cell.questTitleLable.text = @"test";
    cell.questDescriptionLabel.text = @"description";
    
    
}

@end
