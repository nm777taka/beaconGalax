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

@class GXQuest;

@interface GXHomeCollectionViewCell : UICollectionViewCell

//Model[
@property (nonatomic,strong) GXQuest *quest;

//View
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *createrIcon;
@property (weak, nonatomic) IBOutlet UILabel *createrName;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLable;

- (IBAction)showInfo:(id)sender;

@end
    