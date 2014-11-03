//
//  GXExeQuestManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/03.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>


@interface GXExeQuestManager : NSObject

@property (nonatomic) KiiObject *exeQuest;

+ (GXExeQuestManager *)sharedManager;

- (void)startExeQuest;
- (void)completeQuest;


@end
