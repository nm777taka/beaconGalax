//
//  GXTopicManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/30.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXTopicManager.h"
#import "GXDictonaryKeys.h"

static NSString *const GXInfoTopic = @"GXInfoTopic";
static NSString *const GXQuestInviteTopic = @"GXQuestInviteTopic";

@implementation GXTopicManager

+ (GXTopicManager *)sharedManager
{
    
    static GXTopicManager *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXTopicManager alloc] initSharedInstance];
        
    });
    
    return sharedSingleton;
}

- (id)initSharedInstance
{
    self = [super init];
    
    if (self) {
        self.infoTopic = [Kii topicWithName:GXInfoTopic];
        self.questInviteTopic = [Kii topicWithName:GXQuestInviteTopic];
    }
    
    return self;
}

//AppScopeに

//サインアップ時に作られる
//アクセスはだれでも可能な招待用トピック
- (void)createDefaultUserTopic
{
    
    NSError *error = nil;
    KiiUser *user = [KiiUser currentUser];
    KiiTopic *topic = [user topicWithName:topic_invite];
    
    BOOL isSubscribed = [KiiPushSubscription checkSubscriptionSynchronous:topic withError:&error];
    ;
    
    if (!isSubscribed) {
        //全ユーザから各ユーザの招待トピックにメッセージを送信可能にする
        
        [topic saveSynchronous:&error];
        
        KiiPushSubscription *subscription = [KiiPushSubscription subscribeSynchronous:topic withError:&error];
        if (error == nil) {
            NSLog(@"購読の成功:%@",topic);
        } else {
            NSLog(@"購読の失敗:%@",topic);
        }
    } else {
        NSLog(@"すでに購読されています");
    }
    
}

- (void)subscribeTopic
{
//   [KiiPushSubscription subscribe:self.infoTopic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
//       if (error) {
//           NSLog(@"subscribeTopicError:%@",error);
//       } else {
//           NSLog(@"infoトピック購読");
//       }
//   }];
//    
//    [KiiPushSubscription subscribe:self.questInviteTopic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
//        if (error) {
//            NSLog(@"subscribeTopicError:%@",error);
//        } else {
//            NSLog(@"questInviteトピック購読");
//        }
//    }];
    
    //AppScopeのTopicは管理者しか作れない
    
}

- (void)createUserTopic:(NSString *)title
{
}

- (void)setACL
{
    NSError *error = nil;
    KiiUser *user = [KiiUser currentUser];
    KiiTopic *topic = [user topicWithName:topic_invite];
    KiiACL *acl = [topic topicACL];
    KiiAnyAuthenticatedUser *authenticatedUser = [KiiAnyAuthenticatedUser aclSubject];
    KiiACLEntry *entry1 = [KiiACLEntry entryWithSubject:authenticatedUser andAction:KiiACLTopicActionSubscribe];
    
    [acl putACLEntry:entry1];
    KiiACLEntry *entry2 = [KiiACLEntry entryWithSubject:authenticatedUser andAction:KiiACLTopicActionSend];
    [acl putACLEntry:entry2];
    
    //acl保存
    NSArray *succeeded,*failed;
    [acl saveSynchronous:&error didSucceed:&succeeded didFail:&failed];
    if (error == nil) {
        NSLog(@"aclの設定が完了しました");
    } else {
        NSLog(@"save acl error : %@",error);
    }
 
}


@end