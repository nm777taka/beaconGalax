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
UIKIT_EXTERN  NSString *const GXLoginSuccessedNotification;

UIKIT_EXTERN NSString *const GXQuestCreatedNotification;

UIKIT_EXTERN NSString *const GXQuestFetchedNotification;

UIKIT_EXTERN NSString *const GXQuestCellTouchedNotification;

@end
