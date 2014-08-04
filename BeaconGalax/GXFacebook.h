//
//  GXFacebook.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/08/03.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/Facebook.h>
#import "FBConnect.h"


@interface GXFacebook : NSObject<FBRequestDelegate,FBSessionDelegate>

+ (GXFacebook *)sharedManager;
- (void)getUserInfo;
@property (nonatomic,retain) Facebook *facebook;
@property (nonatomic,retain) NSString *facebook_id;

@end
