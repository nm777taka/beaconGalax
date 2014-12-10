//
//  GXGalaxterStatusViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/12/11.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXGalaxterStatusViewCell.h"

@implementation GXGalaxterStatusViewCell

- (void)awakeFromNib {
    // Initialization code
    self.userIconView.layer.cornerRadius = 20.f;
    self.userIconView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userIconView.layer.borderWidth = 2.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
