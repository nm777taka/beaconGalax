//
//  GXQuestGroupViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/10/16.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXQuestGroupViewCell.h"

@implementation GXQuestGroupViewCell

- (void)awakeFromNib
{
    self.userIcon.layer.cornerRadius = 40.0;
    self.userIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userIcon.layer.borderWidth = 1.0;
    
    self.userName.font = [UIFont boldFlatFontOfSize:16];
    self.readyIcon.hidden = YES;
    
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.1f;
    self.layer.shadowRadius = 2.0f;
    
}

@end
