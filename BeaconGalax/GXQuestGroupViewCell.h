//
//  GXQuestGroupViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/16.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/Facebook.h>

@interface GXQuestGroupViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *isReadySignLabel;


@end
