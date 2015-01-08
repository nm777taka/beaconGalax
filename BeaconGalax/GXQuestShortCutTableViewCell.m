//
//  GXQuestShortCutTableViewCell.m
//  BeaconGalax
//
//  Created by 古田貴久 on 2015/01/08.
//  Copyright (c) 2015年 古田貴久. All rights reserved.
//

#import "GXQuestShortCutTableViewCell.h"

@implementation GXQuestShortCutTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.shortCutTitle.font = [UIFont boldFlatFontOfSize:17];
    self.shortCutTitle.textColor = [UIColor darkGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)createButtonPushed:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(doneCreateButton:)]) {
        [self.delegate doneCreateButton:self];
    }
}
@end
