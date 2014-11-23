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

@property (nonatomic) KiiTopic *infoTopic; //システムから発行用（お知らせ)
@property (nonatomic) KiiTopic *questInviteTopic; //クエスト募集した時にみんなに知らせる

+ (GXTopicManager *)sharedManager;
- (void)createUserTopic:(NSString *)title;
- (void)createDefaultUserTopic;
- (void)subscribeTopic;

- (void)setACL;



@end
