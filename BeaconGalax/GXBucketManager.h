//
//  GXBucketManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/30.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXBucketManager : NSObject

@property (nonatomic) KiiBucket *galaxUser;

+ (GXBucketManager *)sharedMager;
- (void)registerGalaxUser:(KiiUser *)user;


@end
