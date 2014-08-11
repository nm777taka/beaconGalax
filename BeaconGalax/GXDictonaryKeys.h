//
//  GXDictonaryKeys.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/08/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

//クエスト
static NSString * const quest_title = @"title";
static NSString * const quest_description = @"description";
static NSString * const quest_createUserURI = @"created_user_uri";
static NSString * const quest_createdUser_fbid = @"facebook_id";
static NSString * const quest_groupURI = @"group_uri";
static NSString * const quest_isStarted = @"isStarted";
static NSString * const quest_isCompleted = @"isCompleted";

//ユーザ
static NSString * const user_uri = @"uri";
static NSString * const user_isNear = @"isNear";
static NSString * const user_isMember = @"isMember";
static NSString * const user_name = @"name";
static NSString * const user_email = @"email";
static NSString * const user_fb_id = @"facebook_id";


@interface GXDictonaryKeys : NSObject

@end
