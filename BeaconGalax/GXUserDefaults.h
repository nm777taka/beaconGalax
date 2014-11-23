//
//  GXUserDefaults.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXUserDefaults : NSObject

//初期値設定

+ (void)doneLaunchFirst;
+ (BOOL)isFirstLaunch;

+ (void)setAccessToken:(NSString *)token;
+ (NSString *)getAccessToken;

+ (void)setUserInfomation:(NSString *)fbid name:(NSString *)name;
+ (NSDictionary *)getUserInfomation;


@end
