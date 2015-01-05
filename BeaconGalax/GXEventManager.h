//
//  GXEventManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/06.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXEventManager : NSObject

+ (instancetype)sharedInstance;

- (void)currentEventCommit;

- (void)registerCommiterUser:(BOOL)isOwner type:(NSString *)cleardType;


- (void)registerSystemQuestCleard;

@end
