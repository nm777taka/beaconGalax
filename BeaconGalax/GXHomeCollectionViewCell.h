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

@class GXQuest;

@interface GXHomeCollectionViewCell : UICollectionViewCell

//Model[
@property (nonatomic,strong) GXQuest *quest;

//View
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *createrIcon;
@property (weak, nonatomic) IBOutlet UILabel *createrName;
@property (weak, nonatomic) IBOutlet UILabel *questTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *questTypeIcon;
@property (weak, nonatomic) IBOutlet UIView *questTypeColorView;
@property (weak, nonatomic) IBOutlet UILabel *requirementLabel;


@end
