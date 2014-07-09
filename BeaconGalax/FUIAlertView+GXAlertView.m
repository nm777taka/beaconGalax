//
//  FUIAlertView+GXAlertView.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/09.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "FUIAlertView+GXAlertView.h"
#import <FlatUIKit/FlatUIKit.h>

@implementation FUIAlertView (GXAlertView)

+ (FUIAlertView *)gxLoginTheme:(FUIAlertView *)alert
{
    alert.titleLabel.textColor = [UIColor cloudsColor];
    alert.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    
    alert.messageLabel.textColor = [UIColor cloudsColor];
    alert.messageLabel.font = [UIFont boldFlatFontOfSize:14];
    
    alert.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alert.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    
    alert.defaultButtonColor = [UIColor cloudsColor];
    alert.defaultButtonShadowColor = [UIColor asbestosColor];
    alert.defaultButtonTitleColor = [UIColor asbestosColor];
    alert.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    
    return alert;
}

@end
