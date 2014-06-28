//
//  GXLoginViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/27.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXLoginViewController.h"

@interface GXLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictView;
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

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
    
    //[self kiiCloudLogin];
    
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self kiiCloudLogin];
    
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


#pragma mark - KiiCloudログイン
- (void)kiiCloudLogin
{
    [KiiSocialConnect setupNetwork:kiiSCNFacebook withKey:@"559613677480642" andSecret:nil andOptions:nil];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSArray arrayWithObject:@"email"],@"permissions",@"public_profile", nil];
    
    [KiiSocialConnect logIn:kiiSCNFacebook usingOptions:options withDelegate:self andCallback:@selector(loginFinished:usingNetwork:withError:)];
    
}

- (void)loginFinished:(KiiUser *)user usingNetwork:(KiiSocialNetworkName)network withError:(NSError *)error {
    
    if (error == nil) {
        
        NSLog(@"login successed");
        
        //push通知
        [Kii enableAPNSWithDevelopmentMode:TRUE andNotificationTypes:UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeBadge];

    } else {
        NSLog(@"error : %@",error);
    }
}

@end
