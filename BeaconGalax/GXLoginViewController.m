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

#import <FlatUIKit/FlatUIKit.h>

@interface GXLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictView;
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@property FUIButton *loginButton;

@end

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
    
    //パーミッション設定
    self.loginView.readPermissions = @[@"public_profile",@"email"];
    
    self.loginView.delegate = self;
    
    
    //init UI
    //LoginButton
    self.loginButton = [[FUIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 100 ,self.view.center.y + 100, 200, 50)];
    self.loginButton.buttonColor = [UIColor turquoiseColor];
    self.loginButton.shadowColor = [UIColor greenSeaColor];
    self.loginButton.shadowHeight = 3.0f;
    self.loginButton.cornerRadius = 6.0f;
    self.loginButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [self.loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginHandler) name:GXLoginSuccessedNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureButton];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginButtonAction
{
    [[GXKiiCloud sharedManager] kiiCloudLogin];
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

#pragma mark - Facebook Delegate

//公開プロフィールをとってきたとき
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    self.profilePictView.profileID = [user objectID];
    self.nameLabel.text = user.name;
    
    NSLog(@"プロフィール取得");
}

//ログイン中を表示する時
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    self.statusLabel.text = @"You're logged in as";
}

//ログアウト中の表示
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    self.statusLabel.text = @"You're not logged in ";
    self.profilePictView.profileID = nil;
    self.nameLabel.text = @"";
}

//エラーハンドラ
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;
    
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again";
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
    } else {
        alertTitle = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error: %@",error);
        
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
}

- (void)configureButton
{
    if ([KiiUser loggedIn]) {
        [self.loginButton setTitle:@"LOGOUT" forState:UIControlStateNormal];
    } else {
        [self.loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    }
}

#pragma  mark GXNotification
- (void)loginHandler
{
    [self configureButton];
}

#pragma mark - Exit
- (IBAction)goBack:(UIStoryboardSegue *)sender
{
}

@end
