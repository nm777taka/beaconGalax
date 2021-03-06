//
//  GXHomeTableViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/31.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/Facebook.h>
#import <BlocksKit/BlocksKit+UIKit.h>

@interface GXHomeTableViewCell : UITableViewCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbUserIcon;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;


@end
