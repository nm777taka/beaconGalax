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

UIKIT_EXTERN NSString *const GXQuestFetchedQuestWithJoinedNotification;

UIKIT_EXTERN NSString *const GXFetchQuestNotComplitedNotification;

UIKIT_EXTERN NSString *const GXQuestCellTouchedNotification;

UIKIT_EXTERN NSString *const GXQuestDeletedNotification;

UIKIT_EXTERN NSString *const GXQuestJoinNotification;

UIKIT_EXTERN NSString *const GXJoindQuestFetchedNotification;

//Group関連
UIKIT_EXTERN NSString *const GXGroupMemberFetchedNotification;

//navigation
UIKIT_EXTERN NSString *const GXViewSegueNotification;

//画面遷移
UIKIT_EXTERN NSString *const GXSegueToQuestExeViewNotification;


@end
