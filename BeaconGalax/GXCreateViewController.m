//
//  GXCreateViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXCreateViewController.h"
#import "GXOnlineMemberTableViewController.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"

#import "GXDictonaryKeys.h"
#import "GXBucketManager.h"
#import "GXUserManager.h"
#import "GXActivityList.h"
#import "GXCreateViewController.h"
#import "GXTopicManager.h"
#import "GXPointManager.h"
#import "Device.h"

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldMargin = 10.0f;
const static CGFloat kJVFieldFontSize = 16.0f;
const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

#define kQUEST_TYPE_ONE 0
#define KQUEST_TYPE_MULTI 1

#define kTARGET_USER_ALL 0
#define kTARGET_USER_SPECIFIC 1

@interface GXCreateViewController ()<UITextFieldDelegate,UITextViewDelegate>
- (IBAction)create:(id)sender;
- (IBAction)closeView:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl; //ビーコンタイプを作るのかユーザタイプを作るのか
@property UIScrollView *scrollView;
@property UIView *beaconQuestContentView;
@property UIView *userQuestContentView;
@property JVFloatLabeledTextField *titleField;
@property JVFloatLabeledTextView *descriptionView;
@property FUIButton *beaconSettingBtn;
@property FUIButton *targetUserBtn;
@property KiiObject *selectedBeaconObj;
@property (nonatomic,strong) NSMutableArray *targetUsers;
@property NSInteger selectedButtonIndex; //どのボタンが押されたか
@property NSInteger quesytTypeIndex;
@property NSInteger targetTypeIndex; //どう配信するのか
@property UISegmentedControl *targetSegmentedControl;
@property UISegmentedControl *questTypeSegmentedControl;

@end

@implementation GXCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.segmentedControl addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectedSegmentIndex = 0;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat topOffset = 64;
    //init
    UIColor *floatingLabelColor = [UIColor brownColor];
    self.scrollView = [UIScrollView new];
    self.scrollView.frame = CGRectMake(0, topOffset, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.scrollView];
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    [self changeCreateUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconSet:) name:@"beaconSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(targetUserSet:) name:@"targetUserSet" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
- (void)setBeaconQuestCreateUI
{
    UIColor *floatingLabelColor = [UIColor brownColor];

    self.beaconQuestContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height + 100)];
    //title
    self.titleField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(kJVFieldMargin, 0, self.view.frame.size.width -2 * kJVFieldMargin, kJVFieldHeight)];
    self.titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"タイトル" attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    self.titleField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.titleField.floatingLabelTextColor = floatingLabelColor;
    self.titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.titleField.delegate = self;
    [self.beaconQuestContentView addSubview:self.titleField];
    self.titleField.returnKeyType = UIReturnKeyDone;
    UIView *div1 = [UIView new];
    div1.frame = CGRectMake(kJVFieldMargin, self.titleField.frame.origin.y + self.titleField.frame.size.height, self.view.frame.size.width -2 * kJVFieldMargin, 1.0f);
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.beaconQuestContentView addSubview:div1];
    
    //詳細
    self.descriptionView = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(kJVFieldMargin, div1.frame.origin.y + div1.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight*2)];
    self.descriptionView.placeholder = @"クエスト詳細";
    self.descriptionView.placeholderTextColor = [UIColor darkGrayColor];
    self.descriptionView.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.descriptionView.floatingLabelTextColor = floatingLabelColor;
    self.descriptionView.floatingLabelFont = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.descriptionView.delegate = self;
    self.descriptionView.returnKeyType = UIReturnKeyDone;
    [self.beaconQuestContentView addSubview:self.descriptionView];
    
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

    
    UIView *div2 = [UIView new];
    div2.frame = CGRectMake(kJVFieldMargin, self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, 1.0f);
    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.beaconQuestContentView addSubview:div2];
    
    UILabel *questTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kJVFieldMargin, div2.frame.origin.y + div2.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight)];
    questTypeLabel.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    questTypeLabel.textColor = [UIColor darkGrayColor];
    questTypeLabel.text = @"クエストのタイプ";
    [self.beaconQuestContentView addSubview:questTypeLabel];
    
    self.questTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"一人",@"協力"]];
    self.questTypeSegmentedControl.frame = CGRectMake(kJVFieldMargin, questTypeLabel.frame.origin.y+questTypeLabel.frame.size.height, self.questTypeSegmentedControl.frame.size.width, self.questTypeSegmentedControl.frame.size.height);
    [self.questTypeSegmentedControl addTarget:self action:@selector(questTypeSegmented:) forControlEvents:UIControlEventValueChanged];
    self.questTypeSegmentedControl.selectedSegmentIndex = 0;
    [self.beaconQuestContentView addSubview:self.questTypeSegmentedControl];
    
    UIView *div3 = [[UIView alloc] initWithFrame:CGRectMake(kJVFieldMargin, self.questTypeSegmentedControl.frame.origin.y + self.questTypeSegmentedControl.frame.size.height+5, self.view.frame.size.width - 2*kJVFieldMargin, 1.0)];
    div3.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.beaconQuestContentView addSubview:div3];
    
    UILabel *settingBeaconLbl
    = [[UILabel alloc] initWithFrame:CGRectMake(kJVFieldMargin, div3.frame.origin.y + div3.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight)];
    settingBeaconLbl.textColor = [UIColor darkGrayColor];
    settingBeaconLbl.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    settingBeaconLbl.text = @"クリア判定をするビーコン";
    [self.beaconQuestContentView addSubview:settingBeaconLbl];
    
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
    [self.beaconQuestContentView addSubview:self.beaconSettingBtn];
    
    UIView *div4 = [UIView new];
    div4.frame = CGRectMake(kJVFieldMargin, self.beaconSettingBtn.frame.origin.y + self.beaconSettingBtn.frame.size.height+5, self.view.frame.size.width - 2*kJVFieldMargin, 1.0f);
    div4.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.beaconQuestContentView addSubview:div4];
    
    //segment - questType
    
    //誰に配信する？
    UILabel *targetUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(kJVFieldMargin, div4.frame.origin.y + div4.frame.size.height, self.view.frame.size.width -2*kJVFieldMargin, kJVFieldHeight)];
    targetUserLabel.textColor = [UIColor darkGrayColor];
    targetUserLabel.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    targetUserLabel.text = @"誰に配信する？";
    [self.beaconQuestContentView addSubview:targetUserLabel];
    
    //targetSegmentedControl
    self.targetSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"みんな",@"特定のメンバー"]];
    self.targetSegmentedControl.frame = CGRectMake(kJVFieldMargin, targetUserLabel.frame.origin.y + targetUserLabel.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, self.targetSegmentedControl.frame.size.height);
    [self.targetSegmentedControl addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    [self.beaconQuestContentView addSubview:self.targetSegmentedControl];
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
    [self.beaconQuestContentView addSubview:self.targetUserBtn];
    self.targetUserBtn.hidden = YES;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.beaconQuestContentView.frame.size.height);
    [self.scrollView addSubview:self.beaconQuestContentView];
    
}

