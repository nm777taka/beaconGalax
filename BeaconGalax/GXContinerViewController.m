//
//  GXContinerViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXContinerViewController.h"

#import "GXHomeViewController.h"
#import "GXQuestBoardViewController.h"
#import "GXUserProfileViewController.h"
#import "GXFriendsNowViewController.h"
#import "GXFriendsProfileViewController.h"

#import "GXNotification.h"

#define SegueIdentifier_Home @"embedHome"
#define SegueIdentifier_QuestBoard @"embedQuestBoard"
#define SegueIdentifier_FriendsNow @"embedFriendsNow"
#define SegueIdentifier_FriendsProfile @"embedFriendsProfile"
#define SegueIdentifier_UserProfile @"embedUserProfile"

@interface GXContinerViewController ()

@property (nonatomic,strong) NSString *currentSegueIdentifier;
@property (nonatomic,strong) GXHomeViewController *homeViewController;
@property (nonatomic,strong) GXQuestBoardViewController *questBoardViewController;
@property (nonatomic,strong) GXFriendsNowViewController *friendsNowViewController;
@property (nonatomic,strong) GXFriendsProfileViewController *friendsProfileViewController;
@property (nonatomic,strong) GXUserProfileViewController *userProfileViewController;
@property (nonatomic,assign) BOOL transitionInProgress;

@property NSDictionary *segueIdentifierDict;


@end

@implementation GXContinerViewController

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
    NSLog(@"%s",__PRETTY_FUNCTION__);
    self.transitionInProgress = NO;
    self.currentSegueIdentifier = SegueIdentifier_Home;
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
    
    self.segueIdentifierDict = @{@"0": SegueIdentifier_Home,
                                 @"1": SegueIdentifier_QuestBoard,
                                 @"2": SegueIdentifier_FriendsNow,
                                 @"3": SegueIdentifier_FriendsProfile,
                                 @"4": SegueIdentifier_UserProfile
                                 };
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swapViewControllers:) name:GXViewSegueNotification object:nil];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:SegueIdentifier_Home] ) {
        
        self.homeViewController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:SegueIdentifier_QuestBoard]) {
        self.questBoardViewController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:SegueIdentifier_FriendsNow]) {
        _friendsNowViewController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:SegueIdentifier_FriendsProfile]) {
        _friendsProfileViewController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:SegueIdentifier_UserProfile]) {
        _userProfileViewController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:SegueIdentifier_Home]) {
        
        if (self.childViewControllers.count > 0) {
            
            [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.homeViewController];
            
            
        } else {
            
            [self addChildViewController:segue.destinationViewController];
            UIView *desView = ((UIViewController *)segue.destinationViewController).view;
            desView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            desView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:desView];
            [segue.destinationViewController didMoveToParentViewController:self];
        }
    }
    
    //QuestBoarView
    else if ([segue.identifier isEqualToString:SegueIdentifier_QuestBoard]) {
        //swap
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.questBoardViewController];
        
    } else if ([segue.identifier isEqualToString:SegueIdentifier_FriendsNow]) {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.friendsNowViewController];
    } else if ([segue.identifier isEqualToString:SegueIdentifier_FriendsProfile]) {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.friendsProfileViewController];
    } else if ([segue.identifier isEqualToString:SegueIdentifier_UserProfile]) {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:self.userProfileViewController];
    }
    
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [fromViewController willMoveToParentViewController:nil];
    
    [self addChildViewController:toViewController];
    
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:0.1f options:UIViewAnimationOptionTransitionNone
                            animations:nil
                            completion:^(BOOL finished) {
                                
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        self.transitionInProgress = NO;
                                
    }];
}

//NotificationHandler
//SegueNotification
- (void)swapViewControllers:(NSNotification *)info
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    id obj = [info object];
    
    if ([obj isKindOfClass:[NSNumber class]]) {
        self.transitionInProgress = YES;
        int index = [obj intValue];
        
        _currentSegueIdentifier = [_segueIdentifierDict objectForKey:[NSString stringWithFormat:@"%d",index]];
        
        [self performSegueWithIdentifier:_currentSegueIdentifier sender:nil];
    }
    
    
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

@end
