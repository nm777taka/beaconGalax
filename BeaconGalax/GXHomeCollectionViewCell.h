//
//  GXHomeCollectionViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/05.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import <FacebookSDK/Facebook.h>
#import <FlatUIKit/FlatUIKit.h>

@interface GXHomeCollectionViewCell : UICollectionViewCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *createrIcon;
@property (weak, nonatomic) IBOutlet UILabel *createrName;
@property (weak, nonatomic) IBOutlet UILabel *questTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *questTypeIcon;
@property (weak, nonatomic) IBOutlet UIView *questTypeColorView;

- (IBAction)joinAction:(id)sender;
@property (weak, nonatomic) IBOutlet FUIButton *acceptButton;

@end
