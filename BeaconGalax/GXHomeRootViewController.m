//
//  GXHomeRootViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXHomeRootViewController.h"
#import "UIBarButtonItem+Badge.h"
#import <REFrostedViewController.h>
#import <DZNSegmentedControl.h>
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXUserDefaults.h"

#import "GXGoogleTrackingManager.h"

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
    
    UIViewController *vc = [self viewControllerForSegmentIndex:0];
    [self addChildViewController:vc];
    vc.view.frame = self.contentView.bounds;
    
    [self.contentView addSubview:vc.view];
    self.currentViewController = vc;
    
    self.title = @"クエスト一覧";
    
    UIImage *image = [UIImage imageNamed:@"someImage"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [button addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = navLeftButton;
    
    //バッジの初期化
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateControl:) name:GXBucketObjectCountNotification object:nil];
    
    [self countBucketObj];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
@end
