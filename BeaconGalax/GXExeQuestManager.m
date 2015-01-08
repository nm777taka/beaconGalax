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
    BOOL isMulti;
    BOOL isUserType = false;
    
    NSString *curretUserID = [KiiUser currentUser].uuid;
    KiiBucket *bucket = [GXBucketManager sharedManager].clearedBucket;
    KiiObject *obj = [bucket createObject];
    NSDictionary *dict = self.nowExeQuest.dictionaryValue;
    NSString *questType = dict[@"type"];
    
    if ([questType isEqualToString:@"user"]) {
        isUserType = YES;
    } else {
    }
    
    int players = [dict[@"player_num"]intValue];
    
    if (players > 1) {
        isMulti = YES;
    } else {
        isMulti = NO;
    }
    
    NSArray *keys = dict.allKeys;
    for (NSString *key in keys) {
        [obj setObject:dict[key] forKey:key];
    }
    
    //cleardに保存
    [obj saveWithBlock:^(KiiObject *object, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        } else {
            //完了したクエストを元バケットから消す
            //クエストが属しているBucketから消える
            //消すんじゃなくて、isCompleted = yesにする
            
//            [self.nowExeQuest deleteWithBlock:^(KiiObject *object, NSError *error) {
//                if (error) {
//                    NSLog(@"error:%@",error);
//                } else {
//                    
//                }
//            }];
            
            [self.nowExeQuest setObject:@YES forKey:quest_isCompleted];
            [self.nowExeQuest saveWithBlock:^(KiiObject *object, NSError *error) {
                
            }];
            
            //system(デイリーの場合、joinedからだけでなく、ソースになっているnotJoinからの消す
//            [self.nowExeParentQuest deleteWithBlock:^(KiiObject *object, NSError *error) {
//                
//            }];
            [self.nowExeParentQuest deleteWithBlock:^(KiiObject *object, NSError *error) {
                //
            }];
        }
    }];
    
    //appscopeに保存しとく
//    if (isMulti) {
//        if (isUserType) {
//            KiiBucket *bucket = [Kii bucketWithName:@"cleard_UserQuest"];
//            KiiObject *obj = [bucket createObject];
//            for (NSString *key in keys) {
//                [obj setObject:dict[key] forKey:key];
//            }
//            [obj setObject:curretUserID forKey:@"userUUID"];
//            [obj saveWithBlock:^(KiiObject *object, NSError *error) {
//                if (!error) {
//                    NSLog(@"userQuest-APPに保存");
//                }
//            }];
//
//        } else {
//            KiiBucket *bucket = [Kii bucketWithName:@"cleard_MultiQuest"];
//            KiiObject *obj = [bucket createObject];
//            
//            for (NSString *key in keys) {
//                [obj setObject:dict[key] forKey:key];
//            }
//            [obj setObject:curretUserID forKey:@"userUUID"];
//            [obj saveWithBlock:^(KiiObject *object, NSError *error) {
//                if (!error) {
//                    NSLog(@"MultiQuest-APPに保存");
//                }
//            }];
//        }
//        
//    } else {
//        KiiBucket *bucket = [Kii bucketWithName:@"cleard_OneQuest"];
//        KiiObject *obj = [bucket createObject];
//        for (NSString *key in keys) {
//            [obj setObject:dict[key] forKey:key];
//        }
//        [obj saveWithBlock:^(KiiObject *object, NSError *error) {
//            if (!error) {
//                NSLog(@"oneQuest-APPに保存");
//            }
//        }];
//    }
}


@end
