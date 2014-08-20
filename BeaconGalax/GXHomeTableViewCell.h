//
//  GXHomeTableViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/31.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/Facebook.h>

@interface GXHomeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentsLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *iconView;

@end
