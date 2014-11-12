//
//  GXAppDelegate.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/06/24.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KiiSDK/Kii.h>
#import <CoreLocation/CoreLocation.h>
#import <TSMessages/TSBlurView.h>
#import <TSMessages/TSMessageView.h>
#import <FlatUIKit.h>
#import <CWStatusBarNotification.h>
#import "FBConnect.h"
#import "GXFacebook.h"

@interface GXAppDelegate : UIResponder <UIApplicationDelegate,FBSessionDelegate,FBRequestDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property GXFacebook *gxFbManager;
@property (nonatomic,retain) Facebook *facebook;
@property KiiObject *gxUser;

@end
