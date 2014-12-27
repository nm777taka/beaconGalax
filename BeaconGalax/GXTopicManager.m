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
        self.questInviteTopic = [Kii topicWithName:GXQuestInviteTopic];
        self.sendingAlertTopic = [Kii topicWithName:@"SendingAlert"];
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

- (void)subscribeInfoTopic
{
    NSError *error;
    self.infoTopic = [[KiiUser currentUser] topicWithName:@"newQuestInfo"];
    [self.infoTopic saveSynchronous:&error];
    
    BOOL isSubscribe = [KiiPushSubscription checkSubscriptionSynchronous:self.infoTopic withError:&error];
    if (!isSubscribe) {
        
        [KiiPushSubscription subscribe:self.infoTopic withBlock:^(KiiPushSubscription *subscription, NSError *error) {
            if (error) {
                NSLog(@"subscribeTopicError:%@",error);
            } else {
                NSLog(@"infoトピック購読");
            }
        }];

    } else {
        NSLog(@"すでにinfoTopicを購読してます");
    }
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

#pragma mark - Send Message
- (void)sendCreateQuestAlert:(NSString *)createdUserName
{
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    NSString *body = [NSString stringWithFormat:@"%@が新しいクエストを作成しました！",createdUserName];
    
    apnsFields.alertBody = body;
    apnsFields.badge = @1;
    
    KiiPushMessage *pushMessage = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
    
    [self.sendingAlertTopic sendMessage:pushMessage withBlock:^(KiiTopic *topic, NSError *error) {
        if (error) {
        } else {
        }
    }];
}

- (void)sendInviteQuestAlert:(NSString *)createdUserName
{
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    NSString *body = [NSString stringWithFormat:@"%@がクエストの参加者を募集しています！",createdUserName];
    
    apnsFields.alertBody = body;
    apnsFields.badge = @1;
    
    KiiPushMessage *pushMessage = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
    
    [self.sendingAlertTopic sendMessage:pushMessage withBlock:^(KiiTopic *topic, NSError *error) {
        if (error) {
        } else {
        }
    }];
}

- (void)sendUserInfoTopic:(NSString *)msg
{
    KiiAPNSFields *apnsFields = [KiiAPNSFields createFields];
    NSString *body = msg;
    
    apnsFields.alertBody = body;
    apnsFields.badge = @1;
    
    KiiPushMessage *pushMessage = [KiiPushMessage composeMessageWithAPNSFields:apnsFields andGCMFields:nil];
    [self.infoTopic sendMessage:pushMessage withBlock:^(KiiTopic *topic, NSError *error) {
        if (error) {
            NSLog(@"sendError:%@",error);
        } else {
            NSLog(@"send to infoTopic");
        }
    }];
}

- (void)sendAlertForSpecificUser:(NSMutableArray *)targetUsers
{
    if (targetUsers.count == 0) {
        
    } else {
        
        NSMutableArray *array = [NSMutableArray new];
        for (KiiObject *user in targetUsers) {
            NSString *userID = [user getObjectForKey:@"userID"];
            [array addObject:userID];
        }
        
        KiiServerCodeEntry *entry = [Kii serverCodeEntry:@"sendAlert"];
        NSDictionary *argDict = @{@"users":array};
        KiiServerCodeEntryArgument *argument = [KiiServerCodeEntryArgument argumentWithDictionary:argDict];
        [entry execute:argument withBlock:^(KiiServerCodeEntry *entry, KiiServerCodeEntryArgument *argument, KiiServerCodeExecResult *result, NSError *error) {
            NSDictionary *retDict = [result returnedValue];
            NSLog(@"retDict:%@",retDict);
        }];
    }
}


@end