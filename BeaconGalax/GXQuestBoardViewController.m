#import "GXQuestBoardViewController.h"
#import "GXTableViewConst.h"
#import "GXCollectionViewCell.h"
#import "GXBucketManager.h"
#import "GXNotification.h"
#import "GXQuestDetialViewController.h"
#import "FUIAlertView+GXAlertView.h"
#import "GXDictonaryKeys.h"

@interface GXQuestBoardViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *questCollectionView;
@property  NSMutableArray *questArray;

@property GXQuestDetialViewController *detailViewController;

@property NSIndexPath *joinButtonIndexPath;

@end

#define FUIAlertButtonIndex_JOIN 1
#define FUIAlertButtonIndex_CANCEL 0

@implementation GXQuestBoardViewController

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
    
    self.questCollectionView.delegate = self;
    self.questCollectionView.dataSource = self;
    
    self.questArray = [NSMutableArray new];
    
//    //QuestCreateButton init
//    FUIButton *questCreateButton = [[FUIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 100, self.view.frame.size.height - 150 , 200, 50)];
//    questCreateButton.buttonColor = [UIColor sunflowerColor];
//    questCreateButton.shadowColor = [UIColor orangeColor];
//    questCreateButton.shadowHeight = 3.0f;
//    questCreateButton.cornerRadius = 6.0f;
//    questCreateButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
//    [questCreateButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
//    [questCreateButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
//    [questCreateButton setTitle:@"Create"forState:UIControlStateNormal];
//    [questCreateButton bk_addEventHandler:^(id sender){
//        //handler
//        //画面遷移
//        [self performSegueWithIdentifier:@"GoToQuestCreateView" sender:self];
//        
//        
//    } forControlEvents:UIControlEventTouchUpInside];
//    
//    //TableViewの上に出す
//    [self.view insertSubview:questCreateButton aboveSubview:self.view];
    
    
    //CollectionView
    //self.questCollectionView.backgroundColor = [UIColor cloudsColor];
    
    //notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gxQuestFetchedHandler:) name:GXFetchQuestNotComplitedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gxQuestDeletedHandler:) name:GXQuestDeletedNotification object:nil];
    
    //指定バケットのデータをすべて削除
    KiiBucket *bucket = [GXBucketManager sharedManager].joinedQuest;
    ///[[GXBucketManager sharedManager] deleteAllObject:bucket];
    [[GXBucketManager sharedManager] displayAllObject:bucket];
    
}

