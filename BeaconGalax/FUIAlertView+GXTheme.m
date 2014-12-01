//
//  FUIAlertView+GXTheme.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "FUIAlertView+GXTheme.h"

@implementation FUIAlertView (GXTheme)

+ (FUIAlertView *)questAcceptAlertTheme
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"確認"
                                                          message:@"このクエストを受注しますか?"
                                                         delegate:nil cancelButtonTitle:@"しない"
                                                otherButtonTitles:@"受注", nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    return alertView;
}

+ (FUIAlertView *)questInviteAlertTheme
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"確認"
                                                          message:@"このクエストを募集しますか?\n募集した場合はあなたがリーダーとなります"
                                                         delegate:nil cancelButtonTitle:@"しない"
                                                otherButtonTitles:@"募集", nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    
    return alertView;

}

+ (FUIAlertView *)questJoinAlertTheme
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"確認"
                                                          message:@"このクエストに参加しますか?"
                                                         delegate:nil cancelButtonTitle:@"しない"
                                                otherButtonTitles:@"参加", nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    return alertView;
}

+ (FUIAlertView *)questStartAlertTheme
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"確認"
                                                          message:@"このクエストを開始しますか?"
                                                         delegate:nil cancelButtonTitle:@"しない"
                                                otherButtonTitles:@"開始", nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    return alertView;

}

+ (FUIAlertView *)gotoGroupViewAlertTheme
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"開始なクエストです"
                                                          message:@"このクエストを開始しますか？"
                                                         delegate:nil cancelButtonTitle:@"しない"
                                                otherButtonTitles:@"開始", nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    return alertView;

}

+ (FUIAlertView *)errorTheme:(NSString *)errorMsg
{
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error"
                                                          message:errorMsg                                                         delegate:nil cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil, nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor pomegranateColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor pumpkinColor];
    return alertView;

}

@end
