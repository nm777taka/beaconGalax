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

#define PADDING_TOP_BUTTOM 10
#define PADDING_LEFT_RIGHT 10
#define CORNER_RADIUS 2
#define SHADOW_RADIUS 3
#define SHADOW_OPACITY 0.5


@interface GXHomeViewController ()
@property (weak, nonatomic) IBOutlet UITableView *joinedQuestTableView;
@property (weak, nonatomic) IBOutlet UIButton *joinQuestButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) NSMutableArray *scrollerViews;

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
    
    self.view.backgroundColor = [UIColor colorWithRed:0.000 green:0.647 blue:0.865 alpha:1.000];
    
    //ScrollView
    _scrollerViews = [NSMutableArray new];
    UIView *questButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300,100)];
    [questButton setBackgroundColor:[UIColor orangeColor]];
    
    UIView *joinedQuestView  = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,200)];
    joinedQuestView.backgroundColor = [UIColor colorWithRed:0.140 green:1.000 blue:0.529 alpha:1.000];
    
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height)];
    [_scrollView setScrollEnabled:YES];
    _scrollView.backgroundColor = [UIColor whiteColor];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    
    //更新されちゃう.viewの下に追加できるようにする
    [self addView:questButton];
    [self addView:joinedQuestView];
    
    
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

#pragma mark - ScrollViewMethod
- (void)addView:(UIView *)view
{
    UIView *lastView = [_scrollView.subviews lastObject];
    _scrollerViews = [[NSMutableArray alloc] initWithArray:_scrollView.subviews];
    NSLog(@"ScrollViewCount: %d",_scrollView.subviews.count);
    float y = lastView.frame.origin.y + lastView.frame.size.height+PADDING_TOP_BUTTOM;
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

@end