#pragma mark - Todo :毎回フェッチするんじゃなくて、変更があった場合のみにしたい
- (void)viewWillAppear:(BOOL)animated
{
    [self fetchQuest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchQuest
{

    self.questArray = [[GXBucketManager sharedManager] fetchQuestWithNotComplited];
 
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - CollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.questArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    GXCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    
    return cell;
    
}

#pragma mark CollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    //notificationで選択されたセルのデータを飛ばす
//    //詳細画面表示
//    if (self.detailViewController == nil) {
//        self.detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestDetailView"];
//        
//    }
//    self.detailViewController.quest = self.questArray[indexPath.row];
//    self.detailViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    [self.view addSubview:self.detailViewController.view];
    
}

#pragma mark ConfigureCell
- (void)configureCell:(GXCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 5.0f;
    cell.layer.shadowPath = [[UIBezierPath bezierPathWithRect:cell.bounds] CGPath];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.backgroundColor = [UIColor cloudsColor];
    
    KiiObject *quest = self.questArray[indexPath.row];
    cell.questNameLabel.text = [quest getObjectForKey:@"title"];
    cell.fbIConView.profileID = [quest getObjectForKey:@"facebook_id"];
    
    [cell.joinButton addTarget:self action:@selector(joinButtonTouch:event:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - ボタンアクション
- (void)joinButtonTouch:(UIButton *)sender event:(UIEvent *)event
{
    //どのセルのjoinボタンが押されたら取得
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point  = [touch locationInView:self.questCollectionView];
    self.joinButtonIndexPath = [self.questCollectionView indexPathForItemAtPoint:point];
    
    KiiObject *obj = self.questArray[self.joinButtonIndexPath.row];
    NSString *createdUser = [obj getObjectForKey:@"created_user_uri"];
    
    
    do {
        
        if ([createdUser isEqualToString:[KiiUser currentUser].objectURI]) {
            //なにもしない
            NSLog(@"クエスト作成者です");
            [TSMessage showNotificationWithTitle:@"ERROR"
                                        subtitle:@"クエスト作成者です"
                                            type:TSMessageNotificationTypeError];
            break;
        }
        
        KiiObject *obj = self.questArray[self.joinButtonIndexPath.row];
        NSString *questTitle = [obj getObjectForKey:@"title"];
        NSLog(@"取得したタイトル:%@",questTitle);
        
        //このタイトルをクエリに自分のバケットからデータを探す処理
        if ([[GXBucketManager sharedManager] isJoinedQuest:questTitle]) {
            
            //既に参加済みの同じクエストがある
            [TSMessage showNotificationWithTitle:@"ERROR"
                                        subtitle:@"既に参加済みの同じクエストがあります"
                                            type:TSMessageNotificationTypeError];
            break;
        }
        
        FUIAlertView *alert = [[FUIAlertView alloc] initWithTitle:@"確認" message:@"このクエストに参加しますか？" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"参加", nil];
        [FUIAlertView gxQuestTheme:alert];
        [alert show];
        
        
    }while(false);
    
    
}

#pragma mark GXNotificationHandler
- (void)gxQuestFetchedHandler:(GXNotification *)info
{
    
    [self.questCollectionView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)gxQuestDeletedHandler:(GXNotification *)info
{
    [self fetchQuest];
}

#pragma mark - FUIAlertViewDelegate
#pragma mark - Todo ここで既に参加済みの同じクエストがあった場合の処理
- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //選択したクエストを自分のバケットに登録
    if (buttonIndex == 1) {
        NSError *error = nil;
        //クエストオブジェクトを取得
        KiiObject *selectedQuest= self.questArray[self.joinButtonIndexPath.row];
        NSString *createUserURI = [selectedQuest getObjectForKey:quest_createUserURI];
        NSLog(@"%@",createUserURI);
        KiiUser *createUser = [KiiUser userWithURI:createUserURI];
        NSLog(@"createUser:%@",createUser);
        
        //ユーザスコープのバケットを取得
        KiiBucket *joinedQuestBucket = [GXBucketManager sharedManager].joinedQuest;
        
        //コピー
        KiiObject *newObj = [joinedQuestBucket createObject];
        [newObj setObject:[selectedQuest getObjectForKey:quest_title] forKey:quest_title];
        [newObj setObject:[selectedQuest getObjectForKey:quest_description] forKey:quest_description];
        [newObj setObject:[selectedQuest getObjectForKey:quest_createdUser_fbid] forKey:quest_createdUser_fbid];
        [newObj setObject:[selectedQuest getObjectForKey:quest_createUserURI] forKey:quest_createUserURI];
        [newObj setObject:[selectedQuest getObjectForKey:quest_groupURI] forKey:quest_groupURI];
        [newObj setObject:[selectedQuest getObjectForKey:quest_isCompleted] forKey:quest_isCompleted];
        [newObj setObject:[selectedQuest getObjectForKey:quest_isStarted] forKey:quest_isStarted];
        
        [newObj saveSynchronous:&error];
        
        if (error) {
            NSLog(@"%s",__PRETTY_FUNCTION__);
            NSLog(@"error : %@",error);
        } else {
            NSLog(@"ユーザバケットへ登録が完了");
            NSLog(@"%s",__PRETTY_FUNCTION__);
            [TSMessage showNotificationWithTitle:@"クエストに参加しました"
                                            type:TSMessageNotificationTypeMessage];
            
            [[GXBucketManager sharedManager] displayAllObject:joinedQuestBucket];
        }
        
        //作成者のinvite_notifyトピックに
        //参加したことを通知する
        [self sendPushNotification:createUser];
        
    }
    
}

#pragma mark - Push通知
- (void)sendPushNotification:(KiiUser *)user
{
    NSError *error = nil;
    
    NSString *topicname = topic_invite;
    KiiTopic *topic = [user topicWithName:topicname];
    
    // Create APNs message fields
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    
    // so the AlertBody is not set.
    //[apnsFields setAlertBody:@"Show message"];
    
    // Build a push message.
    // GCM fields is set nil, so the message will not send to Android devices
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    KiiUser *joinedUser = [KiiUser currentUser];
    [dictionary setValue:joinedUser forKey:@"joined_user"];
    [apnsFields setSpecificData:dictionary];
    
    // Enable the silent push notification by setting "content-available"
    //[apnsFields setContentAvailable:@1];
    
    KiiPushMessage *message = [KiiPushMessage composeMessageWithAPNSFields:apnsFields
                                                              andGCMFields:nil];
    
    // Send the push message.
    [topic sendMessageSynchronous:message
                        withError:&error];
    if (error != nil) {
        // There was a problem.
        NSLog(@"error:%@",error);
    } else {
        NSLog(@"push通知送信");
    }
}

@end
