//
//  GXDescriptionTableViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/08.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

@interface GXDescriptionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@end
