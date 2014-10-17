//
//  GXNotification.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXNotification.h"

@implementation GXNotification

NSString *const GXapplicationDidBecomeActibve = @"GXapplicationDidBecomeActibve";

NSString *const GXLoginSuccessedNotification = @"GXLoginSuccessedNotification";

NSString *const GXQuestCreatedNotification = @"GXQuestCreatedNotification";

//フェッチ
NSString *const GXFetchQuestNotComplitedNotification = @"GXFetchQuestNotComplitedNotification";
NSString *const GXFetchMissionWithNotCompletedNotification = @"GXFetchMissionWithNotCompletedNotification";

NSString *const GXJoinedQuestFetchedNotification = @"GXJoinedQuestFetchedNotification"
;

//参加した一人用クエストをフェッチ
NSString *const GXFetchJoinedOnePersonQuestNotification = @"GXFetchJoinedOnePersonQuestNotification";

//参加したマルチ用クエストをフェッチ
NSString *const GXFetchJoinedMultiPersonQuestNotification = @"GXFetchJoinedMultiPersonQuestNotification";

//招待ボードにあるクエストをフェッチ
NSString *const GXInvitedQuestFetchedNotification = @"GXInvitedQuestFetchedNotification";


NSString *const GXQuestCellTouchedNotification = @"GXQuestCellTouchedNotification";

NSString *const GXQuestDeletedNotification = @"GXQuestDeletedNotification";

NSString *const GXQuestJoinNotification = @"GXQuestJoinNotification";

NSString *const GXFetchQuestWithParticipantNotification = @"GXFetchQuestWithParticipantNotification";
NSString *const GXGroupMemberFetchedNotification = @"GXGroupMemberFetchedNotification";

NSString *const GXFetchQuestWithOwnerNotification = @"GXFetchQuestWithOwnerNotification";

NSString *const GXFBProfilePictNotification = @"GXFBProfilePictNotification";

NSString *const GXAddGroupSuccessedNotification = @"GXAddGroupSuccessedNotification";

NSString *const GXStartQuestNotification = @"GXStartQuestNotification";

NSString *const GXViewSegueNotification = @"GXViewSegueNotification";

NSString *const GXSegueToQuestExeViewNotification = @"GXSegueToQuestExeViewNotification ";

NSString *const GXPointGetNotification = @"GXPointGetNotification";

@end
