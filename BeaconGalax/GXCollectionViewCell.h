//
//  GXCollectionViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/13.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>

@interface GXCollectionViewCell : UICollectionViewCell

//QuestBoardView
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *questNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *questTimeLabel;

//FriendNowView
@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end
