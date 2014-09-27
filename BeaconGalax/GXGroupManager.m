//
//  GXGroupManager.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXGroupManager.h"
#import "GXBucketManager.h"
#import "GXDictonaryKeys.h"
#import "GXNotification.h"

@implementation GXGroupManager

+ (GXGroupManager *)sharedManager
{
    static GXGroupManager *sharedSingleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        sharedSingleton = [[GXGroupManager alloc] initSharedInstance];
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

//渡されたグループのメンバーを返す
- (void)getQuestMember:(KiiObject *)quest
{
    //再インスタンス化
    NSError *error;
    NSString *groupURI = [quest getObjectForKey:quest_groupURI];
    KiiGroup *group = [KiiGroup groupWithURI:groupURI];
    [group refreshSynchronous:&error];
    
//    if (error == nil) {
//        [group getMemberListWithBlock:^(KiiGroup *group, NSArray *members, NSError *error) {
//            if (error == nil) {
//                
//                //さらにbucketからobjcetを取得
//                NSMutableArray *memberObjects = [[GXBucketManager sharedManager] getQuestMembers:members];
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:GXGroupMemberFetchedNotification object:memberObjects];
//            }
//        }];
//    }
    
    if (error == nil) {
        KiiBucket *bucket = [group bucketWithName:@"member"];
        
    }
}

- (void)getGroup:(KiiObject *)quest
{
    NSString *groupURI = [quest getObjectForKey:quest_groupURI];
    KiiGroup *group = [KiiGroup groupWithURI:groupURI];
    [group refreshWithBlock:^(KiiGroup *group, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GXGroupMemberFetchedNotification object:group];
    }];
}

@end
