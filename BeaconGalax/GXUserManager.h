//
//  GXUserManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/01.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXUserManager : NSObject

+ (GXUserManager *)sharedManager;

- (void)addCalamAtSignup:(KiiUser *)user;


@end
