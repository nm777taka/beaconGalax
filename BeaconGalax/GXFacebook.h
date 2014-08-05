//
//  GXFacebook.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/08/03.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <KiiSDK/Kii.h>

@interface GXFacebook : NSObject

+ (GXFacebook *)sharedManager;
- (void)getUserFacebookID;

@end
