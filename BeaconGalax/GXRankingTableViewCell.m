//
//  GXRankingTableViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/07.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXRankingTableViewCell.h"

@implementation GXRankingTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.userIcon.layer.cornerRadius = 20.f;
    self.userIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userIcon.layer.borderWidth = 2.0f;
    self.userName.font = [UIFont boldFlatFontOfSize:17];
    self.rankIndex.font = [UIFont boldFlatFontOfSize:25];
    self.userRank.font = [UIFont boldFlatFontOfSize:13];
    self.userPoint.font = [UIFont boldFlatFontOfSize:13];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
