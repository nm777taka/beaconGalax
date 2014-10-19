//
//  GXQuestExeViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/18.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PulsingHalo/PulsingHaloLayer.h>
#import <ChameleonFramework/Chameleon.h>
#import <EstimoteSDK/ESTBeaconManager.h>
#import <KiiSDK/Kii.h>
#import <UAProgressView/UAProgressView.h>

@interface GXQuestExeViewController : UIViewController

@property (nonatomic,retain) KiiObject *exeQuest;
@property (nonatomic,retain) KiiGroup *exeGroup;

@end
