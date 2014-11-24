//
//  GXQuestBucketManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>
#import "GXQuest.h"

@interface GXQuestBucketManager : NSObject

+ (instancetype)sharedInstance;

//API
//新しいクエストに参加(一人用)
- (void)requestJoinNewQuest:(GXQuest *)quest;

//新しいクエストを募集する
- (void)requestInviteNewQuest:(GXQuest *)quest;

@end
