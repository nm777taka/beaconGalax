//
//  GXActivityTableViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Facebook.h>
#import <FlatUIKit.h>
#import <KiiSDK/Kii.h>


@class GXActivity;

@interface GXActivityTableViewCell : UITableViewCell

//Model
@property (nonatomic,strong) GXActivity *activity;

//View
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end
