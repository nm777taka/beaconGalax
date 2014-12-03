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

UIKIT_EXTERN NSString *const GXRegisteredInvitedBoardNotification;

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
UIKIT_EXTERN NSString *const GXEndQuestNotification;
UIKIT_EXTERN NSString *const GXCommitQuestNotification;

//ポイントゲット
UIKIT_EXTERN NSString *const GXPointGetNotification;

//LocalNotification
UIKIT_EXTERN NSString *const GXRefreshDataFromLocalNotification;

//ログイン関連ｎ
UIKIT_EXTERN NSString *const GXSignUpNotification;

//バケット内オブジェクトをカウント
UIKIT_EXTERN NSString *const GXBucketObjectCountNotification;

//ユーザに紐付いたbeaconからfbidを取得
UIKIT_EXTERN NSString *const GXGetTargetBeaconUserFbidNotification;

@end
