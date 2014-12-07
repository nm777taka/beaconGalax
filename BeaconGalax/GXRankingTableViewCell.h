//
//  GXRankingTableViewCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/07.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXRankingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userRank;
@property (weak, nonatomic) IBOutlet UILabel *userPoint;
@property (weak, nonatomic) IBOutlet UILabel *rankIndex;

@end
