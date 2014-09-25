//
//  GXQuestMemberCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/Facebook.h>

@interface GXQuestMemberCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIconView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userReadySignLabel;

@end
