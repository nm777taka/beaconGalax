//
//  GXTopicManager.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/30.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KiiSDK/Kii.h>

@interface GXTopicManager : NSObject

+ (GXTopicManager *)sharedManager;
- (void)createUserTopic:(NSString *)title;
- (void)createDefaultUserTopic;
- (void)setACL;



@end