- (void)setUserQuestCreateUI
{
    UIColor *floatingLabelColor = [UIColor brownColor];
    
    self.userQuestContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    //title
    self.titleField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(kJVFieldMargin, 0, self.view.frame.size.width -2 * kJVFieldMargin, kJVFieldHeight)];
    self.titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"タイトル" attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    self.titleField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.titleField.floatingLabelTextColor = floatingLabelColor;
    self.titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.titleField.delegate = self;
    [self.userQuestContentView addSubview:self.titleField];
    self.titleField.returnKeyType = UIReturnKeyDone;
    UIView *div1 = [UIView new];
    div1.frame = CGRectMake(kJVFieldMargin, self.titleField.frame.origin.y + self.titleField.frame.size.height, self.view.frame.size.width -2 * kJVFieldMargin, 1.0f);
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.userQuestContentView addSubview:div1];
    
    //詳細
    self.descriptionView = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(kJVFieldMargin, div1.frame.origin.y + div1.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, kJVFieldHeight*2)];
    self.descriptionView.placeholder = @"クエスト詳細";
    self.descriptionView.placeholderTextColor = [UIColor darkGrayColor];
    self.descriptionView.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.descriptionView.floatingLabelTextColor = floatingLabelColor;
    self.descriptionView.floatingLabelFont = [UIFont systemFontOfSize:kJVFieldFontSize];
    self.descriptionView.delegate = self;
    self.descriptionView.returnKeyType = UIReturnKeyDone;
    [self.userQuestContentView addSubview:self.descriptionView];
    
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
    
    UIView *div2 = [UIView new];
    div2.frame = CGRectMake(kJVFieldMargin, self.descriptionView.frame.origin.y + self.descriptionView.frame.size.height, self.view.frame.size.width - 2*kJVFieldMargin, 1.0f);
    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.userQuestContentView addSubview:div2];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.userQuestContentView.frame.size.height);
    [self.scrollView addSubview:self.userQuestContentView];
}

