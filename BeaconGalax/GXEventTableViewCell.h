//
//  GXEventTableViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/06.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXEventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIconView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCleardQuestCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankingIndexLabel;

@end
