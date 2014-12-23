//
//  GXCreateBeaconQuestViewController.m
//
//
//  Created by 古田貴久 on 2014/12/19.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCreateBeaconQuestViewController.h"
#import "GXOnlineMemberTableViewController.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"
#import "FUIAlertView+GXTheme.h"
const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldMargin = 10.0f;
const static CGFloat kJVFieldFontSize = 16.0f;
const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

#define kQUEST_TYPE_ONE 0
#define KQUEST_TYPE_MULTI 1

#define kTARGET_USER_ALL 0
#define kTARGET_USER_SPECIFIC 2
#define kTARGET_USER_RANDOM 1

@interface GXCreateBeaconQuestViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property JVFloatLabeledTextField *titleField;
@property JVFloatLabeledTextView *descriptionView;
@property FUIButton *beaconSettingBtn;
@property FUIButton *targetUserBtn;
@property KiiObject *selectedBeaconObj;
@property KiiObject *selectedTargetObj;
@property NSInteger selectedButtonIndex; //どのボタンが押されたか
@property NSInteger quesytTypeIndex;
@property NSInteger targetTypeIndex;
@property UISegmentedControl *targetSegmentedControl;
@property UISegmentedControl *questTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation GXCreateBeaconQuestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat topOffset = 10;
    UIColor *floatingLabelColor = [UIColor brownColor];
    self.scrollView.scrollEnabled = YES;
    
    //title
    self.titleField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(kJVFieldMargin, topOffset, self.view.frame.size.width -2 * kJVFieldMargin, kJVFieldHeight)];
    self.titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"タイトル" attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    self.titleField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.titleField.floatingLabelTextColor = floatingLabelColor;
    self.titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.titleField.delegate = self;
    [self.scrollView addSubview:self.titleField];
    self.titleField.returnKeyType = UIReturnKeyDone;
    UIView *div1 = [UIView new];
    div1.frame = CGRectMake(kJVFieldMargin, self.titleField.frame.origin.y + self.titleField.frame.size.height, self.view.frame.size.width -2 * kJVFieldMargin, 1.0f);
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.scrollView addSubview:div1];
    
    //詳細
    self.descriptionView = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(kJVFieldMargin, div1.frame.origin.y + div1.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight*2)];
    self.descriptionView.placeholder = @"クエスト詳細";
    self.descriptionView.placeholderTextColor = [UIColor darkGrayColor];
    self.descriptionView.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.descriptionView.floatingLabelTextColor = floatingLabelColor;
    self.descriptionView.floatingLabelFont = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.descriptionView.delegate = self;
    self.descriptionView.returnKeyType = UIReturnKeyDone;
    [self.scrollView addSubview:self.descriptionView];
    UIView *div2 = [UIView new];
    div2.frame = CGRectMake(kJVFieldMargin, self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, 1.0f);
    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.scrollView addSubview:div2];
    
    //キーボード閉じるボタンを追加
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
    
    //クエストタイプ
    //クエストのタイプ
    UILabel *questTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kJVFieldMargin, div2.frame.origin.y + div2.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight)];
    questTypeLabel.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    questTypeLabel.textColor = [UIColor darkGrayColor];
    questTypeLabel.text = @"クエストのタイプ";
    [self.scrollView addSubview:questTypeLabel];
    
    self.questTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"一人",@"協力"]];
    self.questTypeSegmentedControl.frame = CGRectMake(kJVFieldMargin, questTypeLabel.frame.origin.y+questTypeLabel.frame.size.height, self.questTypeSegmentedControl.frame.size.width, self.questTypeSegmentedControl.frame.size.height);
    [self.questTypeSegmentedControl addTarget:self action:@selector(questTypeSegmented:) forControlEvents:UIControlEventValueChanged];
    self.questTypeSegmentedControl.selectedSegmentIndex = 0;
    [self.scrollView addSubview:self.questTypeSegmentedControl];
    
    UIView *div3 = [[UIView alloc] initWithFrame:CGRectMake(kJVFieldMargin, self.questTypeSegmentedControl.frame.origin.y + self.questTypeSegmentedControl.frame.size.height+5, self.view.frame.size.width - 2*kJVFieldMargin, 1.0)];
    div3.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.scrollView addSubview:div3];
    
    UILabel *settingBeaconLbl
    = [[UILabel alloc] initWithFrame:CGRectMake(kJVFieldMargin, div3.frame.origin.y + div3.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight)];
    settingBeaconLbl.textColor = [UIColor darkGrayColor];
    settingBeaconLbl.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    settingBeaconLbl.text = @"クリア判定をするビーコン";
    [self.scrollView addSubview:settingBeaconLbl];
    
    //クリア判定ビーコン設定
    self.beaconSettingBtn = [[FUIButton alloc] initWithFrame:CGRectMake(kJVFieldMargin, settingBeaconLbl.frame.origin.y + settingBeaconLbl.frame.size.height + 5, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight)];
    self.beaconSettingBtn.buttonColor = [UIColor turquoiseColor];
    self.beaconSettingBtn.shadowColor = [UIColor greenSeaColor];
    self.beaconSettingBtn.shadowHeight = 3.0f;
    self.beaconSettingBtn.cornerRadius = 6.0f;
    self.beaconSettingBtn.titleLabel.font = [UIFont boldFlatFontOfSize:13];
    [self.beaconSettingBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.beaconSettingBtn setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [self.beaconSettingBtn setTitle:@"クリア判定をするビーコンを設定" forState:UIControlStateNormal];
    [self.beaconSettingBtn setTitle:@"設定する" forState:UIControlStateHighlighted];
    [self.beaconSettingBtn bk_addEventHandler:^(id sender) {
        self.selectedButtonIndex = 0;
        [self performSegueWithIdentifier:@"getMember" sender:self];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.beaconSettingBtn];
    
    UIView *div4 = [UIView new];
    div4.frame = CGRectMake(kJVFieldMargin, self.beaconSettingBtn.frame.origin.y + self.beaconSettingBtn.frame.size.height+5, self.view.frame.size.width - 2*kJVFieldMargin, 1.0f);
    div4.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.scrollView addSubview:div4];
    
    //segment - questType
    
    //誰に配信する？
    UILabel *targetUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(kJVFieldMargin, div4.frame.origin.y + div4.frame.size.height, self.view.frame.size.width -2*kJVFieldMargin, kJVFieldHeight)];
    targetUserLabel.textColor = [UIColor darkGrayColor];
    targetUserLabel.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    targetUserLabel.text = @"誰に配信する？";
    [self.scrollView addSubview:targetUserLabel];
    
    //targetSegmentedControl
    self.targetSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"みんな",@"ランダム",@"特定のメンバー"]];
    self.targetSegmentedControl.frame = CGRectMake(kJVFieldMargin, targetUserLabel.frame.origin.y + targetUserLabel.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, self.targetSegmentedControl.frame.size.height);
    [self.targetSegmentedControl addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.targetSegmentedControl];
    self.targetSegmentedControl.selectedSegmentIndex = 0;
    
    self.targetUserBtn = [FUIButton buttonWithType:UIButtonTypeCustom];
    self.targetUserBtn.frame = CGRectMake(kJVFieldMargin, self.targetSegmentedControl.frame.origin.y+self.targetSegmentedControl.frame.size.height+5, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight);
    self.targetUserBtn.buttonColor = [UIColor turquoiseColor];
    self.targetUserBtn.shadowColor = [UIColor greenSeaColor];
    self.targetUserBtn.shadowHeight = 3.0f;
    self.targetUserBtn.cornerRadius = 6.0f;
    self.targetUserBtn.titleLabel.font = [UIFont boldFlatFontOfSize:13];
    self.targetUserBtn.titleLabel.textColor = [UIColor cloudsColor];
    [self.targetUserBtn setTitle:@"who?" forState:UIControlStateNormal];
    [self.targetUserBtn setTitle:@"who?" forState:UIControlStateHighlighted];
    [self.targetUserBtn bk_addEventHandler:^(id sender) {
        self.selectedButtonIndex = 1;
        [self performSegueWithIdentifier:@"getMember" sender:self];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.targetUserBtn];
    self.targetUserBtn.hidden = YES;
    
    //scrollViewの大きさを設定
    //最後のUI要素＋10
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.targetUserBtn.frame.origin.y+self.targetUserBtn.frame.size.height + 10);
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconSet:) name:@"beaconSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(targetUserSet:) name:@"targetUserSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushedCreateButton:) name:@"pushCreateButton" object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.titleField resignFirstResponder];
    return YES;
}



