//
//  GXLeaderBoardViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/06.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXLeaderBoardViewController.h"
#import  <REFrostedViewController.h>
#import "GXPointManager.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"

@interface GXLeaderBoardViewController ()
@property (weak, nonatomic) IBOutlet UIButton *gotoRanking;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankSubLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIcon;
@property (weak, nonatomic) IBOutlet UIProgressView *rankProgressView;
@property NSString *nextRank;
@property float nextPoint;
@end

@implementation GXLeaderBoardViewController

#pragma mark - ViewLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.userIcon.layer.cornerRadius = 35.0f;
    self.userIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userIcon.layer.borderWidth = 2.0f;
    self.pointLabel.font = [UIFont boldFlatFontOfSize:20];
    self.rankLabel.font = [UIFont boldFlatFontOfSize:20];
    self.rankSubLabel.font = [UIFont boldFlatFontOfSize:20];
    self.rankProgressView.transform = CGAffineTransformMakeScale(1.0, 4.0);
    self.rankProgressView.trackTintColor = [UIColor cloudsColor];
    self.rankProgressView.progressTintColor = [UIColor sunflowerColor];
    
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
    
    [[GXPageViewAnalyzer shareInstance] setPageView:NSStringFromClass([self class])];
    
    [self configureStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureStatus
{
    int point  = [[GXPointManager sharedInstance] getCurrentPoint];
    self.pointLabel.text = [NSString stringWithFormat:@"取得ポイント数: %d",point];
    
    NSDictionary *dict = [[GXPointManager sharedInstance] checkNextRank];
    NSNumber *nextPoint = dict[@"nextPoint"];
    self.nextPoint = [nextPoint floatValue];
    self.nextRank = dict[@"nextRank"];

    if (point != 0) {
        float progress = (point / self.nextPoint);
        [self.rankProgressView setProgress:progress];
    } else {
        [self.rankProgressView setProgress:0];
    }
    
    KiiObject *gxUser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
    self.userIcon.profileID = [gxUser getObjectForKey:user_fb_id];
    
    NSString *rank = [gxUser getObjectForKey:@"rank"];
    self.rankLabel.text = [NSString stringWithFormat:@"現在のランク: %@ランク",rank];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)buttonPress
{
    [self.frostedViewController presentMenuViewController];
}

@end
