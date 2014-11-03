//
//  GXExeQuestManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/03.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXExeQuestManager.h"
#import "GXDictonaryKeys.h"

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

- (void)startExeQuest
{
    [self.exeQuest refreshWithBlock:^(KiiObject *object, NSError *error) {
        [object setObject:@YES forKey:quest_isStarted];
        [object saveWithBlock:^(KiiObject *object, NSError *error) {
            if (error) {
                NSLog(@"error:%@",error);
            } else {
                
            }
        }];
    }];
}

- (void)completeQuest
{
    [self.exeQuest refreshWithBlock:^(KiiObject *object, NSError *error) {
        [object setObject:@YES forKey:quest_isCompleted];
        [object saveWithBlock:^(KiiObject *object, NSError *error) {
            if (error) {
                NSLog(@"error:%@",error);
            } else {
                
            }
        }];
    }];
}

@end
