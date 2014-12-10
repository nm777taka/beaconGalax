//
//  GXUserManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/01.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>

@interface GXUserManager : NSObject

@property (nonatomic,retain) KiiObject *gxUser;

+ (GXUserManager *)sharedManager;

//出席とかとる
- (void)setLocation:(NSString *)beaconName;
- (void)exitCommunitySpace;

- (int)getUserPoint;

- (int)getUserRank;


@end
