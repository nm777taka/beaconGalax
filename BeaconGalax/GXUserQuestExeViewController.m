//
//  GXUserQuestExeViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXUserQuestExeViewController.h"
#import "GXClearViewController.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"

@interface GXUserQuestExeViewController ()<FUIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UAProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *questTitle;
@property (nonatomic,assign) BOOL paused;
@property (nonatomic,assign) float localQuestProgress;



@end

@implementation GXUserQuestExeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questCommitHandler:) name:GXCommitQuestNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL isOwner = [self isOwner];
    if (isOwner) {
        [self configureOwnerProgress];
    } else {
        [self configureParticipantProgress];
    }
    
    self.questTitle.text = [self.exeQuest getObjectForKey:quest_title];
}

- (BOOL)isOwner
{
    BOOL ret;
    NSError *error;
    KiiUser *owner = [self.exeGroup getOwnerSynchronous:&error];
    KiiUser *curUser = [KiiUser currentUser];
    if ([owner.objectURI isEqualToString:curUser.objectURI]) {
        ret = true;
    } else {
        ret = false;
    }
    
    return ret;
}

- (void)configureOwnerProgress
{
    self.paused = YES;
    self.progressView.tintColor = [UIColor alizarinColor];
    self.progressView.borderWidth = 2.0f;
    self.progressView.lineWidth = 2.0f;
    self.progressView.fillOnTouch = YES;
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 32.0)];
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:27];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = self.progressView.tintColor;
    textLabel.text = @"OK";
    self.progressView.centralView = textLabel;
    self.progressView.fillChangedBlock = ^(UAProgressView *progressView,BOOL filled, BOOL animated){
        UIColor *color = (filled ? [UIColor whiteColor] : progressView.tintColor);
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                [(UILabel *)progressView.centralView setTextColor:color];
            }];
        } else {
            [(UILabel *)progressView.centralView setTextColor:color];
        }
    };
    
    self.progressView.progressChangedBlock = ^(UAProgressView *progressView,float progress){
        [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%",progress * 100]] ;
        
        if (progress * 100 == 100) {
            [(UILabel *)progressView.centralView setText:@"Clear"];
            [SVProgressHUD showSuccessWithStatus:@"クリア処理中"];
            [NSTimer bk_scheduledTimerWithTimeInterval:2.0 block:^(NSTimer *timer) {
                //クリア処理
                [self gotoClearView];
            } repeats:NO];
        }
    };
    
    self.progressView.didSelectBlock = ^(UAProgressView *progressView){
        
        FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"確認"
                                                              message:@"このクエストを完了しますか？"
                                                             delegate:self cancelButtonTitle:@"まだ"
                                                    otherButtonTitles:@"達成!", nil];
        
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        alertView.messageLabel.textColor = [UIColor cloudsColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:14];
        alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        alertView.alertContainer.backgroundColor = [UIColor pomegranateColor];
        alertView.defaultButtonColor = [UIColor cloudsColor];
        alertView.defaultButtonShadowColor = [UIColor asbestosColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor asbestosColor];
        [alertView show];

    };


}

- (void)configureParticipantProgress
{
    self.paused = YES;
    self.progressView.tintColor = [UIColor emerlandColor];
    self.progressView.borderWidth = 2.0f;
    self.progressView.lineWidth = 2.0f;
    self.progressView.fillOnTouch = NO;
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 32.0)];
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:27];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = self.progressView.tintColor;
    textLabel.text = @"0%";
    self.progressView.centralView = textLabel;
    self.progressView.fillChangedBlock = ^(UAProgressView *progressView,BOOL filled, BOOL animated){
        UIColor *color = (filled ? [UIColor whiteColor] : progressView.tintColor);
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                [(UILabel *)progressView.centralView setTextColor:color];
            }];
        } else {
            [(UILabel *)progressView.centralView setTextColor:color];
        }
    };
    
    self.progressView.progressChangedBlock = ^(UAProgressView *progressView,float progress){
        [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%",progress * 100]] ;
        
        if (progress * 100 == 100) {
            [(UILabel *)progressView.centralView setText:@"Clear"];
            [SVProgressHUD showSuccessWithStatus:@"クリア処理中"];
            [NSTimer bk_scheduledTimerWithTimeInterval:2.0 block:^(NSTimer *timer) {
                //クリア処理
                [self gotoClearView];
            } repeats:NO];
        }
    };
    
    self.progressView.didSelectBlock = ^(UAProgressView *progressView){
        
        FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Wait"
                                                              message:@"オーナーによるクリア判定待ちです"
                                                             delegate:nil cancelButtonTitle:@"Dismiss"
                                                    otherButtonTitles:nil, nil];
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        alertView.messageLabel.textColor = [UIColor cloudsColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:14];
        alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
        alertView.alertContainer.backgroundColor = [UIColor nephritisColor];
        alertView.defaultButtonColor = [UIColor cloudsColor];
        alertView.defaultButtonShadowColor = [UIColor asbestosColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor asbestosColor];
        [alertView show];

    };
    
}

- (void)commitQuest
{
    NSLog(@"groupURI:%@",self.exeGroup.objectURI);
    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"commitUserCreateQuest"];
    NSDictionary *argDict = [NSDictionary dictionaryWithObjectsAndKeys:self.exeGroup.objectURI,@"groupURI", nil];
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];

    [entry execute:argument withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
        NSDictionary *returnedDict = [result returnedValue];
        NSLog(@"returned:%@",returnedDict);
    }];
}

#pragma mark FUIAlertDelegate
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self commitQuest];
            break;
            
        default:
            break;
    }
}

#pragma mark GXNotification
- (void)questCommitHandler:(NSNotification *)notis
{
    [self.progressView setProgress:1.0f animated:YES];
}

- (void)gotoClearView
{
    [self performSegueWithIdentifier:@"gotoClearView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoClearView"]) {
        
        GXClearViewController *vc = segue.destinationViewController;
        vc.point = 100;
        vc.group = self.exeGroup;
        vc.quest = self.exeQuest;
    }
}

@end
