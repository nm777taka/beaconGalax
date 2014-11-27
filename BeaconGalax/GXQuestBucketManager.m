//
//  GXQuestBucketManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestBucketManager.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"

@implementation GXQuestBucketManager

+ (instancetype)sharedInstance
{
    static GXQuestBucketManager *sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXQuestBucketManager alloc] initSharedSingleton];
    });
    
    return sharedSingleton;
}

- (id)initSharedSingleton
{
    self = [super init];
    if (self) {
        //init
    }
    
    return self;
}

#pragma mark API
//一人用クエストを受注した場合に呼ばれる
- (void)requestJoinNewQuest:(GXQuest *)quest
{
    //idをもとにbucket内のobjectを再構成
    KiiObject *questObj = [KiiObject objectWithURI:quest.quest_id];
    [questObj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (object) {
            KiiBucket *bucket = [GXBucketManager sharedManager].joinedQuest;
            [self convertObject:questObj toBucket:bucket];
        }
    }];
    
}

//協力用クエストを募集する際に呼ばれる
- (void)requestInviteNewQuest:(GXQuest *)quest
{
    KiiObject *questObj = [KiiObject objectWithURI:quest.quest_id];
    [questObj refreshWithBlock:^(KiiObject *object, NSError *error) {
        if (object) {
            KiiBucket *inviteBucket = [GXBucketManager sharedManager].inviteBoard;
            //[self convertObject:object toBucket:inviteBucket];
        }
    }];
}

#pragma mark - Internal

- (void)convertObject:(KiiObject *)convertObj toBucket:(KiiBucket *)toBucket
{
    NSDictionary *dict = convertObj.dictionaryValue;
    NSLog(@"dict:%@",dict);
    NSArray *allKeys = dict.allKeys;
    KiiObject *newObj = toBucket.createObject;
    for (NSString *key in allKeys) {
        [newObj setObject:dict[key] forKey:key];
    }
    
    [newObj saveWithBlock:^(KiiObject *object, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            NSLog(@"コンバート完了");
            //なんかする
            //delegateとか
            //コンバートしたobjはいらないので削除する
        }
    }];
}




@end
