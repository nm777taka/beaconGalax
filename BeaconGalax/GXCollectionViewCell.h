//
//  GXCollectionViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import <FacebookSDK/Facebook.h>

@interface GXCollectionViewCell : UICollectionViewCell

//QuestBoardView

@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbIConView;

@property (weak, nonatomic) IBOutlet UILabel *questNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentJoinCountLabel;

@property (weak, nonatomic) IBOutlet UIButton *joinButton;



//FriendNowView
@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end
