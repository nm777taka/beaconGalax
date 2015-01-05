//
//  GXDetailViewMembersCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/05.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXDetailViewMembersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
