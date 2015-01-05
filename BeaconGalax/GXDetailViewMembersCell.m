//
//  GXDetailViewMembersCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/05.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import "GXDetailViewMembersCell.h"

@implementation GXDetailViewMembersCell

- (void)awakeFromNib {
    // Initialization code
    self.userIcon.layer.cornerRadius = 5.0f;
    self.userNameLabel.font = [UIFont boldFlatFontOfSize:15];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end