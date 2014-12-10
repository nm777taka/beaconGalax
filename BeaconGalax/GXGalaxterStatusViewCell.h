//
//  GXGalaxterStatusViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXGalaxterStatusViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIconView;

@end
