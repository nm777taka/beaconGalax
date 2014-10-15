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
static NSString * const quest_level = @"level";
static NSString * const quest_type = @"type";
static NSString * const quest_reward = @"reward";
static NSString * const quest_clear_cnt = @"clear_cnt";
static NSString * const quest_clear_des = @"clear_des";
static NSString * const quest_success_cnt = @"success_cnt";
static NSString * const quest_owner = @"owner";
static NSString * const quest_player_num = @"player_num";



static NSString * const quest_createUserURI = @"created_user_uri";
static NSString * const quest_createdUser_fbid = @"facebook_id";
static NSString * const quest_groupURI = @"group_uri";
static NSString * const quest_isStarted = @"isStarted";
static NSString * const quest_isCompleted = @"isCompleted";
static NSString * const quest_createdDate = @"createdDate";
static NSString * const quest_createdUserName = @"user_name";

//ユーザ
static NSString * const user_uri = @"uri";
static NSString * const user_isNear = @"isNear";
static NSString * const user_isMember = @"isMember";
static NSString * const user_name = @"name";
static NSString * const user_email = @"email";
static NSString * const user_fb_id = @"facebook_id";
static NSString * const user_isReady = @"isReady";

//トピック
static NSString * const topic_invite = @"invite_notify";

//push通知
static NSString * const push_type = @"push_type";
static NSString * const push_invite = @"push_invite";
static NSString * const push_add_group = @"push_add_group";

//beacon
static NSString * const beacon_name = @"beacon_name";
static NSString * const beacon_major = @"major";


@interface GXDictonaryKeys : NSObject

@end
