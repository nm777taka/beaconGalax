//
//  GXVisitQuestExeViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/12.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EstimoteSDK/ESTBeaconManager.h>
#import <UAProgressView/UAProgressView.h>

@import CoreLocation;

@interface GXVisitQuestExeViewController : UIViewController

@property (nonatomic) KiiObject *exeQuest;
@property (nonatomic) KiiGroup *exeGroup;
@property (nonatomic) BOOL isMulti;
@property int groupMemberNum;

@end
