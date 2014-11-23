//
//  GXKiiCloud.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXKiiCloud.h"
#import "GXNotification.h"
#import "GXBucketManager.h"
#import "GXTopicManager.h"
#import "GXUserManager.h"
#import "GXDictonaryKeys.h"
#import "GXFacebook.h"
#import "GXUserDefaults.h"

@implementation GXKiiCloud

+ (GXKiiCloud *)sharedManager
{
    static GXKiiCloud *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXKiiCloud alloc]initSharedInstance];
    });
    
    return sharedSingleton;
    
}

- (id)initSharedInstance
{
    self = [super init];
    
    if (self) {
        //init
        
    }
    
    return self;
}

#pragma mark - KiiCloud
- (void)kiiCloudLogin
{
    [KiiSocialConnect setupNetwork:kiiSCNFacebook withKey:@"559613677480642" andSecret:nil andOptions:nil];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSArray arrayWithObject:@"email"],@"permissions", nil];
    
    [KiiSocialConnect logIn:kiiSCNFacebook usingOptions:options withDelegate:self andCallback:@selector(loginFinished:usingNetwork:withError:)];
    
}

- (void)loginFinished:(KiiUser *)user usingNetwork:(KiiSocialNetworkName)network withError:(NSError *)error {
    
    if (error == nil) {
        
        [KiiPushInstallation installSynchronous:&error];
        
        if (error != nil) {
        NSLog(@"push install error:%@",error);
        } else {
        NSLog(@"push install!!");
                
        [[NSNotificationCenter defaultCenter] postNotificationName:GXLoginSuccessedNotification object:nil];
                
        }

    } else {
        NSLog(@"error : %@",error);
    }
}

@end
