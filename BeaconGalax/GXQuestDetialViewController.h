//
//  GXQuestDetialViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import <KiiSDK/Kii.h>

@interface GXQuestDetialViewController : UIViewController<FUIAlertViewDelegate>

@property (nonatomic,retain) KiiObject *quest;

@end