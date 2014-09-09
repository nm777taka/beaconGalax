//
//  GXKiiCloud.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>
#import <AFNetworking/AFNetworking.h>
@interface GXKiiCloud : NSObject

+ (GXKiiCloud *)sharedManager;

- (void)kiiCloudLogin;
- (void)createBucket:(NSString *)title;
- (void)setObject:(KiiObject *)object;

@end
