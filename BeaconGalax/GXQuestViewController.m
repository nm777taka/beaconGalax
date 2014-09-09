//
//  GXQuestViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/08.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestViewController.h"
#import "GXHomeTableViewCell.h"
#import "GXDescriptionViewController.h"
#import "GXBucketManager.h"
#import "GXNotification.h"
#import "GXDictonaryKeys.h"

@interface GXQuestViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)createNewQuest:(id)sender;
@property GXHomeTableViewCell *stubCell;
@property GXDescriptionViewController *descriptionViewContoller;
@property NSArray *textArray;
@property NSMutableArray *objects;
@property KiiObject *selectedObject;
@end

@implementation GXQuestViewController

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
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //セパレータを左端まで伸ばす
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    _objects = [NSMutableArray new];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    
    _stubCell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    _descriptionViewContoller = [[self storyboard] instantiateViewControllerWithIdentifier:@"DescriptionView"];
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questFetched:) name:GXFetchQuestNotComplitedNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![KiiUser loggedIn]) {
        
        //ログイン画面へ遷移
        [self performSegueWithIdentifier:@"gotoLoginView" sender:self];
    } else {
        //DBからフェッチ(非同期)
        //最終的に変更があった場合のみにしたい
        _objects = [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GXHomeTableViewCell *customCell = (GXHomeTableViewCell *)cell;
    KiiObject *object = _objects[indexPath.row];
    
    // メインラベルに文字列を設定
    customCell.mainLabel.text = [object getObjectForKey:quest_title];
    // サブラベルに文字列を設定
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy年MM月dd日 HH時mm分ss秒";
    NSString *dateText = [dateFormatter stringFromDate:object.created];
    customCell.subLabel.text = dateText;
    
    customCell.nameLabel.text = [object getObjectForKey:quest_createdUserName];
    
    //アイコンを更新
    customCell.fbUserIcon.profileID = [object getObjectForKey:quest_createdUser_fbid];
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 計測用のプロパティ"_stubCell"を使って高さを計算する
    [self configureCell:_stubCell atIndexPath:indexPath];
    [_stubCell layoutSubviews];
    CGFloat height = [_stubCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height + 1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];    // 追加
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedObject = _objects[indexPath.row];
    [self performSegueWithIdentifier:@"gotoDescriptionView" sender:self];
}

#pragma mark Notification
- (void)questFetched:(NSNotification *)info
{
    NSLog(@"objects.cout : %d",_objects.count);
    [self.tableView reloadData];

}


#pragma mark Button_Action
- (IBAction)createNewQuest:(id)sender
{
    //segue
}

#pragma mark segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"gotoDescriptionView"]) {
        GXDescriptionViewController *vc = segue.destinationViewController;
        vc.object = _selectedObject;
    }
}
@end
