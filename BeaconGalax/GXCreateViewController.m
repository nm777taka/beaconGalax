//
//  GXCreateViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCreateViewController.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"
#import <RMDateSelectionViewController.h>
#import "GXDictonaryKeys.h"
#import "GXUserDefaults.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXActivityList.h"
#import "GXCreateViewController.h"
#import "GXTopicManager.h"
#import "GXPointManager.h"
#import "Device.h"

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldMargin = 10.0f;
const static CGFloat kJVFieldFontSize = 15.0f;
const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

#define kQUEST_TYPE_ONE 0
#define KQUEST_TYPE_MULTI 1

#define kTARGET_USER_ALL 0
#define kTARGET_USER_SPECIFIC 1

@interface GXCreateViewController ()<UITextFieldDelegate,UITextViewDelegate,RMDateSelectionViewControllerDelegate>
- (IBAction)create:(id)sender;
- (IBAction)closeView:(id)sender;

@property JVFloatLabeledTextField *titleField;
@property JVFloatLabeledTextView *descriptionView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property UIButton *dateSettingButton;
@property NSString *selectedDateString;
@property NSDate *selectedDate;

@end

@implementation GXCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat topOffset = 64;
    //init
    UIColor *floatingLabelColor = [UIColor brownColor];
    self.userIcon.layer.cornerRadius = 5.0f;
    self.userNameLabel.font = [UIFont boldFlatFontOfSize:15];
    [self setUserQuestCreateUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDictionary *userInfo = [GXUserDefaults getUserInfomation];
    self.userIcon.profileID = userInfo[@"GXFacebookID"];
    self.userNameLabel.text = userInfo[@"GXUserName"];
    [[GXPageViewAnalyzer shareInstance] setPageView:NSStringFromClass([self class])];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UI

- (void)setUserQuestCreateUI
{
    UIColor *floatingLabelColor = [UIColor turquoiseColor];
    
    //title
    self.titleField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(kJVFieldMargin, self.userIcon.frame.size.height + 64 + 10, self.view.frame.size.width -2 * kJVFieldMargin, kJVFieldHeight)];
    self.titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"これからなにしたい？" attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    self.titleField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.titleField.floatingLabelTextColor = floatingLabelColor;
    self.titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.titleField.delegate = self;
    [self.view addSubview:self.titleField];
    self.titleField.returnKeyType = UIReturnKeyDone;
    UIView *div1 = [UIView new];
    div1.frame = CGRectMake(kJVFieldMargin, self.titleField.frame.origin.y + self.titleField.frame.size.height, self.view.frame.size.width -2 * kJVFieldMargin, 1.0f);
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div1];
    
    //詳細
    self.descriptionView = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(kJVFieldMargin, div1.frame.origin.y + div1.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight*2)];
    self.descriptionView.placeholder = @"クエスト詳細";
    self.descriptionView.placeholderTextColor = [UIColor darkGrayColor];
    self.descriptionView.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.descriptionView.floatingLabelTextColor = floatingLabelColor;
    self.descriptionView.floatingLabelFont = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.descriptionView.delegate = self;
    self.descriptionView.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.descriptionView];
    
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    accessoryView.backgroundColor = [UIColor darkGrayColor];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(320-100, 5, 100, 30);
    [closeButton setTitle:@"close" forState:UIControlStateNormal];
    [closeButton bk_addEventHandler:^(id sender) {
        [self.descriptionView resignFirstResponder];
    } forControlEvents:UIControlEventTouchUpInside];
    [accessoryView addSubview:closeButton];
    self.descriptionView.inputAccessoryView = accessoryView;
    
