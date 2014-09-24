//
//  GXQuestPrepareViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestPrepareViewController.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"

@interface GXQuestPrepareViewController ()
@property (weak, nonatomic) IBOutlet CSAnimationView *ownerAnimationView;
@property (weak, nonatomic) IBOutlet CSAnimationView *participantAnimationView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *ownerIcon;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *participantIcon;

@end

@implementation GXQuestPrepareViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //募集者
    self.ownerIcon.layer.cornerRadius = 60;
    self.ownerIcon.layer.borderWidth  = 2.0;
    self.ownerIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ownerIcon.profileID = [self.questObject getObjectForKey:quest_createdUser_fbid];
    
    //参加者
    self.participantIcon.layer.cornerRadius = 60.0;
    self.participantIcon.layer.borderWidth = 2.0;
    self.participantIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    
    KiiObject *currentUser = [[GXBucketManager sharedManager] getMeFromGalaxUserBucket];
    self.participantIcon.profileID = [currentUser getObjectForKey:user_fb_id];
    
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.ownerAnimationView startCanvasAnimation];
    [self.participantAnimationView startCanvasAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)closeView:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
