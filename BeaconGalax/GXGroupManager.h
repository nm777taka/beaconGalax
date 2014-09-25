//
//  GXGroupManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>

@interface GXGroupManager : NSObject

+ (GXGroupManager *)sharedManager;

- (void)getQuestMember:(KiiObject *)quest;


@end
