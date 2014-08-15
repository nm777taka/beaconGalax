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
#import "GTScrollViewController.h"
#import "GXHomeTableViewCell.h"
#import "GXHomeTableViewHeader.h"
#import "GXActionViewController.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"


#define PADDING_TOP_BUTTOM 15
#define PADDING_LEFT_RIGHT 10
#define CORNER_RADIUS 2
#define SHADOW_RADIUS 3
#define SHADOW_OPACITY 0.5


@interface GXHomeViewController ()
@property (weak, nonatomic) IBOutlet UITableView *joinedQuestTableView;
@property (weak, nonatomic) IBOutlet UIButton *joinQuestButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) NSMutableArray *scrollerViews;


@property (nonatomic,retain) GXActionViewController *actionViewController;

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
    
    self.joinedQuestList = [NSMutableArray new];
    
    //ActionViewをStoryBoardから取得しておく
    self.actionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActionView"];
    
    
    self.view.backgroundColor = [UIColor colorWithRed:0.000 green:0.647 blue:0.865 alpha:1.000];
    
    //ScrollView
    _scrollerViews = [NSMutableArray new];

    UIButton *questButton = [UIButton buttonWithType:UIButtonTypeCustom];
    questButton.frame = CGRectMake(self.view.center.x - 135, 0, 270, 40);
    [questButton setBackgroundImage:[UIImage imageNamed:@"homeViewQuestJoinButton.png"] forState:UIControlStateNormal];
    questButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UITableView *questTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) style:UITableViewStylePlain];
    questTableView.delegate = self;
    questTableView.dataSource = self;
    //カスタムクラスをアタッチ
    [questTableView registerNib:[UINib nibWithNibName:@"GXHomeTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [questTableView registerNib:[UINib nibWithNibName:@"GXHomeTableViewHeader" bundle:nil] forCellReuseIdentifier:@"sectionHeader"];
    
    questTableView.scrollEnabled = NO;
    
    //アクションビュー呼び出しButton
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionButton.frame = CGRectMake(self.view.center.x - 70/2, self.view.frame.size.height - 200, 70, 70);
    [actionButton setBackgroundImage:[UIImage imageNamed:@"questCreateButton.png"] forState:UIControlStateNormal];
    //questCreateButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [actionButton bk_addEventHandler:^(id sender) {
        [self.view addSubview:self.actionViewController.view];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height)];
    [_scrollView setScrollEnabled:YES];
    _scrollView.backgroundColor = [UIColor colorWithRed:0.195 green:0.935 blue:0.974 alpha:1.000];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    
    [self addButton:questButton];
    [self addTableView:questTableView];

    
    //TableView
    [self.view insertSubview:actionButton atIndex:1];
    
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchQuestHandler:) name:GXQuestFetchedNotification object:nil];
    
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    //fetch
    [self questFetch];
    
}

- (void)questFetch
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    //自分のバケットから
    //参加しているクエストを取得
    if ([KiiUser loggedIn]) {
        
       self.joinedQuestList =  [[GXBucketManager sharedManager] getJoinedQuest];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.joinedQuestList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    GXHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[GXHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = @"test";
    
    [self updateTableSize:tableView];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(GXHomeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    KiiObject *quest = self.joinedQuestList[indexPath.row];
    cell.textLabel.text = [quest getObjectForKey:quest_title];
    
}

- (void)updateTableSize:(UITableView *)tableView
{
    tableView.frame = CGRectMake(tableView.frame.origin.x,
                                 tableView.frame.origin.y,
                                 tableView.contentSize.width,
                                 MIN(tableView.contentSize.height, tableView.bounds.size.height));
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath.row : %u",indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    GXHomeTableViewHeader *headerCell = [tableView dequeueReusableCellWithIdentifier:@"sectionHeader"];;
    return headerCell;
}


- (IBAction)gotoQuestBoard:(id)sender {
}

#pragma mark - ScrollViewMethod
- (void)addView:(UIView *)view
{
    UIView *lastView = [_scrollView.subviews lastObject];
    _scrollerViews = [[NSMutableArray alloc] initWithArray:_scrollView.subviews];
    NSLog(@"ScrollViewCount: %d",_scrollView.subviews.count);
    float y = lastView.frame.origin.y + lastView.frame.size.height+PADDING_TOP_BUTTOM * 1.5;
    if(lastView == nil) {
        y = 20;
    }
    
    CGRect frame = view.frame;
    frame.origin.y = y;
    frame.origin.x = PADDING_LEFT_RIGHT;
    view.frame = frame;
    
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = CORNER_RADIUS;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowRadius = SHADOW_RADIUS;
    view.layer.shadowOpacity = SHADOW_OPACITY;
    
    //viewサイズがscrollViewのサイズを超えてたら
    //scrollViewのサイズを更新する
    if((view.frame.origin.y + view.frame.size.height) >= _scrollView.frame.size.height) {
        
        //new height
        float newHeight = view.frame.origin.y + view.frame.size.height + PADDING_TOP_BUTTOM;
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, newHeight)];
        
    }
    
    [_scrollView addSubview:view];

    
}
- (void)addTableView:(UITableView *)view
{
    UIView *lastView = [_scrollView.subviews lastObject];
    _scrollerViews = [[NSMutableArray alloc] initWithArray:_scrollView.subviews];
    NSLog(@"ScrollViewCount: %d",_scrollView.subviews.count);
    float y = lastView.frame.origin.y + lastView.frame.size.height+PADDING_TOP_BUTTOM * 1.5;
    if(lastView == nil) {
        y = 10;
    }
    
    CGRect frame = view.frame;
    frame.origin.y = y;
    frame.origin.x = PADDING_LEFT_RIGHT;
    view.frame = frame;
    
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = CORNER_RADIUS;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowRadius = SHADOW_RADIUS;
    view.layer.shadowOpacity = SHADOW_OPACITY;
    
    //viewサイズがscrollViewのサイズを超えてたら
    //scrollViewのサイズを更新する
    if((view.frame.origin.y + view.frame.size.height) >= _scrollView.frame.size.height) {
        
        //new height
        float newHeight = view.frame.origin.y + view.frame.size.height + PADDING_TOP_BUTTOM;
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, newHeight)];
        
    }
    
    [_scrollView addSubview:view];
}

- (void)addButton:(UIButton *)button
{
    UIView *lastView = [_scrollView.subviews lastObject];
    _scrollerViews = [[NSMutableArray alloc] initWithArray:_scrollView.subviews];
    float y = lastView.frame.origin.y + lastView.frame.size.height + PADDING_TOP_BUTTOM;
    if (lastView == nil) {
        y = 10;
    }
    
    CGRect frame = button.frame;
    
    //x座標はbuttonのもっているframeに合わせる
    frame.origin.y = y;
    button.frame = frame;
    
    if((button.frame.origin.y + button.frame.size.height) >= _scrollView.frame.size.height) {
        
        //new height
        float newHeight = button.frame.origin.y + button.frame.size.height + PADDING_TOP_BUTTOM;
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, newHeight)];
    }
    
    [_scrollView addSubview:button];
}

#pragma  mark - ノーティフィケーション
- (void)fetchQuestHandler:(NSNotification *)info
{
    NSLog(@"フェッチ完了");
    NSLog(@"%d",self.joinedQuestList.count);
    KiiObject *obj = self.joinedQuestList[0];
    NSLog(@"%@",[obj getObjectForKey:quest_title]);
    [self.joinedQuestTableView reloadData];
}

@end
