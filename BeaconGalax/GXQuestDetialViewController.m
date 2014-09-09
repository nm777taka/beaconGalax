//
//  GXQuestDetialViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestDetialViewController.h"
#import "FUIButton+GXTheme.h"
#import "FUIAlertView+GXAlertView.h"
#import "GXNotification.h"

@interface GXQuestDetialViewController ()
- (IBAction)closeAction:(id)sender;
- (IBAction)joinAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *detailPanel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet FUIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *bgButton;

@property BOOL isCreatedUser;

- (IBAction)bgButtonAction:(id)sender;

@end

@implementation GXQuestDetialViewController

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
    self.view.alpha = 0.0f;
    self.detailPanel.backgroundColor = [UIColor belizeHoleColor];
    self.detailPanel.layer.cornerRadius = 5.0f;
    self.detailPanel.layer.borderWidth = 2.0f;
    self.detailPanel.layer.borderColor = [UIColor sunflowerColor].CGColor;
    
    self.bgButton.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.5];
    
    self.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    self.titleLabel.textColor = [UIColor cloudsColor];
    
    self.descriptionLabel.textColor = [UIColor cloudsColor];
    self.descriptionLabel.font = [UIFont boldFlatFontOfSize:13];
    
    [FUIButton gxQuestTheme:self.joinButton withName:@"JOIN"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureDetailView];
    [self configureButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //fade IN
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
    
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


#pragma mark - Configure detailView
- (void)configureDetailView
{
    self.titleLabel.text = [self.quest getObjectForKey:@"title"];
    self.descriptionLabel.text = [self.quest getObjectForKey:@"description"];

}

#pragma mark - Configure Button
- (void)configureButton
{
    //クエスト作成者なら削除ボタンを
    //クエスト作成者でないなら参加ボタンを
    
    KiiUser *currentUser = [KiiUser currentUser];
    NSString *questCreatedUserURI = [self.quest getObjectForKey:@"created_user_uri"];
    
    if ([currentUser.objectURI compare:questCreatedUserURI] == NSOrderedSame) {
        [FUIButton gxQuestTheme:self.joinButton withName:@"DELETE"];
        self.isCreatedUser = YES;
    } else {
        [FUIButton gxQuestTheme:self.joinButton withName:@"JOIN"];
        self.isCreatedUser = NO;
    }
    
}

- (IBAction)closeAction:(id)sender {
    [self closeView];
}

- (IBAction)joinAction:(id)sender {
    
    if (self.isCreatedUser) {
        //削除
        NSLog(@"delete");
        
        
        FUIAlertView *alert = [[FUIAlertView alloc] initWithTitle:@"確認" message:@"あなたが作成したクエストを削除しますか？" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"OK", nil];
        [FUIAlertView gxQuestTheme:alert];
        [alert show];

        
        } else {
        //参加
        NSLog(@"はいった");
    }
    
}
- (IBAction)bgButtonAction:(id)sender {
    [self closeView];
}

- (void)closeView
{
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        
    }];
}

#pragma mark Alert Delegate
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1: //削除OK
            NSLog(@"clicked");
            [self deleteQuest];
            break;
            
        default:
            break;
    }
}

- (void)deleteQuest
{
    NSError *error = nil;
    KiiObject *obj = [KiiObject objectWithURI:self.quest.objectURI];
    [obj deleteSynchronous:&error];
    if (error != nil) {
        NSLog(@"error----------> %@",error);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GXQuestDeletedNotification object:nil];
        [self closeView];
    }
    
}
@end
