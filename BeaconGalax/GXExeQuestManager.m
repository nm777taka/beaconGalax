//
//  GXExeQuestManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/03.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXExeQuestManager.h"
#import "GXDictonaryKeys.h"
#import "GXBucketManager.h"

@implementation GXExeQuestManager

+ (GXExeQuestManager *)sharedManager
{
    static GXExeQuestManager *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXExeQuestManager alloc] initSharedInstance];
    });
    
    return sharedSingleton;
}

- (id)initSharedInstance
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

- (void)startQuestAtInvitedBucket:(KiiObject *)obj
{
    [obj refreshWithBlock:^(KiiObject *object, NSError *error) {
        [object setObject:@YES forKey:quest_isStarted];
        [object saveWithBlock:^(KiiObject *object, NSError *error) {
            if (error) {
                NSLog(@"error:%@",error);
            } else {
            
            }
        }];
    }];
}

- (void)clearNowExeQuest
{
    //clearBucketに保存
    //保存できたら消す
    
    KiiBucket *bucket = [GXBucketManager sharedManager].clearedBucket;
    KiiObject *obj = [bucket createObject];
    NSDictionary *dict = self.nowExeQuest.dictionaryValue;
    NSArray *keys = dict.allKeys;
    for (NSString *key in keys) {
        [obj setObject:dict[key] forKey:key];
    }
    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            //完了したクエストを元バケットから消す
            //クエストが属しているBucketから消える
            [self.nowExeQuest deleteWithBlock:^(KiiObject *object, NSError *error) {
                if (error) {
                    NSLog(@"error:%@",error);
                } else {
                    
                }
            }];
        }
    }];
    
    
    
}


@end