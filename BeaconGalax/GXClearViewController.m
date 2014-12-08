//
//  GXClearViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/10.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXClearViewController.h"
#import "GXBucketManager.h"
#import "GXActivityList.h"
#import "GXUserManager.h"
#import "GXExeQuestManager.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"
#import "GXQuestViewController.h"
#import "GXInviteQuestViewController.h"
#import "GXFrostedViewController.h"
#import "GXPointManager.h"
#import "GXGoogleTrackingManager.h"

#import "GXAnimationLabel.h"
#import "NSObject+BlocksWait.h"
#import "FUIAlertView+GXTheme.h"

@interface GXClearViewController ()<FUIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UILabel *headerSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *pointSubLabel;
@property (weak, nonatomic) IBOutlet GXAnimationLabel *pointLable;
@property (weak, nonatomic) IBOutlet UILabel *currentPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextRankSubLabel;
@property (weak, nonatomic) IBOutlet FUIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIProgressView *rankProgressView;
@property NSDictionary *rankDict;
@property float gotQuestPoint;
@property float userPoint;
@property float nextPoint;
@property float nowProgress;
@property NSString *nextRank;
- (IBAction)gotoHome:(id)sender;

@end

@implementation GXClearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pointLable.font = [UIFont boldFlatFontOfSize:80.0];
    self.currentPointLabel.font = [UIFont boldFlatFontOfSize:17];
    self.headerTitle.font = [UIFont boldFlatFontOfSize:30.0];
    self.headerSubTitle.font = [UIFont boldFlatFontOfSize:17];
    self.pointSubLabel.font = [UIFont boldFlatFontOfSize:17];
    self.nextRankSubLabel.font = [UIFont boldFlatFontOfSize:17];
    
    self.homeButton.buttonColor = [UIColor turquoiseColor];
    self.homeButton.shadowColor = [UIColor greenSeaColor];
    self.homeButton.shadowHeight = 3.0f;
    self.homeButton.cornerRadius = 6.0f;
    self.homeButton.titleLabel.font = [UIFont boldFlatFontOfSize:15];
    
    [self.rankProgressView configureFlatProgressViewWithTrackColor:[UIColor sunflowerColor] progressColor:[UIColor cloudsColor]];
    self.rankProgressView.transform = CGAffineTransformMakeScale(1.0, 4.0);
    self.rankProgressView.trackTintColor = [UIColor cloudsColor];
    self.rankProgressView.progressTintColor = [UIColor sunflowerColor];
    self.pointLable.text = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
    NSDictionary *dict = [[GXPointManager sharedInstance] checkNextRank];
    NSNumber *nextPoint = dict[@"nextPoint"];
    self.nextPoint = [nextPoint floatValue];
    self.nextRank = dict[@"nextRank"];
    self.nextRankSubLabel.text = [NSString stringWithFormat:@"%@ランクまで",self.nextRank];
    self.userPoint = [[GXPointManager sharedInstance] getCurrentPoint];
    if (self.userPoint != 0) {
        self.nowProgress = (self.userPoint / self.nextPoint);
        [self.rankProgressView setProgress:self.nowProgress];
    } else {
        [self.rankProgressView setProgress:0];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self googleAnalytics];
    self.gotQuestPoint = [[GXPointManager sharedInstance] getQuestClearPoint:self.quest]; //取得ポイントを登録
    [self.pointLable animationFrom:0 to:self.gotQuestPoint withDuration:1.0];
    
    [self clearQuest];
    
    //activity
    [self setActivity];
    [NSObject performBlock:^{
        self.userPoint = [[GXPointManager sharedInstance] getCurrentPoint]; //refresh
        self.currentPointLabel.text = [NSString stringWithFormat:@"%d",(int)self.userPoint];
        [self setProgress];
    } afterDelay:2.0];
}

- (void)setProgress
{
    float progress = self.userPoint / self.nextPoint;
    [self.rankProgressView setProgress:progress animated:YES];
    NSLog(@"progress:%f",progress);
    
    if (progress >= 1.0) {
        //rankup
        [self rankUP];
    }
}

- (void)rankUP
{
    NSLog(@"rankUP");
    FUIAlertView *alert = [FUIAlertView rankUPTheme:self.nextRank];
    alert.delegate = self;
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearQuest
{
    [[GXExeQuestManager sharedManager] clearNowExeQuest];
}

- (void)setActivity
{
    KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
    NSString *questName = [self.quest getObjectForKey:quest_title];
    NSString *text = [NSString stringWithFormat:@"%@クエストを達成しました",questName];
    NSString *fbid = [gxUser getObjectForKey:user_fb_id];
    [[GXActivityList sharedInstance] registerQuestActivity:[gxUser getObjectForKey:user_name] title:text fbid:fbid];
    
}

- (void)googleAnalytics
{
    [GXGoogleTrackingManager sendScreenTracking:@"clearView"];
    [GXGoogleTrackingManager sendEventTracking:@"Quest" action:@"clear" label:@"クリア" value:nil screen:@"clearView"];

}

- (IBAction)gotoHome:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *initViewController = [storyboard instantiateInitialViewController];
    [self presentViewController:initViewController animated:NO completion:nil];

}

#pragma FUIAlert
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"rankup");
        [[GXPointManager sharedInstance] rankUP:self.nextRank];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *initViewController = [storyboard instantiateInitialViewController];
        [self presentViewController:initViewController animated:NO completion:nil];
    }
}
@end
