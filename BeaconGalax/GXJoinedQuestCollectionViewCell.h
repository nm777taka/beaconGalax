//
//  GXJoinedQuestCollectionViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/11/28.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import <FacebookSDK/Facebook.h>

@class GXQuest;

@interface GXJoinedQuestCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) GXQuest *quest;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *createrIcon;

- (IBAction)showDetail:(id)sender;

@end