//    UIView *div2 = [UIView new];
//    div2.frame = CGRectMake(kJVFieldMargin, self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, 1.0f);
//    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
//    [self.view addSubview:div2];
    self.dateSettingButton = [UIButton new];
    self.dateSettingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dateSettingButton.frame = CGRectMake(kJVFieldMargin, self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height, self.view.frame.size.width -2*kJVFieldMargin, 40);
    self.dateSettingButton.layer.borderColor = [UIColor turquoiseColor].CGColor;
    self.dateSettingButton.layer.borderWidth = 1.0f;
    
    // キャプションを設定
    [self.dateSettingButton setTitle:@"クエスト開始予定時間"
            forState:UIControlStateNormal];
    self.dateSettingButton.tintColor = [UIColor turquoiseColor];
    
    // キャプションに合わせてサイズを設定
  //  [button sizeToFit];
    [self.dateSettingButton bk_addEventHandler:^(id sender) {
        //datePickecerを呼び出す
        RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
        dateSelectionVC.delegate = self;
        [dateSelectionVC show];
    } forControlEvents:UIControlEventTouchUpInside];
    // ボタンをビューに追加
    [self.view addSubview:self.dateSettingButton];
    

}

#pragma mark TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.titleField resignFirstResponder];
    return YES;
}

- (IBAction)create:(id)sender
{
    if (self.titleField.text.length == 0) {
        CWStatusBarNotification *notis = [CWStatusBarNotification new];
        notis.notificationLabelBackgroundColor = [UIColor redColor];
        [notis displayNotificationWithMessage:@"タイトルを入力してください" forDuration:2.0f];
        return;
    }
    
    [self createUserQuest];
}

- (void)createUserQuest
{
    KiiObject *newObj = [KiiObject new];
    [newObj setObject:self.titleField.text forKey:quest_title];
    [newObj setObject:self.descriptionView.text forKey:quest_description];
    [newObj setObject:@NO forKey:quest_isCompleted];
    [newObj setObject:@NO forKey:quest_isStarted];
    [newObj setObject:[NSNumber numberWithInt:2] forKey:quest_player_num];
    [newObj setObject:[NSNumber numberWithInt:0] forKey:quest_success_cnt];
    [newObj setObject:@"user" forKey:quest_type];
    [newObj setObject:self.selectedDateString forKey:@"start_date"];
    //ユーザに紐付いたビーコンを取ってくる
    KiiObject *gxUser = [[GXBucketManager sharedManager] getGalaxUser:[KiiUser currentUser].objectURI];
    NSNumber *user_major = [gxUser getObjectForKey:@"user_major"];
    [newObj setObject:@"user" forKey:quest_type];
    [newObj setObject:user_major forKey:@"major"]; //対象
    
    //投稿
    [[GXBucketManager sharedManager] registerInviteBoard:newObj];

    //activityに登録 --- >dubg中のなのでoff
    NSString *name = [gxUser getObjectForKey:user_name];
    NSString *fbid = [gxUser getObjectForKey:user_fb_id];
    NSString *text = [NSString stringWithFormat:@"%@クエストを作成しました",self.titleField.text];
    //[[GXActivityList sharedInstance] registerQuestActivity:name title:text fbid:fbid];

    //みんなに伝える
    //とりあえずoff -- > dubug
//    NSString *createdUserName = [gxUser getObjectForKey:@"name"];
//    [[GXTopicManager sharedManager] sendInviteQuestAlert:createdUserName]; //新しい募集をpushで知らせる (ユーザクエの場合は募集が前提)
    
    //pointゲット
    [[GXPointManager sharedInstance] getCreateQuestPoint];
    [[GXActionAnalyzer sharedInstance] setActionName:GXQuestCreate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RMDataSelectionDelegate
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate
{
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"MM/dd HH:mm";
    NSString *dfStringDate = [df stringFromDate:aDate];
    NSString *buttonTitle = [NSString stringWithFormat:@"クエスト開始予定時間：%@",dfStringDate];
    self.selectedDateString = dfStringDate;
    [self.dateSettingButton setTitle:buttonTitle forState:UIControlStateNormal];
    
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc
{
    
}


@end
