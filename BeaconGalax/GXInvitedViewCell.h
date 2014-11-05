//
//  GXInvitedViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/14.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import <FacebookSDK/Facebook.h>

@interface GXInvitedViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet FUIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *ownerName;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *ownerIcon;
@property (weak, nonatomic) IBOutlet UILabel *userJoinStatus;

@end