#pragma mark Notificaiton
- (void)beaconSet:(NSNotification *)notis
{
    self.selectedBeaconObj = notis.object;
    [self.beaconSettingBtn setTitle:[self.selectedBeaconObj getObjectForKey:@"name"] forState:UIControlStateNormal];
    [self.beaconSettingBtn setTitle:[self.selectedBeaconObj getObjectForKey:@"name"] forState:UIControlStateHighlighted];
}

- (void)targetUserSet:(NSNotification *)notis
{
    self.selectedTargetObj = notis.object;
    [self.targetUserBtn setTitle:[self.selectedTargetObj getObjectForKey:@"name"] forState:UIControlStateNormal];
    [self.targetUserBtn setTitle:[self.selectedTargetObj getObjectForKey:@"name"] forState:UIControlStateHighlighted];
}

//ExE servercode
- (void)pushedCreateButton:(NSNotification *)notis
{
    //servercodeを動かす
    //varidation
    if (self.titleField.text.length == 0) {
        CWStatusBarNotification *notis = [CWStatusBarNotification new];
        notis.notificationLabelBackgroundColor = [UIColor redColor];
        [notis displayNotificationWithMessage:@"タイトルを入力してください" forDuration:2.0f];
        return;
    }
    
    if (self.selectedBeaconObj == nil) {
        CWStatusBarNotification *notis = [CWStatusBarNotification new];
        notis.notificationLabelBackgroundColor = [UIColor redColor];
        [notis displayNotificationWithMessage:@"クリア判定用のビーコンを指定して下さい" forDuration:2.0f];
        return;
    }
    
    if (self.targetTypeIndex == kTARGET_USER_SPECIFIC) {
        if (self.selectedTargetObj == nil) {
            CWStatusBarNotification *notis = [CWStatusBarNotification new];
            notis.notificationLabelBackgroundColor = [UIColor redColor];
            [notis displayNotificationWithMessage:@"配信先のユーザを指定して下さい" forDuration:2.0f];
            return;
        }
        return;
    }
    
    KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
    NSString *questTitle = self.titleField.text;
    NSString *questDescription = self.descriptionView.text;
    NSNumber *tMajor = [self.selectedBeaconObj getObjectForKey:@"user_major"];
    NSString *tMajorOwnerFBID = [self.selectedBeaconObj getObjectForKey:user_fb_id];
    
    NSString *userName = [gxUser getObjectForKey:user_name];
    NSString *userFBID = [gxUser getObjectForKey:user_fb_id];
    
    KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"deliverAllMember"];
    NSDictionary *argDict = @{@"questType":[NSNumber numberWithInteger:self.quesytTypeIndex],
                              @"questTitle":questTitle,
                              @"questDescription":questDescription,
                              @"tMajor":tMajor,
                              @"tMajorOwnerFBID":tMajorOwnerFBID,
                              @"createrName":userName,
                              @"createrFBID":userFBID};
    
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
    NSError *error;
    KiiServerCodeExecResult *result = [entry executeSynchronous:argument withError:&error];
    
    //Perse the result.
    NSDictionary *returnedDict = [result returnedValue];
    NSString *returnString = [returnedDict objectForKey:@"returnedValue"];
    NSLog(@"%@",returnString);
    CWStatusBarNotification *successNotis = [CWStatusBarNotification new];
    successNotis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
    [successNotis displayNotificationWithMessage:@"クエストを作成しました!" forDuration:2.0f];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)notisRemove
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma  mark SegmentChang -
- (void)segmentedChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case kTARGET_USER_ALL:
            self.targetTypeIndex = kTARGET_USER_ALL;
            self.targetUserBtn.hidden = YES;
            break;
            
        case kTARGET_USER_RANDOM:
            self.targetTypeIndex = kTARGET_USER_RANDOM;
            self.targetUserBtn.hidden = YES;
            break;
        case kTARGET_USER_SPECIFIC:
            self.targetTypeIndex = kTARGET_USER_SPECIFIC;
            self.targetUserBtn.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)questTypeSegmented:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case kQUEST_TYPE_ONE:
            //一人用クエスト
            self.quesytTypeIndex = kQUEST_TYPE_ONE;
            break;
            
        case KQUEST_TYPE_MULTI:
            //協力
            self.quesytTypeIndex = KQUEST_TYPE_MULTI;
            break;
            
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"getMember"]) {
        GXOnlineMemberTableViewController *vc = segue.destinationViewController;
        vc.index = self.selectedButtonIndex;
    }
}

@end
