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
#import <FlatUIKit/FlatUIKit.h>


@interface GXQuestReadyViewController : UIViewController

@property KiiObject *willExeQuest;
@property KiiGroup *selectedQuestGroup;
@property BOOL isPushSegued; //領域監視が少し残るため、次の画面から戻ってきた時にbug起きるからそれ用


@end
