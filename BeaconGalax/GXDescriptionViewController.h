//
//  GXDescriptionViewController.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/08.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KiiSDK/Kii.h>

@interface GXDescriptionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) KiiObject *object;

@end
