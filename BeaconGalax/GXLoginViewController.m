//
//  GXLoginViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/27.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXLoginViewController.h"
#import "GXKiiCloud.h"
#import "GXNotification.h"
#import "GXTopicManager.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXUserDefaults.h"
@interface GXLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic,retain) FBProfilePictureView *profilePictureView;

@property UIButton *loginButton;
@property UIButton *startButton;

@end

#define BUTTON_SLID_DOWN_OFFSET_Y 70
#define LOGIN_BUTTON_OFFSET_Y 150

@implementation GXLoginViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - ViewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:self.view.bounds andColors:@[FlatGreen,FlatGreenDark]];
    
    
    //init UI
    //LoginButton
    self.loginButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 100 ,
                                                                  self.view.center.y + LOGIN_BUTTON_OFFSET_Y,
                                                                  200, 50)];
    [self.loginButton.layer setCornerRadius:5];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:FlatWhite forState:UIControlStateNormal];
    [self.loginButton setTitleColor:FlatWhiteDark forState:UIControlStateHighlighted];
    self.loginButton.backgroundColor = [UIColor clearColor];
    self.loginButton.layer.borderWidth = 1.0;
    [self.loginButton.layer setBorderColor:FlatWhite.CGColor];
    
    [self.loginButton addTarget:self action:@selector(loginButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    //startボタン
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-100,
                                                                   self.view.center.y+LOGIN_BUTTON_OFFSET_Y,
                                                                   200, 50)];
    
    
    [self.startButton setTitle:@"GetStarted" forState:UIControlStateNormal];
    self.startButton.backgroundColor = [UIColor clearColor];
    [self.startButton.layer setBorderColor:FlatWhite.CGColor];
    [self.startButton.layer setBorderWidth:1.0];
    [self.startButton.layer setCornerRadius:5];
    [self.startButton setTitleColor:FlatWhite forState:UIControlStateNormal];
    [self.startButton setTitleColor:FlatWhiteDark forState:UIControlStateHighlighted];
    
    [self.startButton bk_addEventHandler:^(id sender) {
        //home画面に遷移
        [self dismissViewControllerAnimated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    self.startButton.alpha = 0.0f;
    [self.view addSubview:self.startButton];
    
    //プロフィール写真
    self.profilePictureView = [[FBProfilePictureView alloc] initWithFrame:CGRectMake(self.view.center.x-50, self.view.center.y, 100, 100)];
    [self.profilePictureView.layer setCornerRadius:50.0f];
    [self.profilePictureView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.profilePictureView.layer setBorderWidth:1.5f];
    [self.view addSubview:self.profilePictureView];
    self.profilePictureView.hidden = YES;
    
    }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginHandler) name:GXLoginSuccessedNotification object:nil];

    [self configureButton];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginButtonAction
{
    if ([KiiUser loggedIn]) {
        [KiiUser logOut];
        
        self.profilePictureView.hidden = YES;
        [self fadeOut];
        
    } else if (![KiiUser loggedIn]){
        [SVProgressHUD show];
        [[GXKiiCloud sharedManager] kiiCloudLogin];
    }
    
    [self configureButton];
    
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

- (void)configureButton
{
    if ([KiiUser loggedIn]) {
        [self.loginButton setTitle:@"LOGOUT" forState:UIControlStateNormal];
    } else {
        [self.loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    }
}

- (void)configurePicutureView
{
   //現在のユーザのKiiObjectをフェッチする
    KiiObject *userObject = [[GXBucketManager sharedManager] getMeFromGalaxUserBucket];
    NSString *fb_id = [userObject getObjectForKey:@"facebook_id"];
    NSString *name = [userObject getObjectForKey:@"name"];
    self.profilePictureView.profileID = fb_id;
    
    //ついでにudに保存
    [GXUserDefaults setUserInfomation:fb_id name:name];
    
   
    
    if (self.profilePictureView.hidden == YES) {
        self.profilePictureView.hidden = NO;
    }
}

#pragma  mark GXNotification
- (void)loginHandler
{
    
    [SVProgressHUD dismiss];
    
    if ([KiiUser loggedIn]) {
        
        //signUpかどうか
        //初回起動フラグを見る
        //初回起動だったらgxUserに登録する
        if ([GXUserDefaults isFirstLaunch]) {
            //Init
            KiiUser *currentUser = [KiiUser currentUser];
            
            [[GXBucketManager sharedManager] registerGalaxUser:currentUser];
            [[GXTopicManager sharedManager] createDefaultUserTopic];
            [[GXTopicManager sharedManager] setACL];
            
            //accesstokenの保存
            NSString *accessToken = [currentUser accessToken];
            [GXUserDefaults setAccessToken:accessToken];
            
        }
        
    }
    
    [self configureButton];
    [self configurePicutureView];
    [self buttonShowAnimationWithLogin];
    
}


#pragma mark - Exit
- (IBAction)goBack:(UIStoryboardSegue *)sender
{
}

#pragma mark ButtonAnimation
- (void)buttonShowAnimationWithLogin
{
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = CGRectMake(self.loginButton.frame.origin.x,
                                     self.loginButton.frame.origin.y+BUTTON_SLID_DOWN_OFFSET_Y,
                                     self.loginButton.frame.size.width,
                                     self.loginButton.frame.size.height);
        
        self.loginButton.frame = newFrame;
        
    } completion:^(BOOL finished) {
        
        [self fadeIn];
        
    }];
}

- (void)butonShowAnimationSlideUP
{
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = CGRectMake(self.loginButton.frame.origin.x,
                                     self.loginButton.frame.origin.y - BUTTON_SLID_DOWN_OFFSET_Y,
                                     self.loginButton.frame.size.width,
                                     self.loginButton.frame.size.height);
        
        self.loginButton.frame = newFrame;
        
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)fadeIn
{
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.startButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)fadeOut
{
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.startButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        //loginボタンを元の位置に戻す
        [self butonShowAnimationSlideUP];
    }];
}


@end
