//
//  GXNotification.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXNotification : NSObject

UIKIT_EXTERN  NSString *const GXapplicationDidBecomeActibve;

//ログイン関連
UIKIT_EXTERN  NSString *const GXLoginSuccessedNotification;
UIKIT_EXTERN NSString *const GXFBProfilePictNotification; //ログインした際にstatusViewでfbusericonを表示できるように

//クエスト関連
UIKIT_EXTERN NSString *const GXQuestCreatedNotification;

UIKIT_EXTERN NSString *const GXJoinedQuestFetchedNotification;

UIKIT_EXTERN NSString *const GXInvitedQuestFetchedNotification;

UIKIT_EXTERN NSString *const GXFetchQuestNotComplitedNotification;

UIKIT_EXTERN NSString *const GXQuestCellTouchedNotification;

UIKIT_EXTERN NSString *const GXQuestDeletedNotification;

UIKIT_EXTERN NSString *const GXQuestJoinNotification;

UIKIT_EXTERN NSString *const GXFetchQuestWithParticipantNotification;

UIKIT_EXTERN NSString *const GXFetchQuestWithOwnerNotification;

//参加した一人用クエストをフェッチ
UIKIT_EXTERN NSString *const GXFetchJoinedOnePersonQuestNotification;

//参加したマルチ用クエストをフェッチ
UIKIT_EXTERN NSString *const GXFetchJoinedMultiPersonQuestNotification;

//ミッション関連
UIKIT_EXTERN NSString *const GXFetchMissionWithNotCompletedNotification;

//Group関連
UIKIT_EXTERN NSString *const GXGroupMemberFetchedNotification;

//navigation
UIKIT_EXTERN NSString *const GXViewSegueNotification;

//画面遷移
UIKIT_EXTERN NSString *const GXSegueToQuestExeViewNotification;

//push
UIKIT_EXTERN NSString *const GXAddGroupSuccessedNotification;
UIKIT_EXTERN NSString *const GXStartQuestNotification;

//ポイントゲット
UIKIT_EXTERN NSString *const GXPointGetNotification;

@end