- (void)changeCreateUI
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self.userQuestContentView removeFromSuperview];
            [self setBeaconQuestCreateUI];
            break;
            
        case 1:
            [self.beaconQuestContentView removeFromSuperview];
            [self setUserQuestCreateUI];
            break;
            
        default:
            break;
    }
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
    
    //beaconタイプなら
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
        if (self.selectedBeaconObj == nil) {
            CWStatusBarNotification *notis = [CWStatusBarNotification new];
            notis.notificationLabelBackgroundColor = [UIColor redColor];
            [notis displayNotificationWithMessage:@"クリア判定用のビーコンを指定して下さい" forDuration:2.0f];
            return;
        }
        
        if (self.targetTypeIndex == kTARGET_USER_SPECIFIC) {
            
            if (self.targetUsers.count == 0) {
                CWStatusBarNotification *notis = [CWStatusBarNotification new];
                notis.notificationLabelBackgroundColor = [UIColor redColor];
                [notis displayNotificationWithMessage:@"配信先のユーザを指定して下さい" forDuration:2.0f];
                return;
            }
        }

    }
    
    KiiServerCodeEntry *entry;
    NSDictionary *argDict;

    //動かすサーバーコードと一緒に渡すParamsを設定
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        //ベーコンクエスト
        entry = [self setServerCodeForBeaconQuest];
        argDict = [self setParamsForBeaconQuest];
    } else {
        //userクエストr
        [self createUserQuest];
        return;
    }
    
    KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
    NSError *error;
    KiiServerCodeExecResult *result = [entry executeSynchronous:argument withError:&error];
    
    //Perse the result.
    if (error) {
        CWStatusBarNotification *successNotis = [CWStatusBarNotification new];
        successNotis.notificationLabelBackgroundColor = [UIColor redColor];
        [successNotis displayNotificationWithMessage:@"通信エラー" forDuration:2.0f];
        return;
    }
    
    NSDictionary *returnedDict = [result returnedValue];
    NSString *returnString = [returnedDict objectForKey:@"returnedValue"];
    NSLog(@"%@",returnString);
    CWStatusBarNotification *successNotis = [CWStatusBarNotification new];
    successNotis.notificationLabelBackgroundColor = [UIColor turquoiseColor];
    [successNotis displayNotificationWithMessage:@"クエストを配信しました!" forDuration:2.0f];
    
    //Topicへ
    if (self.targetTypeIndex == kTARGET_USER_ALL) {
        [[GXTopicManager sharedManager] sendCreateQuestAlert:[KiiUser currentUser].displayName]; //みんなにSendingAlertTopicへmsg送信で知らせる
    } else {
        //sendAlert
        [[GXTopicManager sharedManager] sendAlertForSpecificUser:self.targetUsers]; //これみんなに配信した場合はこないよ ..servercodeで直接newquestInfoに
    }
    
    //pointゲット
    [[GXPointManager sharedInstance] getCreateQuestPoint];
    
    //action
    [[GXActionAnalyzer sharedInstance] setActionName:GXQuestCreate];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (KiiServerCodeEntry *)setServerCodeForBeaconQuest
{
    KiiServerCodeEntry *entry;
    switch (self.targetTypeIndex) {
        case kTARGET_USER_ALL:
            //all
            entry = [Kii serverCodeEntry:@"deliverAllMember"];
            break;
        case kTARGET_USER_SPECIFIC:
            //specific
            entry = [Kii serverCodeEntry:@"deliverSpecific"];
            break;
            
        default:
         break;
    }
    
    return entry;
}

- (NSDictionary *)setParamsForBeaconQuest
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    //クエスト状況
    KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
    NSLog(@"%@",gxUser);
    NSString *questTitle = self.titleField.text;
    NSString *questDescription = self.descriptionView.text;
    
    NSNumber *tMajor = [self.selectedBeaconObj getObjectForKey:@"user_major"];
    NSLog(@"tMajor:%ld",[tMajor integerValue]);
    
    NSString *tMajorOwnerFBID = [self.selectedBeaconObj getObjectForKey:user_fb_id];
    
    //作成ユーザー情報
    NSString *userName = [gxUser getObjectForKey:user_name];
    NSString *userFBID = [gxUser getObjectForKey:user_fb_id];
    NSMutableArray *targetURIs = [NSMutableArray new];
    
    //配信先情報
    //特定のuserだったらURIだけパックにして送信
    if (self.targetTypeIndex == kTARGET_USER_SPECIFIC) {
        for (KiiObject *user in self.targetUsers) {
            NSString *targetURI = user.objectURI;
            [targetURIs addObject:targetURI];
        }
    }

    NSDictionary *argDict = @{@"questType":[NSNumber numberWithInteger:self.quesytTypeIndex],
                              @"questTitle":questTitle,
                              @"questDescription":questDescription,
                              @"tMajor":tMajor,
                              @"tMajorOwnerFBID":tMajorOwnerFBID,
                              @"createrName":userName,
                              @"createrFBID":userFBID,
                              @"targetURIs":targetURIs};
    
    NSLog(@"argDict:%@",argDict);
    
    return argDict;

}

