//
//  GXQuestCompleteViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/18.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KiiSDK/Kii.h>
#import <FlatUIKit/FlatUIKit.h>
#import <Canvas/CSAnimationView.h>
#import <UAProgressView/UAProgressView.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface GXQuestCompleteViewController : UIViewController

@property KiiObject *completeQuest;
@property KiiGroup *questGroup;

@end
