//
//  FUIButton+GXTheme.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "FUIButton+GXTheme.h"

@implementation FUIButton (GXTheme)

+ (void)gxQuestTheme:(FUIButton *)button
{
    button.titleLabel.font = [UIFont boldFlatFontOfSize:14];
    [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    button.buttonColor = [UIColor emerlandColor];
    button.shadowColor = [UIColor nephritisColor];
    button.shadowHeight = 2.0f;
    button.cornerRadius = 1.0;
    
    [button setTitle:@"JOIN" forState:UIControlStateNormal];
}

@end
