//
//  GXQuestReadyViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PulsingHalo/PulsingHaloLayer.h>
#import <ChameleonFramework/Chameleon.h>
#import <EstimoteSDK/ESTBeaconManager.h>
#import <FacebookSDK/Facebook.h>
#import <KiiSDK/Kii.h>


@interface GXQuestReadyViewController : UIViewController

@property KiiObject *willExeQuest;
@property KiiGroup *selectedQuestGroup;

@end
