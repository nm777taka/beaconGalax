//
//  GXHomeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXHomeViewController.h"
#import "NSMutableArray+Extended.h"
#import "GXNotification.h"
#import "GXQuestBoardViewController.h"


@interface GXHomeViewController ()
@property (weak, nonatomic) IBOutlet UITableView *joinedQuestTableView;
@property (weak, nonatomic) IBOutlet UIButton *joinQuestButton;
- (IBAction)gotoQuestBoard:(id)sender;


@property NSMutableArray *joinedQuestList;


@end

@implementation GXHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.joinedQuestTableView.delegate = self;
    self.joinedQuestTableView.dataSource = self;
    
    NSMutableArray *subItems;
    self.joinedQuestList = [NSMutableArray array];
    subItems = [NSMutableArray array];
    subItems = [@[@"テスト1"] mutableCopy];
    subItems.extended = YES;
    [self.joinedQuestList addObject:subItems];
    
    subItems = [NSMutableArray array];
    subItems.extended = YES;
    [subItems addObject:@"テスト2"];
    [subItems addObject:@"テスト3"];
    [self.joinedQuestList addObject:subItems];
    
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

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.joinedQuestList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSMutableArray *)self.joinedQuestList[(NSInteger)section]).extended ? [self.joinedQuestList[(NSInteger)section] count]+1 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ParentCellIdentifier = @"ParentCell";
    static NSString *ChildCellIdentifier = @"ChildCell";
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSMutableArray *subItems;
    subItems = self.joinedQuestList[section];
    
    UITableViewCell *cell;
    
    NSString *identifier;
    
    if (row == 0) {
        identifier = ParentCellIdentifier;
    } else {
        identifier = ChildCellIdentifier;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *strText;
    if (row == 0) {
        strText = [NSString stringWithFormat:@"==== section [%d] ===",indexPath.section];
    } else {
        strText = [NSString stringWithFormat:@"row (%d) ==== ",indexPath.row];
    }
    
    //Configure
    cell.textLabel.text = strText;
    
    return cell;
}

#pragma mark UItableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSMutableArray *subItems;
    subItems = self.joinedQuestList[section];
    
    if (row == 0) {
        subItems.extended = !subItems.extended;
        
        if (subItems.extended == NO) {
            //animation
            [self collapseSubItemAtIndex:row+1 maxRow:[subItems count]+1 section:section];
        } else {
            //animation
            [self expandItemAtIndex:row+1 maxRow:[subItems count]+1 section:section];
        }
    }
}

#pragma mark TableViewAnimation
//縮小
- (void)collapseSubItemAtIndex:(int)firstRow maxRow:(int)maxRow section:(int)section
{
    NSMutableArray *indexPaths = [NSMutableArray new];
    
    for (int i=firstRow; i<maxRow; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    [self.joinedQuestTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

//拡張
- (void)expandItemAtIndex:(int)firstRow maxRow:(int)maxRow section:(int)section
{
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int i=firstRow; i<maxRow; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.joinedQuestTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.joinedQuestTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:firstRow inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}


- (IBAction)gotoQuestBoard:(id)sender {
}


@end
