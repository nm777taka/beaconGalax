//
//  GXJoinedQuestTableViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2014/09/20.
//  Copyright (c) 2014年 古田貴久. All rights reserved.
//

#import "GXJoinedQuestTableViewCell.h"

@implementation GXJoinedQuestTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)gotoQuestExe:(id)sender {
    
    [[NSNotificationCenter defaultCenter ] postNotificationName:GXSegueToQuestExeViewNotification object:self];
}
@end
