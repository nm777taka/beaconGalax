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
@property (nonatomic) KiiBucket *nearUser;

+ (GXBucketManager *)sharedManager;
- (void)registerGalaxUser:(KiiUser *)user;
- (NSMutableArray *)getNearUser:(KiiUser *)user;



@end
