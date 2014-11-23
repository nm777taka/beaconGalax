//
//  GXUserDefaults.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXUserDefaults.h"

static NSString *const GXFirstLaunching = @"GXFirstLaunching";
static NSString *const GXAccessToken = @"GXAcessToken";
static NSString *const GXFacebookID = @"GXFacebookID";
static NSString *const GXUserName = @"GXUserName";

@implementation GXUserDefaults

static NSUserDefaults *ud;

+ (void)initialize
{
    if (!ud) {
        ud = [NSUserDefaults standardUserDefaults];
    }
}

+ (void)doneLaunchFirst
{
    [ud setBool:YES forKey:GXFirstLaunching];
    BOOL succeed = [ud synchronize];
    if (succeed) {
        NSLog(@"ud保存 @ doneLaunchFirst ");
    }
}

+ (BOOL)isFirstLaunch
{
    return [ud boolForKey:GXFirstLaunching];
}

+ (void)setAccessToken:(NSString *)token
{
    [ud setObject:token forKey:GXAccessToken];
    BOOL succeed = [ud synchronize];
    if (succeed) {
        NSLog(@"ud保存 @ setAccessToken ");
    }
}

+ (NSString *)getAccessToken
{
    return [ud stringForKey:GXAccessToken];
    
}

+ (void)setUserInfomation:(NSString *)fbid name:(NSString *)name
{
    [ud setObject:fbid forKey:GXFacebookID];
    [ud setObject:name forKey:GXUserName];
    BOOL succeed = [ud synchronize];
    if (succeed) {
        NSLog(@"ud保存 @ setUserInfomation");
    }
}

+ (NSDictionary *)getUserInfomation
{
    NSDictionary *retDict = [NSDictionary dictionary];
    [retDict setValue:[ud stringForKey:GXFacebookID] forKey:GXFacebookID];
    [retDict setValue:[ud stringForKey:GXUserName] forKey:GXUserName];
    
    return retDict;
}




@end
