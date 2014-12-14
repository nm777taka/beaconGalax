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
    NSDictionary *retDict = @{GXFacebookID:[ud stringForKey:GXFacebookID],
                              GXUserName:[ud stringForKey:GXUserName]};
    
    
    return retDict;
}

+ (void)setCurrentNotJoinQuestNum:(NSUInteger)num
{
    [ud setObject:[NSNumber numberWithInteger:num] forKey:@"currentNotJoinQuest"];
    BOOL succed = [ud synchronize];
    
}

+ (NSUInteger)getCurrentNotJoinQuest
{
    return [ud integerForKey:@"currentNotJoinQuest"];
}




@end
