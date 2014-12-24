//
//  GXHomeRootViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXHomeRootViewController.h"
#import "GXAppDelegate.h"
#import "UIBarButtonItem+Badge.h"
#import <REFrostedViewController.h>
#import <DZNSegmentedControl.h>
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXUserDefaults.h"
#import "GXTopicManager.h"
#import "GXDictonaryKeys.h"
#import "NSObject+BlocksWait.h"

@interface GXHomeRootViewController ()<DZNSegmentedControlDelegate>

@property UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) DZNSegmentedControl *control;
@end

@implementation GXHomeRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    NSArray *items = @[@"New", @"受注済み", @"募集中"];
    _control = [[DZNSegmentedControl alloc] initWithItems:items];
    _control.tintColor = [UIColor blueColor];
    
    _control.delegate = self;
    _control.selectedSegmentIndex = 0;
    [_control addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    _control.frame = CGRectMake(0, 65, self.view.frame.size.width, 63);
    _control.height = 63;
    [self.view addSubview:_control];
    
    if ([KiiUser loggedIn]) {
        [self showNotJoinView];
    }
    
    self.title = @"クエスト一覧";
    
    UIImage *image = [UIImage imageNamed:@"someImage"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [button addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = navLeftButton;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateControl:) name:GXBucketObjectCountNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessed:) name:GXLoginSuccessedNotification object:nil];
    
    //[self countBucketObj];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([KiiUser loggedIn]) {
        [self countBucketObj];
    } else {
        //ログイン処理
        [SVProgressHUD showWithStatus:@"ログイン中"];
        [NSObject performBlock:^{
            [[GXKiiCloud sharedManager] kiiCloudLogin];
        } afterDelay:5.0f];
    }
}

- (void)countBucketObj
{
    [[GXBucketManager sharedManager] countNotJoinBucket];
    [[GXBucketManager sharedManager] countJoinedBucket];
    [[GXBucketManager sharedManager] countInviteBucket];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index
{
    UIViewController *vc;
    
    switch (index) {
        case 0:
            //vc取得
            vc  = [self.storyboard instantiateViewControllerWithIdentifier:@"notJoin"];
            break;
            
        case 1:
            vc  = [self.storyboard instantiateViewControllerWithIdentifier:@"joined"];
            break;
            
        case 2:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"invite"];
            break;
            
        default:
            break;
    }
    
    return vc;
}


- (void)selectedSegment:(DZNSegmentedControl *)sender {
    
    UIViewController *vc = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    [self addChildViewController:vc];
    //ビューの変更
    [self transitionFromViewController:self.currentViewController toViewController:vc duration:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.currentViewController.view removeFromSuperview];
        vc.view.frame = self.contentView.bounds;
        [self.contentView addSubview:vc.view];
    } completion:^(BOOL finished){
        [vc didMoveToParentViewController:self];
        [self.currentViewController removeFromParentViewController];
        self.currentViewController = vc;
    }];

    
}

#pragma mark - Notification
- (void)updateControl:(NSNotification *)notis
{
    NSDictionary *dict = notis.object;
    NSNumber *dataNum = dict[@"count"];
    NSNumber *index = dict[@"index"];
    switch ([index integerValue]) {
        case 0:
            [self.control setCount:dataNum forSegmentAtIndex:0];
            break;
            
        case 1:
            [self.control setCount:dataNum forSegmentAtIndex:1];
            break;
        
        case 2:
            [self.control setCount:dataNum forSegmentAtIndex:2];
            break;
        default:
            break;
    }
    
}

- (void)loginSuccessed:(NSNotification *)notis
{
    [SVProgressHUD showSuccessWithStatus:@"ログイン完了"];
    
    [self showNotJoinView];
    
}

#pragma mark - 最初のクエスト
- (void)createFirstQuest
{
    NSError *error;
    KiiBucket *bucket = [GXBucketManager sharedManager].notJoinedQuest;
    //一人用
    KiiObject *newQuest1 = [bucket createObject];
    [newQuest1 setObject:@"最初のクエスト" forKey:@"title"];
    [newQuest1 setObject:@"研究室のビーコンに近づいてみよう" forKey:@"description"];
    [newQuest1 setObject:@"クリア条件:研究室のビーコンに一定時間近づく" forKey:@"requirement"];
    [newQuest1 setObject:@28319 forKey:@"major"];
    [newQuest1 setObject:@1 forKey:@"player_num"];
    [newQuest1 setObject:@NO forKey:@"isCompleted"];
    [newQuest1 setObject:@0 forKey:@"success_cnt"];
    [newQuest1 saveSynchronous:&error];
    if (error) NSLog(@"init quest error:%@",error);
    else NSLog(@"newQuest1 suc");
    
    //協力クエスト
    KiiObject *newQuest2 = [bucket createObject];
    [newQuest2 setObject:@"はじめての協力" forKey:@"title"];
    [newQuest2 setObject:@"メンバーと一緒にクエストをやってみよう" forKey:@"description"];
    [newQuest2 setObject:@"クリア条件：研究室のビーコンに一定時間近づく" forKey:@"requirement"];
    [newQuest2 setObject:@28319 forKey:@"major"];
    [newQuest2 setObject:@2 forKey:@"player_num"];
    [newQuest2 setObject:@NO forKey:@"isCompleted"];
    [newQuest2 setObject:@0 forKey:@"success_cnt"];
    [newQuest2 saveSynchronous:&error];
    if (error) NSLog(@"init quest error:%@",error);
    else NSLog(@"newQuest1 suc");
}

#pragma mark BarButton + Badge
- (void)buttonPress
{
    NSLog(@"buttonPress");
    [self.frostedViewController presentMenuViewController];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view
{
    return UIBarPositionBottom;
}

- (void)showNotJoinView
{
    UIViewController *vc = [self viewControllerForSegmentIndex:0];
    [self addChildViewController:vc];
    vc.view.frame = self.contentView.bounds;
    
    [self.contentView addSubview:vc.view];
    self.currentViewController = vc;

}
@end
