//
//  GXViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXViewController.h"
#import "GXKiiCloud.h"
#import "GXBucketManager.h"
#import <CSAnimationView.h>
#import <FlatUIKit/FlatUIKit.h>
#import <FacebookSDK/Facebook.h>
#import <Accounts/Accounts.h>


@interface GXViewController ()

@property GXKiiCloud *kiiCloudManager;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbProfileImageView;

@property (nonatomic) ACAccountStore *accountStore;

@property KiiBucket *bucket;
@property NSMutableArray *nearUser;

@end

@implementation GXViewController

#pragma mark - ViewLifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UI init
    FUIButton *helpButton = [[FUIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 50, self.view.frame.size.height - 100, 100, 50)];
    helpButton.buttonColor = [UIColor turquoiseColor];
    helpButton.shadowColor = [UIColor greenSeaColor];
    helpButton.shadowHeight = 3.0f;
    helpButton.cornerRadius = 6.0f;
    helpButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [helpButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [helpButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [helpButton setTitle:@"HELP" forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(testSelector:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:helpButton];
    
    self.kiiCloudManager = [GXKiiCloud sharedManager];
    
    self.nearUser = [NSMutableArray new];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view startCanvasAnimation];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![KiiUser loggedIn]) {
        
        [self performSegueWithIdentifier:@"GoToLoginView" sender:self];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Exit
- (IBAction)goBack:(UIStoryboardSegue *)sender
{
    
}

#pragma mark - Button Action

- (void)testSelector:(id)sender
{
//    //test sertver code　を実行する
//    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"server_time"];
//    
//    //set the custom paraeters.
//    
//    NSError *error = nil;
//    KiiServerCodeExecResult *result = [entry executeSynchronous:nil withError:&error];
//    
//    //Parse
//    NSDictionary *returenedDict = [result returnedValue];
//    NSString *timestamp = [returenedDict objectForKey:@"returnedValue"];
//    
//    NSLog(@"timestamp %@",timestamp);
    
    self.nearUser = [[GXBucketManager sharedManager] getNearUser:[KiiUser currentUser]];
    
    
    NSLog(@"near user count : %d",self.nearUser.count);
    
    if (self.nearUser.count != 0) {
        
        NSError *error = nil;
        
        for (KiiObject *target in self.nearUser) {
            NSString *targetURI = [target getObjectForKey:@"uri"];
            KiiUser *targetUser = [KiiUser userWithURI:targetURI];
            KiiTopic *targetTopic = [targetUser topicWithName:@"invite_notify"];
            
            KiiAPNSFields *apnsFiled = [KiiAPNSFields createFields];
            
            //ここでpushになにかしら情報を加えることができる
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            [dictionary setObject:targetUser.displayName forKey:@"From"];
            [dictionary setObject:@"HELP" forKey:@"msgBody"];
            
            [apnsFiled setSpecificData:dictionary];
            
            KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFiled andGCMFields:nil];
            
            //send
            [targetTopic sendMessageSynchronous:message withError:&error];
            
            if (error) {
                NSLog(@"push message error %@",error);
            } else {
                NSLog(@"push message successed");
            }
        }
    
    }
    
    
}

#pragma mark acconts-fb(使うかどうかは今後)

- (void)loginForFBapp
{
    
    //accounts
    if (self.accountStore == nil) {
        self.accountStore = [ACAccountStore new];
    }
    
    //facebokに指定
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    //許可
    NSDictionary *options = @{ACFacebookAppIdKey:@"559613677480642",
                              ACFacebookAudienceKey:ACFacebookAudienceOnlyMe,
                              ACFacebookPermissionsKey : @[@"email"]};
    
    [self.accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (granted) {
                
                //ユーザがfacebookアカウントへのアクセスを許可した
                NSArray *facebookAccounts = [self.accountStore accountsWithAccountType:accountType];
                
                if (facebookAccounts.count >0) {
                    ACAccount *facebookAccount = [facebookAccounts lastObject];
                    
                    //メールアドレスを取得
                    NSString *email = facebookAccount.username;
                    NSString *fullName = [[facebookAccount valueForKey:@"properties"] objectForKey:@"ACUIDisplayUsername"];
                    
                    //アクセストークンを取得
                    ACAccountCredential *facebookCredential = [facebookAccount credential];
                    NSString *accessToken = [facebookCredential oauthToken];
                    NSLog(@"email : %@ , fullname : %@ ,token : %@",email,fullName,accessToken);
                    
                    
                    //ここでログイン処理
                }
            } else {
                if ([error code] == ACErrorAccountNotFound) {
                    NSLog(@"iOSにfaceBookアカウントが登録されていません。設定から追加して下さい");
                } else {
                    //ユーザが許可しない
                    NSLog(@"facebookが有効になっていません");
                }
            }
        });
    }];

}



@end
