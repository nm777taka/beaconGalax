//
//  GXStatusViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit.h>
#import <Facebook.h>

@interface GXStatusViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *createrIcon;
@property (weak, nonatomic) IBOutlet UILabel *createdDate;

@end