- (void)createUserQuest
{
    KiiObject *newObj = [KiiObject new];
    [newObj setObject:self.titleField.text forKey:quest_title];
    [newObj setObject:self.descriptionView.text forKey:quest_description];
    [newObj setObject:@NO forKey:quest_isCompleted];
    [newObj setObject:@NO forKey:quest_isStarted];
    [newObj setObject:[NSNumber numberWithInt:2] forKey:quest_player_num];
    [newObj setObject:@"クリア条件：リーダーがクリアボタンを押す" forKey:@"requirement"];
    [newObj setObject:[NSNumber numberWithInt:100] forKey:quest_reward];
    [newObj setObject:[NSNumber numberWithInt:0] forKey:quest_success_cnt];
    
    //ユーザに紐付いたビーコンを取ってくる
    KiiObject *gxUser = [GXUserManager sharedManager].gxUser;
    NSNumber *user_major = [gxUser getObjectForKey:@"user_major"];
    [newObj setObject:@"user" forKey:quest_type];
    [newObj setObject:user_major forKey:@"major"]; //対象
    [[GXBucketManager sharedManager] registerInviteBoard:newObj];

    //activityに登録
    NSString *name = [gxUser getObjectForKey:user_name];
    NSString *fbid = [gxUser getObjectForKey:user_fb_id];
    NSString *text = [NSString stringWithFormat:@"%@クエストを作成しました",self.titleField.text];
    [[GXActivityList sharedInstance] registerQuestActivity:name title:text fbid:fbid];

    //みんなに伝える
    NSString *createdUserName = [gxUser getObjectForKey:@"name"];
    [[GXTopicManager sharedManager] sendInviteQuestAlert:createdUserName]; //新しい募集をpushで知らせる (ユーザクエの場合は募集が前提)
    
    //pointゲット
    [[GXPointManager sharedInstance] getCreateQuestPoint];
    [[GXActionAnalyzer sharedInstance] setActionName:GXQuestCreate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segument
- (void)selectedSegment:(UISegmentedControl *)sender
{
    [self changeCreateUI];
}

#pragma  mark SegmentChang -
- (void)segmentedChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case kTARGET_USER_ALL:
            self.targetTypeIndex = kTARGET_USER_ALL;
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

#pragma mark Notificaiton
- (void)beaconSet:(NSNotification *)notis
{
    self.selectedBeaconObj = notis.object;
    [self.beaconSettingBtn setTitle:[self.selectedBeaconObj getObjectForKey:@"name"] forState:UIControlStateNormal];
    [self.beaconSettingBtn setTitle:[self.selectedBeaconObj getObjectForKey:@"name"] forState:UIControlStateHighlighted];
}

- (void)targetUserSet:(NSNotification *)notis
{
    NSLog(@"targetusers:%ld",self.targetUsers.count);
    NSMutableArray *targetUsers = notis.object;
    
    //なにも設定されてないならデフォルトにもどす
    if (targetUsers == nil) {
        self.targetUsers = [NSMutableArray arrayWithArray:targetUsers];
        [self.targetUserBtn setTitle:@"Who?" forState:UIControlStateNormal];
        [self.targetUserBtn setTitle:@"Who?" forState:UIControlStateHighlighted];
    } else {
        self.targetUsers = [NSMutableArray arrayWithArray:targetUsers];
        [self.targetUserBtn setTitle:@"設定完了" forState:UIControlStateNormal];
        [self.targetUserBtn setTitle:@"設定完了" forState:UIControlStateHighlighted];
    }
    
    NSLog(@"targets.count:%ld",self.targetUsers.count);

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"getMember"]) {
        GXOnlineMemberTableViewController *vc = segue.destinationViewController;
        vc.index = self.selectedButtonIndex;
    }
}

@end
