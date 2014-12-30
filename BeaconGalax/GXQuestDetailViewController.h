//
//  GXQuestDetailViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KiiSDK/Kii.h>
#import <Canvas/CSAnimation.h>
#import <Canvas/CSAnimationView.h>
#import <Facebook.h>

@class GXQuest;
@interface GXQuestDetailViewController : UIViewController

@property (nonatomic,strong) GXQuest *quest;

@end
