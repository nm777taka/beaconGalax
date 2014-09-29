//
//  GXQuestMemberCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/25.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestMemberCell.h"

@implementation GXQuestMemberCell

- (void)awakeFromNib {
    // Initialization code
    self.userIconView.layer.cornerRadius = 20.0f;
    self.userIconView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userIconView.layer.borderWidth = 2.0f;
    
    self.userNameLabel.textColor = [UIColor whiteColor];
    self.userReadySignLabel.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
