//
//  GXFriendsProfileCell.h
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/07/30.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXFriendsProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userRank;

@end
