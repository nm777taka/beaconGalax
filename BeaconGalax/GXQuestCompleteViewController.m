//
//  GXQuestCompleteViewController.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/18.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestCompleteViewController.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"

@interface GXQuestCompleteViewController ()
@property (weak, nonatomic) IBOutlet FUIButton *clearButton;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation GXQuestCompleteViewController{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.89];
    
    _clearButton.buttonColor = [UIColor alizarinColor];
    _clearButton.shadowColor = [UIColor pomegranateColor];
    _clearButton.shadowHeight = 3.0f;
    _clearButton.cornerRadius = 6.0f;
    _clearButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [_clearButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [_clearButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [_clearButton bk_addEventHandler:^(id sender) {
        //とりあえず押したらクリア
        //clear_cnt = 1
        //success を１に更新
        //cler_cnt == successでクリア
        [self commitQuest];
    } forControlEvents:UIControlEventTouchUpInside];
    
    //notificaiton
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endQuestHandler:) name:GXEndQuestNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"quest_complete:%@",self.completeQuest);
    self.descriptionLabel.text = [self.completeQuest getObjectForKey:quest_title];
    [self.animationView startCanvasAnimation];
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

- (void)commitQuest
{
    NSError *error;
    KiiBucket *bucket = [self.questGroup bucketWithName:@"quest"];
    KiiQuery *query = [KiiQuery queryWithClause:nil];
    KiiQuery *nextQuery;
    NSArray *result = [bucket executeQuerySynchronous:query withError:&error andNext:&nextQuery];
    KiiObject *quest = result.firstObject;
    
    int succCnt = [[quest getObjectForKey:quest_success_cnt] intValue];
    succCnt++;
    NSNumber *newValue  = [NSNumber numberWithInt:succCnt];
    [quest setObject:newValue forKey:quest_success_cnt];
    [quest saveSynchronous:&error];
    if (!error) {
        //クリア判定
        NSNumber *clearCnt = [quest getObjectForKey:quest_clear_cnt];
        NSNumber *succCnt = [quest getObjectForKey:quest_success_cnt];
        if ([clearCnt isEqualToNumber:succCnt]) {
            //クリア
            //なにかしらアラート
            NSLog(@"クリア");
            //pushおくってみんなで画面遷移
            [SVProgressHUD showWithStatus:@"クリア判定中"];
            [self sendClearPush];
            
        }
    }
}

- (void)sendClearPush
{
    NSError *error;
    KiiTopic *clearTopic = [self.questGroup topicWithName:@"quest_end"];
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    KiiPushMessage *msg = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
    [clearTopic sendMessageSynchronous:msg withError:&error];
    if (error) {
        NSLog(@"sendPushError:%@",error);
        [SVProgressHUD showErrorWithStatus:@"push通知送信エラー"];
    } else {
        NSLog(@"クリアpush送信完了");
        [NSTimer bk_scheduledTimerWithTimeInterval:3.0 block:^(NSTimer *timer) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [SVProgressHUD dismiss];
        } repeats:NO];
    }
}

#pragma mark - Notification
- (void)endQuestHandler:(NSNotification *)info
{
    //クエストクリア
}

@end
