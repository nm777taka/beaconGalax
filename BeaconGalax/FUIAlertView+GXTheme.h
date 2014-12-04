//
//  FUIAlertView+GXTheme.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "FUIAlertView.h"
#import <FlatUIKit/FlatUIKit.h>

@interface FUIAlertView (GXTheme)

+ (FUIAlertView *)questAcceptAlertTheme;
+ (FUIAlertView *)questInviteAlertTheme;
+ (FUIAlertView *)questStartAlertTheme;
+ (FUIAlertView *)questJoinAlertTheme;
+ (FUIAlertView *)gotoGroupViewAlertTheme;

+ (FUIAlertView *)errorTheme:(NSString *)errorMsg;
+ (FUIAlertView *)cautionTheme:(NSString *)msg;



@end
