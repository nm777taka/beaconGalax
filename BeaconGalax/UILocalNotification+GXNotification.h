//
//  UILocalNotification+GXNotification.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/23.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILocalNotification (GXNotification)

+ (void)setQuestDeliverLocalNotification;
+ (BOOL)isQuestDeliverLocalNotification:(UILocalNotification *)notification;

@end
